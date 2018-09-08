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

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint * bottomViewHeightConstraint;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bottomViewHeightConstraint.constant = SafeAreaBottomHeight;
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - ******* Action *******

//注册协议
- (IBAction)agreementAction:(UIButton *)sender {
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
             NSDictionary * params = @{@"uid":user.uid,
                                       @"nickname":user.nickname,
                                       @"icon":user.icon,
                                       @"gender":[NSString stringWithFormat:@"%ld",user.gender],
                                       @"email":email,
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
    [ShareSDK getUserInfo:SSDKPlatformTypeFacebook
           onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error)
     {
         if (state == SSDKResponseStateSuccess)
         {
             NSLog(@"uid=%@",user.uid);
             NSLog(@"%@",user.credential);
             NSLog(@"token=%@",user.credential.token);
             NSLog(@"nickname=%@",user.nickname);
             
         }
         
         else
         {
             NSLog(@"%@",error);
         }
         
     }];
}
//google
- (IBAction)googleAction:(UIButton *)sender {
}

#pragma mark - ******* Request *******

- (void)requestLogin:(NSDictionary *)params{
    [FSNetWorkManager requestWithType:HttpRequestTypePost
                        withUrlString:kApiLogin
                        withParaments:params
                     withSuccessBlock:^(NSDictionary *object) {
                            NSLog(@"请求成功");
                            
                            [ShowHUDTool hideAlert];
                            
                            if (NetResponseCheckStaus)
                            {
                                NSString *token = object[@"data"][@"token"];
                                [[BHUserModel sharedInstance] analysisUserInfoWithToken:token];
                                
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
