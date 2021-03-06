//
//  AppDelegate.m
//  Waiting_iOS
//
//  Created by ChenQiuLiang on 2017/6/5.
//  Copyright © 2017年 BEHE. All rights reserved.
//

#import "AppDelegate.h"
#import "FSLaunchManager.h"
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
#import "FSNetWorkManager.h"
#import "BHUserModel.h"
//#import "FSDeviceManager.h"
#import "IQKeyboardManager.h"
#import <UMCommon/UMCommon.h>

#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>

#import "NTESNotificationCenter.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
{
    int             _loginCount; //记录自动登录错误次数
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //Target中设置隐藏状态栏（启动图无状态栏效果），需要在程序启动后取消隐藏。
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[ZBLocalized sharedInstance] initLanguage];//放在tabbar前初始化
    sleep(1);
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    //注册shareSDK
    [self registerShareSDK];
    //注册网易云信
    [self registerNIMSDK];
    
    // 检查更新
    [self checkVersion];
    // 判断显示状态
    [self launchWindows];
    
    // 友盟监测
    [UMConfigure setEncryptEnabled:YES];
    [UMConfigure initWithAppkey:UMengAppKey channel:@"App Store"];
    
#if  TARGET_MODE==0 //正式环境
    
#else
    [UMConfigure setLogEnabled:YES];
#endif
    
    // 启动键盘自动处理
    [self startWithIQKeyboardManager];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

#pragma mark - ******* ShareSDK *******

- (void)registerShareSDK{
    /**初始化ShareSDK应用
     
     @param activePlatforms
     使用的分享平台集合
     @param importHandler (onImport)
     导入回调处理，当某个平台的功能需要依赖原平台提供的SDK支持时，需要在此方法中对原平台SDK进行导入操作
     @param configurationHandler (onConfiguration)
     配置回调处理，在此方法中根据设置的platformType来填充应用配置信息
     */
    [ShareSDK registerActivePlatforms:@[
                                        @(SSDKPlatformTypeFacebook),
                                        @(SSDKPlatformTypeTwitter),
                                        @(SSDKPlatformTypeGooglePlus),
                                        ]
                             onImport:^(SSDKPlatformType platformType)
     {
         
     }
                      onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo)
     {
         
         switch (platformType)
         {
             case SSDKPlatformTypeFacebook:
                 [appInfo SSDKSetupFacebookByApiKey:kFacebookApiKey
                                          appSecret:kFacebookSecretKey
                                        displayName:kFacebookDisplayName
                                           authType:SSDKAuthTypeBoth];
                 break;
             case SSDKPlatformTypeTwitter:
                 [appInfo SSDKSetupTwitterByConsumerKey:kTwitterApiKey
                                         consumerSecret:kTwitterSecretKey
                                            redirectUri:kTwitterRedirectUri];
                 break;
             case SSDKPlatformTypeGooglePlus:
                 [appInfo SSDKSetupGooglePlusByClientID:@"232554794995.apps.googleusercontent.com"
                                           clientSecret:@"PEdFgtrMw97aCvf0joQj7EMk"
                                            redirectUri:@"http://localhost"];
                 break;
             default:
                 break;
         }
     }];
}

#pragma mark - ******* 网易云信 *******

- (void)registerNIMSDK{
    //推荐在程序启动的时候初始化 NIMSDK
    NIMSDKOption *option    = [NIMSDKOption optionWithAppKey:kNIMAppKey];
//    option.apnsCername      = @"your APNs cer name";
//    option.pkCername        = @"your pushkit cer name";
    [[NIMSDK sharedSDK] registerWithOption:option];
    
    //云信是否开启 HTTPS 支持
    NIMServerSetting *setting = [[NIMServerSetting alloc] init];
    setting.httpsEnabled = NO;
    [[NIMSDK sharedSDK] setServerSetting:setting];
    
    //手动登录在登录接口
    
    //注册通知,用来通知被叫响应
    [[NTESNotificationCenter sharedCenter] start];
}
//自动登录NIM
- (void)autoLoginNIM{
    NIMAutoLoginData * autoData = [[NIMAutoLoginData alloc] init];
    autoData.account = [BHUserModel sharedInstance].userID;
    autoData.token = [BHUserModel sharedInstance].token;
    autoData.forcedMode = YES;
    
    [[[NIMSDK sharedSDK] loginManager] autoLogin:autoData];
}

#pragma mark -

- (void)startWithIQKeyboardManager
{
    IQKeyboardManager *keyboardManager = [IQKeyboardManager sharedManager]; // 获取类库的单例变量
    keyboardManager.enable = NO; // 控制整个功能是否启用
    keyboardManager.shouldResignOnTouchOutside = YES; // 控制点击背景是否收起键盘
//    keyboardManager.shouldToolbarUsesTextFieldTintColor = YES; // 控制键盘上的工具条文字颜色是否用户自定义
//    keyboardManager.toolbarManageBehaviour = IQAutoToolbarBySubviews; // 有多个输入框时，可以通过点击Toolbar 上的“前一个”“后一个”按钮来实现移动到不同的输入框
    keyboardManager.enableAutoToolbar = YES; // 控制是否显示键盘上的工具条
    keyboardManager.shouldShowToolbarPlaceholder = NO; // 是否显示占位文字
//    keyboardManager.placeholderFont = [UIFont boldSystemFontOfSize:17]; // 设置占位文字的字体
    keyboardManager.keyboardDistanceFromTextField = 10.0f; // 输入框距离键盘的距离
}

