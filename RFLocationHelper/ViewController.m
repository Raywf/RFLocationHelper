//
//  ViewController.m
//  RFLocationHelper
//
//  Created by Raywf on 2018/2/26.
//  Copyright © 2018年 S.Ray. All rights reserved.
//

#import "ViewController.h"
#import "RFLocationHelper.h"

@interface ViewController ()
@property (nonatomic, strong) UILabel *displayLab;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.title = @"简单定位";
    self.view.backgroundColor = [UIColor lightGrayColor];

    [self customUI];
}

- (void)customUI {
    CGRect frame = CGRectMake(10, 64+10, CGRectGetWidth(self.view.frame)-20, 47);
    UILabel *displayLab = [[UILabel alloc] initWithFrame:frame];
    displayLab.backgroundColor = [UIColor whiteColor];
    displayLab.textColor = [UIColor purpleColor];
    displayLab.textAlignment = NSTextAlignmentCenter;
    displayLab.adjustsFontSizeToFitWidth = YES;
    displayLab.text = @"empty";
    [self.view addSubview:displayLab];
    self.displayLab = displayLab;

    frame = CGRectMake((CGRectGetWidth(self.view.frame)-200)/2, 64*2+10, 200, 47);
    UIButton *rightsBtn = [[UIButton alloc] initWithFrame:frame];
    rightsBtn.backgroundColor = [UIColor purpleColor];
    rightsBtn.layer.cornerRadius = 47.0f/2;
    rightsBtn.clipsToBounds = YES;
    [rightsBtn setTitle:@"Request Rights" forState:UIControlStateNormal];
    [rightsBtn addTarget:self action:@selector(requestLocationServicesAuthorization:)
        forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rightsBtn];

    frame = CGRectMake((CGRectGetWidth(self.view.frame)-200)/2, 64*3+10, 200, 47);
    UIButton *locBtn = [[UIButton alloc] initWithFrame:frame];
    locBtn.backgroundColor = [UIColor purpleColor];
    locBtn.layer.cornerRadius = 47.0f/2;
    locBtn.clipsToBounds = YES;
    [locBtn setTitle:@"Start Loc" forState:UIControlStateNormal];
    [locBtn addTarget:self action:@selector(startUpdateLocation:)
     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:locBtn];

    __weak typeof(self) weakSelf = self;
    [RFLocationHelper CheckAuthorizationStatusCompletion:^(NSInteger status,
                                                           NSString *description) {
        weakSelf.displayLab.text = description;
    }];
}

- (void)requestLocationServicesAuthorization:(UIButton *)sender {
    __weak typeof(self) weakSelf = self;
    [RFLocationHelper RequestAuthorizationStatusCompletion:^(NSInteger status,
                                                             NSString *description) {
        weakSelf.displayLab.text = description;
    }];
}

- (void)startUpdateLocation:(UIButton *)sender {
    __weak typeof(self) weakSelf = self;
    [RFLocationHelper StartUpdatingLocation:^(CLLocation *location, NSError *error) {
        if (!error) {
            weakSelf.displayLab.text = [NSString stringWithFormat:@"经度：%f, 纬度：%f", location.coordinate.longitude, location.coordinate.latitude];
            //[RFLocationHelper StopUpdatingLocation];
        }
    } ReverseGeocoder:^(NSArray<CLPlacemark *> *placemarks, NSError *error) {
        if (!error) {
            NSLog(@"%@", placemarks);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
