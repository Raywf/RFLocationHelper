//
//  RFLocationHelper.h
//  RFLocationHelper
//
//  Created by Raywf on 2018/2/26.
//  Copyright © 2018年 S.Ray. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface RFLocationHelper : NSObject

+ (void)CheckAuthorizationStatusCompletion:(void (^)(NSInteger status,
                                                     NSString *description))completion;

+ (void)RequestAuthorizationStatusCompletion:(void (^)(NSInteger status,
                                                       NSString *description))completion;

+ (void)StartUpdatingLocation:(void (^)(CLLocation *location, NSError *error))location
              ReverseGeocoder:(void (^)(NSArray<CLPlacemark *> *placemarks,
                                        NSError *error))reverseGeocoder;

+ (void)StopUpdatingLocation;

@end
