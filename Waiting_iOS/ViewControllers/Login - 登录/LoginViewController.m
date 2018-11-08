//
//  LoginViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/8/28.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LoginViewController.h"
#import <ShareSDK/ShareSDK.h>
#import "FSNetWorkManager.h"
#import "BHUserModel.h"
#import "WTWebViewController.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint * bottomViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel    * loginTitleLabel; //登录提示文字
@property (weak, nonatomic) IBOutlet UIButton   * registerAgreementButton; //注册协议按钮


@property (weak, nonatomic) IBOutlet UITextField * userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField * passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton    * loginButton;


@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createUI];
    // Do any additional setup after loading the view from its nib.
    [self requestCheckPermission];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}
#pragma mark - ******* UI *******
- (void)createUI{
    self.bottomViewHeightConstraint.constant = SafeAreaBottomHeight;
    self.loginTitleLabel.text = ZBLocalized(@"Join us with", nil);
    [self.registerAgreementButton setTitle:ZBLocalized(@"By continuing you agree to the Terms of Service", nil) forState:UIControlStateNormal];
}

- (void)showUserLogin{
    self.userNameTextField.hidden = NO;
    self.passwordTextField.hidden = NO;
    self.loginButton.hidden = NO;
    self.userNameTextField.placeholder = ZBLocalized(@"UserName", nil);
    self.passwordTextField.placeholder = ZBLocalized(@"Password", nil);
    [self.loginButton setTitle:ZBLocalized(@"Log in", nil) forState:UIControlStateNormal];
}

#pragma mark - ******* Action *******

