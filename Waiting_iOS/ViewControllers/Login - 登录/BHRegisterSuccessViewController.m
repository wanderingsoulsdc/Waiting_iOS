//
//  BHResetPWSuccessViewController.m
//  Customer
//
//  Created by QiuLiang Chen QQ：1123548362 on 2017/5/19.
//  Copyright © 2017年 BEHE. All rights reserved.
//
//  If the hero never comes to you
//  Keep calm and be a man

#import "BHRegisterSuccessViewController.h"
#import <Masonry/Masonry.h>
#import "FSLaunchManager.h"
#import "BHUserModel.h"
#import "FSNetWorkManager.h"
#import "UIViewController+NavigationItem.h"
#import "FSDeviceManager.h"
#import "UIButton+countdown.h"
#import "YYKit.h"

@interface BHRegisterSuccessViewController ()

@property (nonatomic, strong) UIImageView * checkSuccessImageView;
@property (nonatomic, strong) UILabel     * successLabel;
@property (nonatomic, strong) UIButton    * confirmButton;

@property (nonatomic, assign) BOOL        isTokenRequesting;//是否正在请求token

@end

@implementation BHRegisterSuccessViewController


#pragma mark - Life circle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.type == ResetPassWordTypeRegister ? @"注册成功" : @"重置密码成功";
    self.title = self.type == ResetPassWordTypeReset ? @"修改密码成功" : self.title;
    self.view.backgroundColor = UIColorFromRGB(0xFAFAFA);
    
    self.isTokenRequesting = NO;
    //如果本地不存在token
    if (self.type == ResetPassWordTypeForget || self.type == ResetPassWordTypeReset) {
        [self requestUserToken];
    }
    
    // You should add subviews here, just add subviews
    [self.view addSubview:self.checkSuccessImageView];
    [self.view addSubview:self.successLabel];
    [self.view addSubview:self.confirmButton];
    
    // You should add notification here
    
    
    // layout subviews
    [self layoutSubviews];
    
    if (self.type == ResetPassWordTypeForget) {
        [self setConfirmButtonTimer:@"进入登录页"];
    }else{
        [self setConfirmButtonTimer:@"进入招财宝"];
    }
    
    [self setLeftBarButtonTarget:self Action:@selector(leftBarButtonAction:) Image:@""];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.confirmButton endSetting];
}

- (void)layoutSubviews {
    //You should set subviews constrainsts or frame here
    
    [self.checkSuccessImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(100);
        make.width.height.equalTo(@120);
    }];
    [self.successLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.checkSuccessImageView.mas_bottom).offset(15);
        make.height.equalTo(@20);
    }];
    [self.confirmButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.successLabel.mas_bottom).offset(80);
        make.left.equalTo(self.view).offset(50);
        make.right.equalTo(self.view).offset(-50);
        make.height.equalTo(@40);
    }];
}

#pragma mark - SystemDelegate



#pragma mark - CustomDelegate



#pragma mark - Event response
// button、gesture, etc

- (void)confirmButtonAction:(UIButton *)sender
{
    //取消自动进入
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(confirmButtonAction:) object:nil];
    
    if (self.type == ResetPassWordTypeForget) {
        [[FSLaunchManager sharedInstance] launchWindowWithType:LaunchWindowTypeLogin];
        return;
    }
    
    if (self.isTokenRequesting) {
        return;
    }
    
    if (!kStringNotNull(self.token)) {
        [self requestUserToken];
        return;
    }
    
    NSLog(@"确定");
    NSString * mobile = [BHUserModel sharedInstance].mobile;
    NSString * password = [BHUserModel sharedInstance].passwd;
    
    [ShowHUDTool showLoading];
    NSDictionary * params = @{@"mobile":mobile,
                              @"password":password,
                              @"token":self.token,
                              @"idfa":[[FSDeviceManager sharedInstance] getDeviceID],
                              @"appVersion":[[FSDeviceManager sharedInstance] getAppVersion],
                              @"system":[[FSDeviceManager sharedInstance] getSystemName],
                              @"systemVersion":[[FSDeviceManager sharedInstance] getSystemVersion],
                              @"deviceName":[[FSDeviceManager sharedInstance] getDeviceModel],
                              @"netType":[[FSDeviceManager sharedInstance] getNetType],
                              @"carrierName":[[FSDeviceManager sharedInstance] getCarrierName],
                              @"deviceModel":[[FSDeviceManager sharedInstance] getDeviceModel],
                              };
    [FSNetWorkManager requestWithType:HttpRequestTypePost
                        withUrlString:kApiLogin
                        withParaments:params withSuccessBlock:^(NSDictionary *object) {
                            NSLog(@"请求成功");
                            [ShowHUDTool hideAlert];
                            if (NetResponseCheckStaus)
                            {
                                [[BHUserModel sharedInstance] analysisUserInfoWithDictionary:object Mobile:mobile Passwd:password Token:self.token];
                                NSInteger deviceNum = [object[@"data"][@"deviceNum"] integerValue];
                                                            
                                if (deviceNum < 1) {
                                    [[FSLaunchManager sharedInstance] launchWindowWithType:LaunchWindowTypeAddDevice];
                                }else{
                                    [[FSLaunchManager sharedInstance] launchWindowWithType:LaunchWindowTypeMain];
                                }
                            }
                            else
                            {
                                [ShowHUDTool showBriefAlert:NetResponseMessage];
                            }
                            
                        } withFailureBlock:^(NSError *error) {
                            NSLog(@"error is %@", error);
                            [ShowHUDTool hideAlert];
                            [ShowHUDTool showBriefAlert:NetRequestFailed];
                        }];
}

