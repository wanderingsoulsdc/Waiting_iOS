//
//  AppDelegate.m
//  Waiting_iOS
//
//  Created by ChenQiuLiang on 2017/6/5.
//  Copyright © 2017年 BEHE. All rights reserved.
//

#import "AppDelegate.h"
#import "FSLaunchManager.h"
#import "WXApi.h"
#import <AlipaySDK/AlipaySDK.h>
#import "JPUSHService.h"
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
#import <AdSupport/AdSupport.h>
#import <SobotKit/SobotKit.h>
#import "FSNetWorkManager.h"
#import "BHUserModel.h"
#import "BHLoginViewController.h"
#import "FSPushManager.h"
#import "FSDeviceManager.h"
#import "IQKeyboardManager.h"
#import <UMCommon/UMCommon.h>
#import <UMAnalytics/MobClick.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>

@interface AppDelegate () <WXApiDelegate, JPUSHRegisterDelegate,BMKGeneralDelegate>
{
    BMKMapManager* _mapManager;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //Target中设置隐藏状态栏（启动图无状态栏效果），需要在程序启动后取消隐藏。
    [[UIApplication sharedApplication] setStatusBarHidden:NO];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    //初始化百度地图
    [self startSetBaiduMapManager];
    
    // 检查更新
    [self checkVersion];
    
    [self launchWindows];
    
    
    // 向微信注册
    [WXApi registerApp:kWechatAppKey];
    
    // 向JPush注册
//    [self registerJpushWithOption:launchOptions];
//    [application setApplicationIconBadgeNumber:0];
//    [JPUSHService setBadge:0];
    
    // 友盟监测
//    [UMConfigure setEncryptEnabled:YES];
//    [UMConfigure initWithAppkey:UMengAppKey channel:@"App Store"];
//    [MobClick setScenarioType:E_UM_NORMAL];
    
#ifdef RELEASE
    
#else
    [UMConfigure setLogEnabled:YES];
#endif
    
    // 启动键盘自动处理
    [self startWithIQKeyboardManager];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

#pragma mark - 百度地图

- (void)startSetBaiduMapManager{
    // 要使用百度地图，请先启动BaiduMapManager
    _mapManager = [[BMKMapManager alloc]init];
    /**
     *百度地图SDK所有接口均支持百度坐标（BD09）和国测局坐标（GCJ02），用此方法设置您使用的坐标类型.
     *默认是BD09（BMK_COORDTYPE_BD09LL）坐标.
     *如果需要使用GCJ02坐标，需要设置CoordinateType为：BMK_COORDTYPE_COMMON.
     */
    if ([BMKMapManager setCoordinateTypeUsedInBaiduMapSDK:BMK_COORDTYPE_BD09LL]) {
        NSLog(@"经纬度类型设置成功");
    } else {
        NSLog(@"经纬度类型设置失败");
    }
    BOOL ret = [_mapManager start:kBaiduMapKey generalDelegate:self];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
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
    NSString * urlString = [NSString stringWithFormat:@"%@%@", kApiHostPort, kApiGetUserInfo];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    NSURL *userInfoURL = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:userInfoURL];
    
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setTimeoutInterval: 5];
    [request setHTTPMethod:@"GET"];
    //无需参数只需要Header
    [request addValue:token forHTTPHeaderField:@"token"];
    
    NSHTTPURLResponse *response;
    NSError *error = nil;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request
                                               returningResponse:&response
                                                           error:&error];
    
    
    if (error)
    {   // 超时或无网络
        [[FSLaunchManager sharedInstance]launchWindowWithType:LaunchWindowTypeLogin];
        return;
    }
    
    // json解析
    NSDictionary *object = [NSJSONSerialization JSONObjectWithData:returnData
                                                           options:NSJSONReadingAllowFragments
                                                             error:nil];
    if (NetResponseCheckStaus)
    {
        NSLog(@"自动登录成功");
        
        NSString  *deviceNum = @"0";
        NSDictionary *deviceDic = object[@"data"];
        [BHUserModel sharedInstance].deviceNum = [deviceDic stringValueForKey:@"deviceNum" default:@""];
        deviceNum = [deviceDic stringValueForKey:@"deviceNum" default:@""];
        
        if ([deviceNum integerValue] < 1) {
            [[FSLaunchManager sharedInstance] launchWindowWithType:LaunchWindowTypeAddDevice];
        }else{
            [[FSLaunchManager sharedInstance] launchWindowWithType:LaunchWindowTypeMain];
        }
    }
    else
    {
        NSLog(@"%@",NetResponseMessage);
        // 清除登录数据
        [FSNetWorkManager clearCookies];
        [BHUserModel cleanupCache];
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

#pragma mark - 微信支付回调

-(void)onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[PayResp class]]){
        switch (resp.errCode) {
            case WXSuccess:
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kWechatPayResaultNotification object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"9000", @"resultStatus", nil]];
            }
                break;
                
            default:
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kWechatPayResaultNotification object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"7999", @"resultStatus", nil]];
            }
                break;
        }
    }
}

