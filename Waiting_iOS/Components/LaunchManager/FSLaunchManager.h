//
//  IGDLaunchManager.h
//  iGanDong
//
//  Created by ChenQiuLiang on 16/5/24.
//  Copyright © 2016年 iGanDong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "FSBaseTabBarController.h"
#import "SliderMenuController.h"

#define SharedApp ((AppDelegate*)[[UIApplication sharedApplication] delegate])

/**
 定义引导类型的枚举
 */
typedef enum : NSUInteger {
    LaunchWindowTypeLogin,
    LaunchWindowTypeMain,
    LaunchWindowTypeTest,
} LaunchWindowType;


@interface FSLaunchManager : NSObject

@property (strong, nonatomic) FSBaseTabBarController * rootTabBarController;
@property (strong, nonatomic) SliderMenuController * slider;

/**
 *  单例方法
 *
 *  @return 实例对象
 */
+ (instancetype)sharedInstance;


/**
 *  主引导方法
 *
 *  @param type 引导类型
 */
-(void)launchWindowWithType:(LaunchWindowType)type;



/**
 *  获取当前屏幕显示的viewcontroller
 */
- (UIViewController *)getCurrentVC;

@end
