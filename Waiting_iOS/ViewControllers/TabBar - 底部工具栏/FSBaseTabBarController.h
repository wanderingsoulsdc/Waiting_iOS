//
//  FSBaseTabBarController.h
//  
//
//  Created by ChenQiuLiang on 16/5/23.
//  Copyright © 2016年. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSBaseTabBarController : UITabBarController
- (void)pushToViewController:(UIViewController *)viewController animated:(BOOL)animated;

//加载tabbar
- (void)launchTabbar;

//显示中间大按钮
-(void)showCenterItem;
//隐藏中间大按钮
-(void)hideCenterItem;

@end
