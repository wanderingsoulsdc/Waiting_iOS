//
//  LiteDeviceAddViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/6/29.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteDeviceAddViewController.h"
#import "BHUserModel.h"
#import "FSNetWorkManager.h"
#import "LiteDeviceScanQRViewController.h"
#import <Masonry/Masonry.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>   //引入base相关所有的头文件
#import <BaiduMapAPI_Map/BMKMapComponent.h>     //引入地图功能所有的头文件
#import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件

@interface LiteDeviceAddViewController ()<BMKMapViewDelegate,UINavigationControllerDelegate>
{
    BMKMapView* _mapView;
}

@property (nonatomic , strong) UIView * deviceAddView;

@end

@implementation LiteDeviceAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.delegate = self;

    _mapView = [[BMKMapView alloc] initWithFrame:self.view.bounds];
    _mapView.userInteractionEnabled = NO;
    
    [self.view addSubview:_mapView];
    
    [self DeviceAddView];

    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    
//    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
}

- (void)viewWillDisappear:(BOOL)animated
{
//    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
}

#pragma mark - UINavigationControllerDelegate
// 将要显示控制器
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // 判断要显示的控制器是否是自己
    BOOL isSelfVC = [viewController isKindOfClass:[self class]];
    if (isSelfVC) {
        [self.navigationController setNavigationBarHidden:isSelfVC animated:YES];
    }
}

#pragma mark - UI
- (void)DeviceAddView
{
    self.deviceAddView = [[UIView alloc] init];
    self.deviceAddView.layer.cornerRadius = 4;
    self.deviceAddView.layer.masksToBounds = YES;
    self.deviceAddView.backgroundColor = [UIColorWhite colorWithAlphaComponent:1];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed:@"no_data"];
    [self.deviceAddView addSubview:imageView];
    
    UIButton *addButton = [[UIButton alloc] init];
    [addButton setTitle:@"添加一个设备" forState:UIControlStateNormal];
    [addButton setTitleColor:UIColorWhite forState:UIControlStateNormal];
    addButton.titleLabel.font = [UIFont systemFontOfSize:14];
    addButton.backgroundColor = UIColorBlue;
    addButton.layer.cornerRadius = 19;
    addButton.layer.masksToBounds = YES;
    [addButton addTarget:self action:@selector(addDeviceAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.deviceAddView addSubview:addButton];
    
    UIButton *loginButton = [[UIButton alloc] init];
    [loginButton setTitle:@"退出登录" forState:UIControlStateNormal];
    [loginButton setTitleColor:UIColorBlue forState:UIControlStateNormal];
    loginButton.titleLabel.font = [UIFont systemFontOfSize:14];
    loginButton.backgroundColor = UIColorWhite;
    loginButton.layer.cornerRadius = 19;
    loginButton.layer.masksToBounds = YES;
    loginButton.layer.borderColor = UIColorBlue.CGColor;
    loginButton.layer.borderWidth = 1;
    [loginButton addTarget:self action:@selector(switchLogin:) forControlEvents:UIControlEventTouchUpInside];
    [self.deviceAddView addSubview:loginButton];
    
    
    [self.view addSubview:self.deviceAddView];
    
    [self.deviceAddView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.centerY.equalTo(self.view.mas_centerY).offset(-0);//负数向上偏移
        make.height.mas_equalTo(kScreenHeight*4/7);
    }];
    
    [imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.deviceAddView.mas_centerX);
        make.centerY.equalTo(self.deviceAddView.mas_centerY).offset(-50);
        make.height.width.equalTo(self.deviceAddView.mas_width).multipliedBy(1.0/2.0);
    }];
    
    [addButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imageView.mas_bottom).offset(30);
        make.height.equalTo(@38);
        make.width.equalTo(imageView.mas_width);
        make.centerX.equalTo(imageView.mas_centerX);
    }];
    
    [loginButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(addButton.mas_bottom).offset(15);
        make.height.equalTo(@38);
        make.width.equalTo(imageView.mas_width);
        make.centerX.equalTo(imageView.mas_centerX);
    }];
    
}

#pragma mark - Action About
- (void)addDeviceAction:(UIButton *)button{
    NSLog(@"添加设备");
    LiteDeviceScanQRViewController *vc = [[LiteDeviceScanQRViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)switchLogin:(UIButton *)button{
    NSLog(@"切换账号");
    [ShowHUDTool showLoading];
    [FSNetWorkManager requestWithType:HttpRequestTypeGet
                            withUrlString:kApiLogout
                            withParaments:nil withSuccessBlock:^(NSDictionary *object) {
                                NSLog(@"请求成功");
                                
                                [ShowHUDTool hideAlert];
                                
                                if (NetResponseCheckStaus)
                                {
                                    [FSNetWorkManager clearCookies];
                                    [BHUserModel cleanupCache];
                                    
                                    [[FSLaunchManager sharedInstance] launchWindowWithType:LaunchWindowTypeLogin];
                                }
                                else
                                {
                                    [ShowHUDTool showBriefAlert:NetResponseMessage];
                                }
                            } withFailureBlock:^(NSError *error) {
                                
                                [ShowHUDTool hideAlert];
                                [FSNetWorkManager clearCookies];
                                [BHUserModel cleanupCache];
                                [[FSLaunchManager sharedInstance] launchWindowWithType:LaunchWindowTypeLogin];
                            }];
}


#pragma mark -

#pragma mark -

#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