#pragma mark - 自动登录

- (void)launchWindows
{
    _loginCount = 0;
    NSString *token = [BHUserModel sharedInstance].token;
    if (!kStringNotNull(token))
    {
        // 用户未登录
        [[FSLaunchManager sharedInstance] launchWindowWithType:LaunchWindowTypeLogin];
    }
    else
    {
        [self checkToken:[BHUserModel sharedInstance].token];
    }
}

- (void)checkToken:(NSString *)token{
    NSLog(@"开始自动登录");
    // 同步请求
    NSString * urlString = [NSString stringWithFormat:@"%@%@", kApiHostPort, kApiCheckToken];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    NSURL *userInfoURL = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:userInfoURL];
    
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setTimeoutInterval: 5];
    [request setHTTPMethod:@"POST"];
    //无需参数只需要Header
    [request addValue:token forHTTPHeaderField:@"token"];
    
    NSHTTPURLResponse *response;
    NSError *error = nil;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request
                                               returningResponse:&response
                                                           error:&error];
    
    
    if (error)
    {   // 超时或无网络
        if (_loginCount >= 2) { //重试三次
            [[FSLaunchManager sharedInstance]launchWindowWithType:LaunchWindowTypeLogin];
        } else {
            _loginCount ++;
            NSLog(@"自动登录失败重试");
            [self checkToken:token];
        }
        return;
    }
    _loginCount = 0;
    
    // json解析
    NSDictionary *object = [NSJSONSerialization JSONObjectWithData:returnData
                                                           options:NSJSONReadingAllowFragments
                                                             error:nil];
    if (NetResponseCheckStaus)
    {
        NSLog(@"自动登录成功");
        [[FSLaunchManager sharedInstance] launchWindowWithType:LaunchWindowTypeMain];
        [self autoLoginNIM];
    }
    else
    {
        NSLog(@"%@",NetResponseMessage);
        // 清除登录数据
        [FSNetWorkManager clearCookies];
        [BHUserModel cleanupCache];
        [[NIMSDK sharedSDK].loginManager logout:nil];
        [[FSLaunchManager sharedInstance]launchWindowWithType:LaunchWindowTypeLogin];
    }
}

#pragma mark - 检查更新

- (void)checkVersion
{
    return;
    NSString *localVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSDictionary * params = @{@"versionName":localVersion, @"type":@"1"};
    [FSNetWorkManager requestWithType:HttpRequestTypePost
                        withUrlString:kApiCheckVersion
                        withParaments:params
                     withSuccessBlock:^(NSDictionary *object) {
                         // 请求成功
                         if (NetResponseCheckStaus)
                         {
                             // #1 不用更新 #2 选择更新 #3 强制更新
                             NSString * status = object[@"data"][@"status"];
                             if ([status integerValue] == 2)
                             {
                                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"新版本提示"
                                                                                     message:@"发现新版本！\n是否立即更新？"
                                                                                    delegate:self
                                                                           cancelButtonTitle:@"稍后更新"
                                                                           otherButtonTitles:@"立即更新", nil];
                                 [alertView setTag:1234];
                                 [alertView show];
                             }
                             else if ([status integerValue] == 3)
                             {
                                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"新版本提示"
                                                                                     message:@"应用版本有重大升级，请立即更新"
                                                                                    delegate:self
                                                                           cancelButtonTitle:nil
                                                                           otherButtonTitles:@"立即更新", nil];
                                 [alertView setTag:12345];
                                 [alertView show];
                             }
                         }
                     } withFailureBlock:^(NSError *error) {
                         //
                     }];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1234) {
        if (buttonIndex == 0) {
            
        } else if (buttonIndex == 1) {
            NSString *iTunesString = [NSString stringWithFormat:@"https://itunes.apple.com/app/id%@", kAPPID];
            NSURL *iTunesURL = [NSURL URLWithString:iTunesString];
            [[UIApplication sharedApplication] openURL:iTunesURL];
        }
    }
    else if (alertView.tag == 12345)
    {
        NSString *iTunesString = [NSString stringWithFormat:@"https://itunes.apple.com/app/id%@", kAPPID];
        NSURL *iTunesURL = [NSURL URLWithString:iTunesString];
        [[UIApplication sharedApplication] openURL:iTunesURL];
        
        sleep(1);
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"新版本提示"
                                                            message:@"应用版本有重大升级，请立即更新"
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"立即更新", nil];
        [alertView setTag:12345];
        [alertView show];
    }
}

#pragma mark - 

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return YES;
}
// NOTE: 9.0以后使用新API接口
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    return YES;
}

#pragma mark - 横竖屏

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window
{
    if (self.allowRotation == YES) {
        // 允许横屏
        return UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskLandscapeLeft|UIInterfaceOrientationMaskLandscapeRight;
    }else{
        // 只能竖屏
        return UIInterfaceOrientationMaskPortrait;
    }
}

#pragma mark -

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    //实现一个可以后台运行几分钟的权限, 当用户在后台强制退出程序时就会走applicationWillTerminate 了.
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // 程序退出
}


@end
