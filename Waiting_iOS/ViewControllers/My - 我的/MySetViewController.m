//
//  MySetViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/8/28.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "MySetViewController.h"
#import "FSNetWorkManager.h"
#import "BHUserModel.h"
#import "WTWebViewController.h"
#import "WTLanguageViewController.h"

@interface MySetViewController ()

@property (weak , nonatomic) IBOutlet UILabel * titleLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint * topViewTopConstraint; //顶部视图 距上约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * logoutButtonBottomConstraint; //退出登录 距下约束
@property (weak, nonatomic) IBOutlet UILabel * privacyPolicyTitleLabel; //隐私政策title
@property (weak, nonatomic) IBOutlet UILabel * languageTitleLabel; //语言title

@property (weak, nonatomic) IBOutlet UILabel * versionLabel; //版本


@property (weak, nonatomic) IBOutlet UIButton * logoutButton;

@end

@implementation MySetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
#pragma mark - ******* UI Methods *******

- (void)createUI{
    self.topViewTopConstraint.constant = kStatusBarHeight;
    self.logoutButtonBottomConstraint.constant = SafeAreaBottomHeight + 60;
    
    self.logoutButton.layer.borderWidth = 1;
    self.logoutButton.layer.borderColor = UIColorFromRGB(0x9014FC).CGColor;
    
    self.privacyPolicyTitleLabel.text = ZBLocalized(@"Terms of Service", nil);
    self.languageTitleLabel.text = ZBLocalized(@"Language", nil);
    self.versionLabel.text = [NSString stringWithFormat:@"Version %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    
    self.titleLabel.text = ZBLocalized(@"Setting", nil);
    [self.logoutButton setTitle:ZBLocalized(@"Log out", nil) forState:UIControlStateNormal];
}

#pragma mark - ******* Action Methods *******
//隐私政策
- (IBAction)privacyPolicyAction:(UIButton *)sender {
    WTWebViewController *vc = [[WTWebViewController alloc] init];
    vc.url = @"http://app.waitfy.net/h5/about/?id=100002";
    [self.navigationController pushViewController:vc animated:YES];
}
//切换语言
- (IBAction)languageAction:(UIButton *)sender {
    WTLanguageViewController *vc = [[WTLanguageViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}
//退出登录
- (IBAction)logoutAction:(UIButton *)sender {
    [FSNetWorkManager clearCookies];
    [BHUserModel cleanupCache];
    [[NIMSDK sharedSDK].loginManager logout:nil];
    [[FSLaunchManager sharedInstance]launchWindowWithType:LaunchWindowTypeLogin];
}
- (IBAction)backAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

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
