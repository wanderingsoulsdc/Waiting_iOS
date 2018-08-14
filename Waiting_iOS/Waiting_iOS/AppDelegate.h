//
//  AppDelegate.h
//  Waiting_iOS
//
//  Created by ChenQiuLiang on 2017/6/5.
//  Copyright © 2017年 BEHE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
/**
 * 是否允许转向
 */
@property(nonatomic,assign)BOOL allowRotation;

@end

