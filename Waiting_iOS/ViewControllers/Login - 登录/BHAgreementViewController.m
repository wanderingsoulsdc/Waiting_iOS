//
//  BHAgreementViewController.m
//  Waiting_iOS
//
//  Created by QiuLiang Chen QQ：1123548362 on 2017/12/6.
//Copyright © 2017年 BEHE. All rights reserved.
//
//  If the hero never comes to you
//  Keep calm and be a man

#import "BHAgreementViewController.h"
#import "FSNetWorkManager.h"
#import <Masonry/Masonry.h>
#import "BHUserModel.h"
#import "JPUSHService.h"
#import "FSDeviceManager.h"
#import "FSPushManager.h"

@interface BHAgreementViewController ()

@property (nonatomic, strong) UIView                 * lineView;
@property (nonatomic, strong) UILabel                * remindLabel;
@property (nonatomic, strong) UIButton               * refuseButton;
@property (nonatomic, strong) UIButton               * consentButton;   // 同意

@end

@implementation BHAgreementViewController

#pragma mark - Life circle

- (void)viewDidLoad {
    self.title = @"璧合用户服务协议";
    self.view.backgroundColor = UIColorFromRGB(0xFAFAFA);
    if (self.type == BHAgreementTypeNew)
    {
        [self.view addSubview:self.lineView];
        [self.view addSubview:self.remindLabel];
        [self.view addSubview:self.refuseButton];
        [self.view addSubview:self.consentButton];
    }
    
    // You should add notification here
    
    [super viewDidLoad];
}

- (void)layoutSubviews {
    //You should set subviews constrainsts or frame here
    
    [self.webView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(self.type == BHAgreementTypeNew ? 30 : 0);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(self.type == BHAgreementTypeNew ? -60 : 0);
    }];
    
    if (self.type == BHAgreementTypeNew)
    {
        [self.lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.webView.mas_bottom);
            make.left.right.equalTo(self.view);
            make.height.equalTo(@1);
        }];
        [self.remindLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.view);
            make.height.equalTo(@30);
        }];
        [self.refuseButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(-12);
            make.height.equalTo(@40);
            make.right.equalTo(self.view.mas_centerX).offset(-20);
            make.width.equalTo(@100);
        }];
        [self.consentButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.refuseButton);
            make.width.height.equalTo(self.refuseButton);
            make.left.equalTo(self.view.mas_centerX).offset(20);
        }];
    }
}

#pragma mark - Public Method


#pragma mark - Event response
// button、gesture, etc

- (void)refuseButtonAction:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)consentButtonAction:(UIButton *)sender
{
    NSDictionary * params = @{@"deviceNumber":[[FSDeviceManager sharedInstance] getDeviceID]};
    [FSNetWorkManager requestWithType:HttpRequestTypeGet
                        withUrlString:kApiCheckAgreement
                        withParaments:params
                     withSuccessBlock:^(NSDictionary *object) {
                         
                         if (NetResponseCheckStaus)
                         {
                             [self continueLoginFlowWithData:self.loginResponseData];
                         }
                         else
                         {
                             [ShowHUDTool showBriefAlert:NetResponseMessage];
                         }
                     } withFailureBlock:^(NSError *error) {
                         [ShowHUDTool showBriefAlert:NetRequestFailed];
                     }];
}

#pragma mark - Private methods

- (void)continueLoginFlowWithData:(NSDictionary *)object
{
    // 处理后续的登录
//    NSInteger treasureCount = [[object objectForKey:@"shop"] integerValue];
//    [[BHUserModel sharedInstance] analysisUserInfoWithDictionary:object Mobile:self.mobile Passwd:self.password Token:self.token];
//
//    // 设置Jpush 别名
//    [JPUSHService setAlias:[BHUserModel sharedInstance].userID completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
//    } seq:0];
    
//    // 判断探针的数量，等于0执行绑定操作，大于0进入到首页
//    if (treasureCount == 0)
//    {
//        BHBindStoreViewController * bindVC = [[BHBindStoreViewController alloc] init];
//        bindVC.type = BHBindStoreChannelTypeLogin;
//        [self.navigationController pushViewController:bindVC animated:YES];
//    }
//    else
//    {
        [[FSLaunchManager sharedInstance] launchWindowWithType:LaunchWindowTypeMain];
        
//        // 处理推送消息 和 deeplink 消息
//        NSDictionary * pushInfo = [[NSUserDefaults standardUserDefaults] objectForKey:kPushInfoUserDefault];
//        NSURL        * url = [[NSUserDefaults standardUserDefaults] objectForKey:kDeepLinkInfoUserDefault];
//        if (kDictNotNull(pushInfo))
//        {
//            [[FSPushManager sharedInstance] handingPushNotificationDictionary: pushInfo];
//            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kPushInfoUserDefault];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//        }
//        else if (url != nil)
//        {
//            [[FSDeepLinkManager sharedInstance] handingOpenUrl:url];
//            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kDeepLinkInfoUserDefault];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//        }
//    }
}

// 判断是否允许跳转页面，即是否要进行拦截
- (BOOL)shouldStartLoadWithRequest:(NSURLRequest *)request
{
    [super shouldStartLoadWithRequest:request];
    if ([request.URL.host hasSuffix:@"behe.com"])
    {
        return YES;
    }
    return YES;
}

#pragma mark - Getters and Setters
// initialize views here, etc

- (UIView *)lineView
{
    if (!_lineView)
    {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = UIColorFromRGB(0xE2E1E6);
    }
    return _lineView;
}
- (UILabel *)remindLabel
{
    if (!_remindLabel)
    {
        _remindLabel = [[UILabel alloc] init];
        _remindLabel.backgroundColor = UIColorFromRGB(0xFEC880);
        _remindLabel.text = @"当您同意新版用户服务协议后才可使用系统，请知悉";
        _remindLabel.textColor = UIColorFromRGB(0xffffff);
        _remindLabel.textAlignment = NSTextAlignmentCenter;
        _remindLabel.font = [UIFont systemFontOfSize:14];
    }
    return _remindLabel;
}
- (UIButton *)refuseButton
{
    if (!_refuseButton)
    {
        _refuseButton = [[UIButton alloc] init];
        _refuseButton.backgroundColor = UIColorFromRGB(0xFFFFFF);
        _refuseButton.layer.borderColor = UIColorFromRGB(0xE2E1E6).CGColor;
        _refuseButton.layer.borderWidth = 1;
        _refuseButton.layer.cornerRadius = 2;
        _refuseButton.clipsToBounds = YES;
        _refuseButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_refuseButton setTitle:@"拒绝" forState:UIControlStateNormal];
        [_refuseButton setTitleColor:UIColorFromRGB(0x96A4B3) forState:UIControlStateNormal];
        [_refuseButton addTarget:self action:@selector(refuseButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _refuseButton;
}
- (UIButton *)consentButton
{
    if (!_consentButton)
    {
        _consentButton = [[UIButton alloc] init];
        _consentButton.backgroundColor = UIColorBlue;
        _consentButton.layer.borderColor = UIColorFromRGB(0xE2E1E6).CGColor;
        _consentButton.layer.borderWidth = 1;
        _consentButton.layer.cornerRadius = 2;
        _consentButton.clipsToBounds = YES;
        _consentButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_consentButton setTitle:@"同意" forState:UIControlStateNormal];
        [_consentButton setTitleColor:UIColorFromRGB(0xFFFFFF) forState:UIControlStateNormal];
        [_consentButton addTarget:self action:@selector(consentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _consentButton;
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
