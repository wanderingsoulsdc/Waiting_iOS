//
//  IGDLaunchManager.m
//  iGanDong
//
//  Created by ChenQiuLiang on 16/5/24.
//  Copyright © 2016年 iGanDong. All rights reserved.
//

#import "FSLaunchManager.h"
#import "FSBaseNavigationController.h"

#import "UIImage+category.h"
#import "BHUserModel.h"
//#import "UITabBar+Badge.h"

#import "HomeViewController.h"
#import "LoginViewController.h"
#import "ChatListViewController.h"

@interface FSLaunchManager () <UITabBarControllerDelegate>

@end

@implementation FSLaunchManager

#pragma mark - Public Methods

+ (instancetype)sharedInstance
{
    static FSLaunchManager *launchManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @synchronized(self){
            launchManager = [[self alloc] init];
            [launchManager configNavigationBackItemStyle];
        }
    });
    return launchManager;
}

#pragma mark -
/**
 *  根据类型切换tabbar显示根视图
 *  LaunchWindowTypeLogin 登陆
 *  LaunchWindowTypeMain  主页面
 *  
 */
- (void)launchWindowWithType:(LaunchWindowType)type
{
    switch (type) {
        case LaunchWindowTypeLogin:
        {
            [self launchLoginView];
        }
            break;
        case LaunchWindowTypeMain:
        {   // Tab Bar
//            [self.rootTabBarController launchTabbar];
            [self launchHomeView];
        }
            break;
        case LaunchWindowTypeTest:
        {   //添加设备
            [self launchTest];
        }
            break;
        default:
            break;
    }
}

/**
 *  设置返回按钮样式 & 导航栏标题颜色
 */
- (void)configNavigationBackItemStyle
{
    //标题文字属性
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           UIColorDarkBlack, NSForegroundColorAttributeName, [UIFont systemFontOfSize:17], NSFontAttributeName, nil]];
    
    UINavigationBar * navigationBar = [UINavigationBar appearance];
    // 始终绘制图片原始状态，不使用Tint Color。
    UIImage *image = [[UIImage imageNamed:@"nav_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];;
    navigationBar.backIndicatorImage = image;
    navigationBar.backIndicatorTransitionMaskImage = image;

    UIBarButtonItem *buttonItem = [UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil];
    //将返回按钮的文字position设置不在屏幕上显示
    [buttonItem setBackButtonTitlePositionAdjustment:UIOffsetMake(-500, 0) forBarMetrics:UIBarMetricsDefault];
    
}
/**
 *  获取当前显示的控制器
 */
- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    // 到当前为止，result为当前视图的rootViewController (Tabbar级别)
    
    if ([result isKindOfClass:[UITabBarController class]])
    {
        UITabBarController * tabController = (UITabBarController *)result;
        result = tabController.selectedViewController;
        if ([result isKindOfClass:[UINavigationController class]])
        {
            UINavigationController * navController = (UINavigationController *)result;
            result = navController.topViewController;
        }
    }
    else if ([result isKindOfClass:[UINavigationController class]])
    {
        UINavigationController * navController = (UINavigationController *)result;
        result = navController.topViewController;
    }
    
    return result;
}

#pragma mark - Private Methods
//切换登陆页面
- (void)launchLoginView
{
    LoginViewController * loginViewController = [[LoginViewController alloc] init];
    FSBaseNavigationController * loginNavigationController = [[FSBaseNavigationController alloc] initWithRootViewController:loginViewController];
    SharedApp.window.rootViewController = loginNavigationController;
}

//切换添加设备页面
- (void)launchTest
{
    ChatListViewController * vc = [[ChatListViewController alloc] init];
    FSBaseNavigationController * DeviceAddNavigationController = [[FSBaseNavigationController alloc] initWithRootViewController:vc];
    SharedApp.window.rootViewController = DeviceAddNavigationController;
}

//切换到根页面
- (void)launchHomeView
{
    HomeViewController * homeViewController = [[HomeViewController alloc] init];
    FSBaseNavigationController * homeNavigationController = [[FSBaseNavigationController alloc] initWithRootViewController:homeViewController];
    SharedApp.window.rootViewController = homeNavigationController;
}

//tabbar切换代理方法
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    if ([viewController isEqual:tabBarController.viewControllers[1]]) {
//        UITabBarItem *item = [self.rootTabBarController.tabBar.items objectAtIndex:1];
//        item.title = @"";
        [self.rootTabBarController showCenterItem];
    } else {
        [self.rootTabBarController hideCenterItem];
    }
}

#pragma mark - Getters and Setters

- (FSBaseTabBarController *)rootTabBarController
{
    if (!_rootTabBarController) {
        _rootTabBarController = [[FSBaseTabBarController alloc] init];
        _rootTabBarController.delegate = self;
    }
    return _rootTabBarController;
}

@end
