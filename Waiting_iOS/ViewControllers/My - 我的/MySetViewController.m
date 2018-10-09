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

@interface MySetViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint * topViewTopConstraint; //顶部视图 距上约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * logoutButtonBottomConstraint; //退出登录 距下约束


@property (weak, nonatomic) IBOutlet UIButton *logoutButton;

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
    self.logoutButtonBottomConstraint.constant = SafeAreaBottomHeight;
    
    self.logoutButton.layer.borderWidth = 1;
    self.logoutButton.layer.borderColor = UIColorFromRGB(0x9014FC).CGColor;
}

#pragma mark - ******* Action Methods *******
//FAQ
- (IBAction)FAQAction:(UIButton *)sender {

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
