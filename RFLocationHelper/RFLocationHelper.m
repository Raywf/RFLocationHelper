//
//  RFLocationHelper.m
//  RFLocationHelper
//
//  Created by Raywf on 2018/2/26.
//  Copyright © 2018年 S.Ray. All rights reserved.
//

#import "RFLocationHelper.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface RFLocationHelper () <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLGeocoder *geoManager;
@property (nonatomic, copy) void (^Request)(NSInteger status, NSString *description);
@property (nonatomic, copy) void (^Location)(CLLocation *location, NSError *error);
@property (nonatomic, copy) void (^ReverseGeocoder)(NSArray<CLPlacemark *> *placemarks, NSError *error);
@end

static RFLocationHelper *instance = nil;
@implementation RFLocationHelper

#pragma mark - Public Methods
+ (void)CheckAuthorizationStatusCompletion:(void (^)(NSInteger, NSString *))completion {
    [[RFLocationHelper SharedInstance]
     reportLocationServicesAuthorizationStatus:[CLLocationManager authorizationStatus]
     Completion:completion];;
}

+ (void)RequestAuthorizationStatusCompletion:(void (^)(NSInteger, NSString *))completion {
    [RFLocationHelper SharedInstance].Request = completion;
    [[RFLocationHelper SharedInstance] requestLocationServicesAuthorization];
}

+ (void)StartUpdatingLocation:(void (^)(CLLocation *, NSError *))location
              ReverseGeocoder:(void (^)(NSArray<CLPlacemark *> *, NSError *))reverseGeocoder {
    [self RequestAuthorizationStatusCompletion:nil];
    [RFLocationHelper SharedInstance].Location = location;
    [RFLocationHelper SharedInstance].ReverseGeocoder = reverseGeocoder;
    [[RFLocationHelper SharedInstance].locationManager startUpdatingLocation];
}

+ (void)StopUpdatingLocation {
    [[RFLocationHelper SharedInstance].locationManager stopUpdatingLocation];;
}

#pragma mark - Private Methods
+ (RFLocationHelper *)SharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [RFLocationHelper new];
    });
    return instance;
}

#pragma mark 检查授权
- (void)reportLocationServicesAuthorizationStatus:(CLAuthorizationStatus)status
                                       Completion:(void (^)(NSInteger status,
                                                            NSString *description))completion {
    if (![CLLocationManager locationServicesEnabled]) {
        if (completion) {
            completion(-1, @"系统定位服务未开启。");
        }
        return;
    }

    NSString *description = @"";
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:{
            description = @"应用正在等待用户授权。";
            break;
        }
        case kCLAuthorizationStatusRestricted:{
            description = @"应用授权被限制，用户可能未见到权限提示框，目前不清楚什么情况会导致api返回这个状态码。";
            break;
        }
        case kCLAuthorizationStatusDenied:{
            description = @"用户已拒绝授权。";
            break;
        }
        case kCLAuthorizationStatusAuthorizedWhenInUse:{
            description = @"用户已授权。【kCLAuthorizationStatusAuthorizedWhenInUse】";
            break;
        }
        case kCLAuthorizationStatusAuthorizedAlways:{
            description = @"用户已授权。【kCLAuthorizationStatusAuthorizedAlways】";
            break;
        }
    }
    if (completion) {
        completion(status, description);
    }
}

#pragma mark 获取授权
- (void)requestLocationServicesAuthorization {
//    if (![CLLocationManager locationServicesEnabled]) {
//        if (completion) {
//            completion(-1, @"系统定位服务未开启。");
//        }
//        return;
//    }

    //CLLocationManager的实例对象一定要保持生命周期的存活
    if (!self.locationManager) {
        self.locationManager  = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = 100; // 设置定位距离过滤参数 (当本次定位和上次定位之间的距离大于或等于这个值时，调用代理方法)
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest; // 设置定位精度(精度越高越耗电)

        if (@available(iOS 9.0, *)) {
            self.locationManager.allowsBackgroundLocationUpdates = YES;
        } else {
            // Fallback on earlier versions
        }

        self.geoManager = [[CLGeocoder alloc] init];
    }

    //[self.locationManager requestWhenInUseAuthorization];
    [self.locationManager requestAlwaysAuthorization];
}

#pragma mark CLLocationMangerDelegate methods
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self.locationManager stopUpdatingLocation];
    if (self.Location) {
        self.Location(nil, error);
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *newLocation = locations[0];
    if (self.Location) {
        self.Location(newLocation, nil);
    }
    //CLLocationCoordinate2D oldCoordinate = newLocation.coordinate;
    //NSLog(@"旧的经度：%f,旧的纬度：%f",oldCoordinate.longitude,oldCoordinate.latitude);

    if (!self.ReverseGeocoder) {
        return;
    }
    [self.geoManager reverseGeocodeLocation:newLocation
                          completionHandler:^(NSArray<CLPlacemark *> *_Nullable placemarks,
                                              NSError * _Nullable error) {
                              if (self.ReverseGeocoder) {
                                  self.ReverseGeocoder(placemarks, error);
                              }
                              //for (CLPlacemark *place in placemarks) {
                              //    NSLog(@"name,%@",place.name);                      // 位置名
                              //    NSLog(@"thoroughfare,%@",place.thoroughfare);      // 街道
                              //    NSLog(@"subThoroughfare,%@",place.subThoroughfare);// 子街道
                              //    NSLog(@"locality,%@",place.locality);              // 市
                              //    NSLog(@"subLocality,%@",place.subLocality);        // 区
                              //    NSLog(@"country,%@",place.country);                // 国家
                              //}
                          }];

}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    [self reportLocationServicesAuthorizationStatus:status Completion:self.Request];
}

@end
