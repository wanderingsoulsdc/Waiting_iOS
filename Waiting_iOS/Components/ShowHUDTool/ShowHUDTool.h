//
//  ShowHUDTool.h
//  MvBox
//
//  Created by 陈秋亮 on 17-1-11.
//  Copyright (c) 2017年. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

static CGFloat const   kShowTime  = 1.5f;

@interface ShowHUDTool : NSObject

/**
 *  是否显示变淡效果，默认为YES，  PS：只为 showPermanentAlert:(NSString *)alert 和 showLoading 方法添加
 */
@property (nonatomic, assign) BOOL isShowGloomy;
/**
 * 单例模式
 */
+(instancetype )shareManager;

#pragma mark - 不隐藏提示语

/**
 *  显示“加载中”，待圈圈，若要修改直接修改kLoadingMessage的值即可
 */
+ (void)showLoading;
/**
 *  显示网络加载到view上
 *
 *  @param view 要添加到的view
 */
+ (void)showLoadingInView:(UIView *)view;
/**
 *  显示网络加载到view上
 *
 *  @param title 要显示的文字
 *  @param view 要添加到的view
 */
+ (void)showLoadingWithTitle:(NSString *)title inView:(UIView *)view;


#pragma mark - 自动隐藏提示语
/**
 *  显示简短的提示语，默认1.5秒钟，时间可直接修改kShowTime
 *
 *  @param alert 提示信息
 */
+ (void)showBriefAlert:(NSString *)alert;
/**
 *  显示简短提示语到view上
 *
 *  @param alert   提示语
 *  @param view    要添加到的view
 */
+ (void)showBriefAlert:(NSString *)alert inView:(UIView *)view;


#pragma mark - 隐藏提示语

/**
 *  隐藏keyWindow上的alert
 */
+ (void)hideAlert;
/**
 *  隐藏alert
 */
+ (void)hideAlertInView:(UIView *)view;

#pragma mark - 自定义图片

/**
 *  自定义加载视图接口，显示对勾图片
 *
 *  @param title 要显示的提示文字
 */
+ (void)showAlertWithFinishImageWithTitle:(NSString *)title;
/**
 *  自定义加载视图接口，支持自定义图片
 *
 *  @param imageName  要显示的图片，最好是37 x 37大小的图片
 *  @param title 要显示的提示文字
 */
+ (void)showAlertWithCustomImage:(NSString *)imageName title:(NSString *)title;
/**
 *  自定义加载视图接口，支持自定义图片
 *
 *  @param imageName  要显示的图片，最好是37 x 37大小的图片
 *  @param title 要显示的提示文字
 *  @param view 要把提示框添加到的view
 */
+ (void)showAlertWithCustomImage:(NSString *)imageName title:(NSString *)title inView:(UIView *)view;

/**
 *  自定义加载视图接口，支持自定义View
 *
 *  @param showView  要显示的view
 */
+ (void)showPermanentView:(UIView *)showView;
/**
 *  自定义加载视图接口，支持自定义View
 *
 *  @param showView  要显示的view
 */
+ (void)showPermanentView:(UIView *)showView title:(NSString *)title;
/**
 *  自定义加载视图接口，支持自定义View
 *
 *  @param showView  要显示的view
 *  @param view 要把提示框添加到的view
 */
+ (void)showPermanentView:(UIView *)showView title:(NSString *)title inView:(UIView *)view;

/**
 *  自定义加载自定义图片视图接口
 *
 *  @param imageName  要显示的图片
 *  @param title 要显示的提示文字
 *  @param message 要显示的副文字
 */

- (void)showAlertWithCustomImage:(NSString *)imageName title:(NSString *)title message:(NSString *)message;


@end