#pragma mark - 

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    if ([url.host isEqualToString:@"luckycat.behe.com"])
    {
        [self handingOpenUrl:url];
    }
    else if ([url.host isEqualToString:@"pay"])
    {
        return  [WXApi handleOpenURL:url delegate:self];
    }
    //如果极简 SDK 不可用,会跳转支付宝钱包进行支付,需要将支付宝钱包的支付结果回传给 SDK
    if ([url.host isEqualToString:@"safepay"]) {
        // 支付跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            [[NSNotificationCenter defaultCenter]postNotificationName:kAliPayResaultNotification object:nil userInfo:resultDic];
        }];
        
        // 授权跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDic) {
            [[NSNotificationCenter defaultCenter]postNotificationName:kAliPayResaultNotification object:nil userInfo:resultDic];
        }];
    }
    return YES;
}
// NOTE: 9.0以后使用新API接口
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    if ([url.host isEqualToString:@"luckycat.behe.com"])
    {
        [self handingOpenUrl:url];
    }
    else if ([url.host isEqualToString:@"pay"])
    {
        return  [WXApi handleOpenURL:url delegate:self];
    }
    //如果极简 SDK 不可用,会跳转支付宝钱包进行支付,需要将支付宝钱包的支付结果回传给 SDK
    if ([url.host isEqualToString:@"safepay"]) {
        // 支付跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            [[NSNotificationCenter defaultCenter]postNotificationName:kAliPayResaultNotification object:nil userInfo:resultDic];
        }];
        
        // 授权跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDic) {
            [[NSNotificationCenter defaultCenter]postNotificationName:kAliPayResaultNotification object:nil userInfo:resultDic];
        }];
    }
    return YES;
}

#pragma mark - Push

- (void)registerJpushWithOption:(NSDictionary *)launchOptions
{
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        // 可以添加自定义categories
        // NSSet<UNNotificationCategory *> *categories for iOS10 or later
        // NSSet<UIUserNotificationCategory *> *categories for iOS8 and iOS9
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    
    NSString *advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
#if TARGET_MODE==0
    [JPUSHService setupWithOption:launchOptions appKey:kJPushAppKey
                          channel:@"App Store"
                 apsForProduction:YES
            advertisingIdentifier:advertisingId];
#else
    [JPUSHService setupWithOption:launchOptions appKey:kJPushAppKey
                          channel:@"App Store"
                 apsForProduction:NO
            advertisingIdentifier:advertisingId];
#endif
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    /// Required - 注册 DeviceToken
//    [JPUSHService registerDeviceToken:deviceToken];
}

#pragma mark - Privite Method

- (void)handingPushNotificationDictionary:(NSDictionary *)userInfo
{
    NSLog(@"11");
    // TODO:判断是否在登录页面
    if ([[[FSLaunchManager sharedInstance] getCurrentVC] isKindOfClass:[BHLoginViewController class]])
    {
        [[NSUserDefaults standardUserDefaults] setObject:userInfo forKey:kPushInfoUserDefault];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        [[FSPushManager sharedInstance] handingPushNotificationDictionary:userInfo];
    }
}

- (void)handingOpenUrl:(NSURL *)url
{
    NSLog(@"11");
    // TODO:判断是否在登录页面
    if ([[[FSLaunchManager sharedInstance] getCurrentVC] isKindOfClass:[BHLoginViewController class]])
    {
        [[NSUserDefaults standardUserDefaults] setObject:url forKey:kDeepLinkInfoUserDefault];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
//        [[FSDeepLinkManager sharedInstance] handingOpenUrl:url];
    }
}

#pragma mark- JPUSHRegisterDelegate

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"iOS10 前台收到远程通知");
        [JPUSHService handleRemoteNotification:userInfo];
    }
    else
    {
        // 判断为本地通知
        NSLog(@"iOS10 前台收到本地通知");
    }
    completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"iOS10 收到远程通知,点击通知消息打开");
        [JPUSHService handleRemoteNotification:userInfo];
        [self handingPushNotificationDictionary:userInfo];
    }
    else {
        // 判断为本地通知
        NSLog(@"iOS10 收到本地通知,点击通知消息打开");
    }
    completionHandler();  // 系统要求执行这个方法
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // Required, iOS 7 Support
    if(application.applicationState == UIApplicationStateInactive)
    {
        [self handingPushNotificationDictionary:userInfo];
    }
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Required,For systems with less than or equal to iOS6
    [JPUSHService handleRemoteNotification:userInfo];
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