//注册协议
- (IBAction)agreementAction:(UIButton *)sender {
    WTWebViewController *vc = [[WTWebViewController alloc] init];
    NSString *lang = [[NSUserDefaults standardUserDefaults] objectForKey:AppLanguage];
    vc.url = [NSString stringWithFormat:@"%@%@",@"http://app.waitfy.net/h5/about/?id=100001&lang=",kStringNotNull(lang)?lang:@"en"];
    [self.navigationController pushViewController:vc animated:YES];
}
//twitter
- (IBAction)twitterAction:(UIButton *)sender {
    //twitter的登录
    WEAKSELF
    [ShareSDK getUserInfo:SSDKPlatformTypeTwitter
           onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error)
     {
         if (state == SSDKResponseStateSuccess)
         {
             NSLog(@"uid=%@",user.uid);
             NSLog(@"%@",user.credential);
             NSLog(@"token=%@",user.credential.token);
             NSLog(@"nickname=%@",user.nickname);
             NSLog(@"nickname=%@",user.rawData);

             NSString *email = [user.rawData objectForKey:@"email"];
             if (!kStringNotNull(email)) {
                 email = @"";
             }
             NSDictionary * params = @{@"tuid":user.uid,
                                       @"nickname":user.nickname,
                                       @"photo":user.icon,
                                       @"gender":[NSString stringWithFormat:@"%ld",(long)user.gender],
                                       @"email":email,
                                       @"birthday":@"1990-09-01",
                                       @"type":@"twitter"
                                       };
             [weakSelf requestLogin:params];
         }
         
         else
         {
             NSLog(@"%@",error);
         }
         
     }];
}
//facebook
- (IBAction)facebookAction:(UIButton *)sender {
    WEAKSELF
    [ShareSDK getUserInfo:SSDKPlatformTypeFacebook
           onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error)
     {
         if (state == SSDKResponseStateSuccess)
         {
             NSLog(@"uid=%@",user.uid);
             NSLog(@"%@",user.credential);
             NSLog(@"token=%@",user.credential.token);
             NSLog(@"nickname=%@",user.nickname);
             NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
             [dateFormatter setDateFormat:@"yyyy-MM-dd"];
             NSString *birthdayStr = [dateFormatter stringFromDate:user.birthday];
             NSLog(@"birthday=%@",birthdayStr);

             NSString *email = [user.rawData objectForKey:@"email"];
             if (!kStringNotNull(email)) {
                 email = @"";
             }
             NSDictionary * params = @{@"tuid":user.uid,
                                       @"nickname":user.nickname,
                                       @"photo":user.icon,
                                       @"gender":[NSString stringWithFormat:@"%ld",(long)user.gender],
                                       @"email":email,
                                       @"birthday":birthdayStr,
                                       @"type":@"facebook"
                                       };
             [weakSelf requestLogin:params];
             
         }
         
         else
         {
             NSLog(@"%@",error);
         }
         
     }];
}
//google
- (IBAction)googleAction:(UIButton *)sender {
    return;
}
//测试登录
- (IBAction)textlogin:(id)sender {
    
    //如果用户名或密码不对 就不让进
    //账号：apple
    //密码：apple1234567
   
    NSDictionary * params = @{@"uname":self.userNameTextField.text,
                              @"passwd":self.passwordTextField.text};
    WEAKSELF
    [FSNetWorkManager requestWithType:HttpRequestTypePost
                        withUrlString:kApiPasswordLogin
                        withParaments:params
                     withSuccessBlock:^(NSDictionary *object) {
                         NSLog(@"请求成功");

                         if (NetResponseCheckStaus)
                         {
                             NSString *token = object[@"data"][@"token"];
                             NSString *uid = object[@"data"][@"uid"];
                             [[BHUserModel sharedInstance] analysisUserInfoWithToken:token Uid:uid];

                             [weakSelf loginNIM];
                             [[FSLaunchManager sharedInstance] launchWindowWithType:LaunchWindowTypeMain];
                         }
                         else
                         {
                             [ShowHUDTool showBriefAlert:NetResponseMessage];
                         }
                     } withFailureBlock:^(NSError *error) {
                         NSLog(@"error is %@", error);
                         [ShowHUDTool showBriefAlert:NetRequestFailed];
                     }];
    
}
- (IBAction)superLogin:(UIButton *)sender {
    //自己测试专用
    NSDictionary * params = @{@"tuid":@"9988776655",
                              @"nickname":@"Wander",
                              @"photo":@"",
                              @"gender":@"1",
                              @"email":@"",
                              @"birthday":@"1990-09-01",
                              @"type":@"facebook"
                              };
    [self requestLogin:params];
}
#pragma mark - ******* Request *******
//检查权限
- (void)requestCheckPermission{
    NSString * appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSDictionary *params = @{@"v":appVersion};
    WEAKSELF
    [FSNetWorkManager requestWithType:HttpRequestTypePost
                        withUrlString:kApiCheckPermissions
                        withParaments:params
                     withSuccessBlock:^(NSDictionary *object) {
                         NSLog(@"请求成功");
                         
                         [ShowHUDTool hideAlert];
                         
                         if (NetResponseCheckStaus)
                         {
                             NSDictionary *dataDic = object[@"data"];
                             NSString *audit = [dataDic stringValueForKey:@"audit" default:@""];
                             if (kStringNotNull(audit)) {
                                 if ([audit intValue] == 1) { //开启审核  显示用户名密码 登陆
                                     [weakSelf showUserLogin];
                                 }
                             }
                         }
                         else
                         {
                             [ShowHUDTool showBriefAlert:NetResponseMessage];
                         }
                     } withFailureBlock:^(NSError *error) {
                     }];
}

- (void)requestLogin:(NSDictionary *)params{
    WEAKSELF
    [FSNetWorkManager requestWithType:HttpRequestTypePost
                        withUrlString:kApiLogin
                        withParaments:params
                     withSuccessBlock:^(NSDictionary *object) {
                            NSLog(@"请求成功");
                            
                            [ShowHUDTool hideAlert];
                            
                            if (NetResponseCheckStaus)
                            {
                                NSString *token = object[@"data"][@"token"];
                                NSString *uid = object[@"data"][@"uid"];
                                [[BHUserModel sharedInstance] analysisUserInfoWithToken:token Uid:uid];
                                
                                [weakSelf loginNIM];
                                [[FSLaunchManager sharedInstance] launchWindowWithType:LaunchWindowTypeMain];
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

//手动登录im
- (void)loginNIM{
    //手动登录
    [[[NIMSDK sharedSDK]loginManager] login:[BHUserModel sharedInstance].userID token:[BHUserModel sharedInstance].token completion:^(NSError * _Nullable error) {
        if (!error) {
            NSLog(@"手动登陆成功");
        }else{
            NSLog(@"手动登录错误 = %@",error);
        }
    }];
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
