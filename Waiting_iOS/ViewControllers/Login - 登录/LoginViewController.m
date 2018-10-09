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


@property (weak, nonatomic) IBOutlet UITextField *textfield;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bottomViewHeightConstraint.constant = SafeAreaBottomHeight;
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
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
             NSDictionary * params = @{@"tuid":user.uid,
                                       @"nickname":user.nickname,
                                       @"icon":user.icon,
                                       @"gender":[NSString stringWithFormat:@"%ld",(long)user.gender],
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
             
             NSString *email = [user.rawData objectForKey:@"email"];
             if (!kStringNotNull(email)) {
                 email = @"";
             }
             NSDictionary * params = @{@"tuid":user.uid,
                                       @"nickname":user.nickname,
                                       @"icon":user.icon,
                                       @"gender":[NSString stringWithFormat:@"%ld",(long)user.gender],
                                       @"email":email,
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
    //假数据
    return;
    NSDictionary * params = @{@"tuid":@"112233445566",
                              @"nickname":@"我是假数据",
                              @"icon":@"https://gss0.baidu.com/-Po3dSag_xI4khGko9WTAnF6hhy/zhidao/pic/item/359b033b5bb5c9ea86b6f4add739b6003af3b333.jpg",
                              @"gender":@"1",
                              @"email":@"",
                              @"type":@"twitter"
                              };
    [self requestLogin:params];
}
//测试登录
- (IBAction)textlogin:(id)sender {
    
    //匹配数字,字母和中文
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^[0-9]+$"];
    
    if (!kStringNotNull(self.textfield.text)) {
        [ShowHUDTool showBriefAlert:@"uid为空"];
        return;
    }else{
        
        if (![predicate evaluateWithObject:self.textfield.text]) {
            [ShowHUDTool showBriefAlert:@"填纯数字uid"];
            return;
        }
        
        if (self.textfield.text.length <8) {
            [ShowHUDTool showBriefAlert:@"8位以上uid"];
            return;
        }
    }
    
    NSDictionary * params = @{@"tuid":self.textfield.text,
                              @"nickname":@"我是假数据",
                              @"icon":@"https://gss0.baidu.com/-Po3dSag_xI4khGko9WTAnF6hhy/zhidao/pic/item/359b033b5bb5c9ea86b6f4add739b6003af3b333.jpg",
                              @"gender":@"1",
                              @"email":@"",
                              @"type":@"twitter"
                              };
    [self requestLogin:params];
}
#pragma mark - ******* Request *******

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