- (void)leftBarButtonAction:(UIButton *)sender
{
    NSLog(@"取消掉返回按钮");
}

#pragma mark - Private methods
//设置确认按钮倒计时
- (void)setConfirmButtonTimer:(NSString *)content{
    JxbScaleSetting* setting = [[JxbScaleSetting alloc] init];
    setting.strSuffix = [NSString stringWithFormat:@"s %@",content];
    setting.strCommon = content;
    setting.indexStart = 3;
    setting.colorDisable = UIColorBlue;
    setting.colorCommon = UIColorBlue;
    setting.enable = YES;
    [self.confirmButton startWithSetting:setting];
    [self performSelector:@selector(confirmButtonAction:) withObject:nil afterDelay:3.0f];
}

//请求用户token
- (void)requestUserToken
{
    if (self.isTokenRequesting) {
        return;
    }
    self.isTokenRequesting = YES;
    NSDictionary * params = @{@"source":@"11",@"time":[self getTimestampFromCurrentTime],@"secret":[self getMD5Encrypt]};
    [FSNetWorkManager requestWithType:HttpRequestTypeGet
                        withUrlString:kApiLoginGetToken
                        withParaments:params
                     withSuccessBlock:^(NSDictionary *object) {
                         
                         if (NetResponseCheckStaus)
                         {
                             NSLog(@"请求token成功");
                             NSDictionary *dic = object[@"data"];
                             self.token = dic[@"token"];
                         }
                         else
                         {
                             [ShowHUDTool showBriefAlert:NetResponseMessage];
                         }
                         self.isTokenRequesting = NO;
                     } withFailureBlock:^(NSError *error) {
                         NSLog(@"error is:%@", error);
                         [ShowHUDTool showBriefAlert:NetRequestFailed];
                         self.isTokenRequesting = NO;
                     }];
}

#pragma mark - 获取接口参数
//md5(本地秘钥+当前时间戳)

- (NSString *)getMD5Encrypt{
    NSString *string = [NSString stringWithFormat:@"%@%@",kTokenLocalKey,[self getTimestampFromCurrentTime]];
    return [string md5String];
}


//获取当前时间的 时间戳
- (NSString *)getTimestampFromCurrentTime{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];// ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    //设置时区,这个对于时间的处理有时很重要
    //例如你在国内发布信息,用户在国外的另一个时区,你想让用户看到正确的发布时间就得注意时区设置,时间的换算.
    //例如你发布的时间为2010-01-26 17:40:50,那么在英国爱尔兰那边用户看到的时间应该是多少呢?
    //他们与我们有7个小时的时差,所以他们那还没到这个时间呢...那就是把未来的事做了
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    
    [formatter setTimeZone:timeZone];
    
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    
    NSString *nowtimeStr = [formatter stringFromDate:datenow];//----------将nsdate按formatter格式转成nsstring
    
    NSLog(@"%@", nowtimeStr);
    
    // 时间转时间戳的方法:
    
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    
    NSLog(@"timeSp:%@",timeSp);//时间戳的值
    
    return timeSp;
}

#pragma mark - Getters and Setters
// initialize views here, etc

- (UIImageView *)checkSuccessImageView
{
    if (!_checkSuccessImageView)
    {
        _checkSuccessImageView = [[UIImageView alloc] init];
        _checkSuccessImageView.contentMode = UIViewContentModeScaleAspectFit;
        _checkSuccessImageView.image = [UIImage imageNamed:@"login_register_success"];
    }
    return _checkSuccessImageView;
}
- (UILabel *)successLabel
{
    if (!_successLabel)
    {
        _successLabel = [[UILabel alloc] init];
        _successLabel.text = self.type == ResetPassWordTypeRegister ? @"恭喜您，注册成功!" : @"重置密码成功!";
        _successLabel.text = self.type == ResetPassWordTypeReset ? @"修改密码成功" : _successLabel.text;
        _successLabel.textColor = UIColorFromRGB(0x797E81);
        _successLabel.font = [UIFont systemFontOfSize:16];
        _successLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _successLabel;
}
- (UIButton *)confirmButton
{
    if (!_confirmButton)
    {
        _confirmButton = [[UIButton alloc] init];
        _confirmButton.backgroundColor = UIColorBlue;
        [_confirmButton setTitle:@"进入招财宝" forState:UIControlStateNormal];
        [_confirmButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
        _confirmButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _confirmButton.layer.cornerRadius = 2;
        _confirmButton.clipsToBounds = YES;
        [_confirmButton addTarget:self action:@selector(confirmButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

#pragma mark - MemoryWarning

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
