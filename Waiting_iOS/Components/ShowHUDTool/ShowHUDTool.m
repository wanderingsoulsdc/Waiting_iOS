//
//  ShowHUDTool.m
//  MvBox
//
//  Created by 刘一一 on 14-4-1.
//  Copyright (c) 2014年 51mvbox. All rights reserved.
//

#import "ShowHUDTool.h"
#import "AppDelegate.h"

#define kScreen_height  [[UIScreen mainScreen] bounds].size.height
#define kScreen_width   [[UIScreen mainScreen] bounds].size.width

@interface ShowHUDTool ()<UIGestureRecognizerDelegate>
{
    UITapGestureRecognizer *tap;
    UIView                 *customView;
    BOOL                    customViewHasShow;
}
@end

@implementation ShowHUDTool


#pragma mark - 初始化

- (instancetype)init{
    if (self = [super init]) {
        self.isShowGloomy = YES;
    }
    return self;
}

# pragma mark - 单例

+(instancetype )shareManager {
    static ShowHUDTool * hudManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hudManager = [[self alloc] init];
    });
    return hudManager;
}

#pragma mark - 不隐藏提示语

+ (void)showLoading
{
    [self showLoadingInView:nil];
}
+ (void)showLoadingInView:(UIView *)view
{
    [self showLoadingWithTitle:nil inView:view];
}
+ (void)showLoadingWithTitle:(NSString *)title inView:(UIView *)view
{
    view = view ?: [UIApplication sharedApplication].keyWindow;
    title = title ?: NSLocalizedString(@"Loading", nil);
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
    hud.removeFromSuperViewOnHide = YES;
    if ([ShowHUDTool shareManager].isShowGloomy) {
        hud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
        hud.backgroundView.color = [UIColor colorWithWhite:0.f alpha:0.3f];
    }
    hud.label.text = title;
    [view addSubview:hud];
    [hud showAnimated:YES];
}

#pragma mark - 自动隐藏提示语
+ (void)showBriefAlert:(NSString *)alert;
{
    [self showBriefAlert:alert inView:nil];
}
+ (void)showBriefAlert:(NSString *)alert inView:(UIView *)view
{
    view = view ?: [UIApplication sharedApplication].keyWindow;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = [NSString stringWithFormat:@"%@", alert];
    hud.label.numberOfLines = 0;
    hud.mode = MBProgressHUDModeText;
    hud.bezelView.backgroundColor = [UIColor colorWithRed:1.0/255.0 green:1.0/255.0 blue:1.0/255.0 alpha:0.7];
    hud.label.textColor = [UIColor whiteColor];
    hud.margin = 10.f;
    [hud hideAnimated:YES afterDelay:kShowTime];
}

#pragma mark - 隐藏提示语

+ (void)hideAlert
{
    [self hideAlertInView:nil];
}
+ (void)hideAlertInView:(UIView *)view
{
    view = view ?: [UIApplication sharedApplication].keyWindow;
    
    NSEnumerator *subviewsEnum = [view.subviews reverseObjectEnumerator];
    for (UIView *subview in subviewsEnum) {
        if ([subview isKindOfClass:[MBProgressHUD class]]) {
            MBProgressHUD * hud = (MBProgressHUD *)subview;
            hud.removeFromSuperViewOnHide = YES;
            [hud hideAnimated:YES];
        }
    }
    
//    MBProgressHUD *hud = [self HUDForView:view];
//    if (hud != nil) {
//        hud.removeFromSuperViewOnHide = YES;
//        [hud hideAnimated:YES];
//        return;
//    }
}
+ (MBProgressHUD *)HUDForView:(UIView *)view {
    NSEnumerator *subviewsEnum = [view.subviews reverseObjectEnumerator];
    for (UIView *subview in subviewsEnum) {
        if ([subview isKindOfClass:[MBProgressHUD class]]) {
            return (MBProgressHUD *)subview;
        }
    }
    return nil;
}

#pragma mark - 自定义图片

+ (void)showAlertWithFinishImageWithTitle:(NSString *)title
{
    [self showAlertWithCustomImage:nil title:title];
}
+ (void)showAlertWithCustomImage:(NSString *)imageName title:(NSString *)title
{
    [self showAlertWithCustomImage:imageName title:title inView:nil];
}
+ (void)showAlertWithCustomImage:(NSString *)imageName title:(NSString *)title inView:(UIView *)view
{
    imageName = imageName ?: @"checkmarkHUD";
    view = view ?: [UIApplication sharedApplication].keyWindow;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    UIImageView *littleView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 37, 37)];
    littleView.image = [UIImage imageNamed:imageName];
    hud.customView = littleView;
    hud.removeFromSuperViewOnHide = YES;
    hud.animationType = MBProgressHUDAnimationZoom;
    hud.label.text = title;
    hud.mode = MBProgressHUDModeCustomView;
    [hud hideAnimated:YES afterDelay:kShowTime];
}

+ (void)showPermanentView:(UIView *)showView
{
    [self showPermanentView:showView title:nil];
}
+ (void)showPermanentView:(UIView *)showView title:(NSString *)title
{
    [self showPermanentView:showView title:title inView:nil];
}
+ (void)showPermanentView:(UIView *)showView title:(NSString *)title inView:(UIView *)view
{
    view = view ?: [UIApplication sharedApplication].keyWindow;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:NO];
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = showView;
    hud.removeFromSuperViewOnHide = YES;
//    hud.animationType = MBProgressHUDAnimationFade;
    hud.label.text = title;
    hud.minSize = showView.size;
    if ([ShowHUDTool shareManager].isShowGloomy) {
        hud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
        hud.backgroundView.color = [UIColor colorWithWhite:0.f alpha:0.3f];
    }
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTheHUD:)];
    [view addGestureRecognizer:tap];
    [hud addGestureRecognizer:tap];
}

- (void)showAlertWithCustomImage:(NSString *)imageName title:(NSString *)title message:(NSString *)message{
    if (!customViewHasShow) {
        customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth/2, kScreenWidth/2)];
        customView.layer.cornerRadius = 6;
        customView.layer.masksToBounds = YES;
        customView.backgroundColor = [UIColorBlack colorWithAlphaComponent:0.5];
        customView.center = [UIApplication sharedApplication].keyWindow.center;
        
        CGFloat imageWH = kScreenWidth/6;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageWH, imageWH/2,imageWH, imageWH)];
        imageView.image = [UIImage imageNamed:imageName];
        [customView addSubview:imageView];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, imageWH/2+imageWH+imageWH/4,kScreenWidth/2 , 30)];
        titleLabel.text = title;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = UIColorWhite;
        titleLabel.font = [UIFont systemFontOfSize:19];
        [customView addSubview:titleLabel];
        
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, imageWH/2+imageWH+imageWH/4 + 30 ,kScreenWidth/2 , 20)];
        messageLabel.text = message;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.textColor = UIColorWhite;
        messageLabel.font = [UIFont systemFontOfSize:12];
        [customView addSubview:messageLabel];
        
        [[UIApplication sharedApplication].keyWindow addSubview:customView];
        
        [self performSelector:@selector(hideCustomImageAndTitleAndMessage) withObject:nil afterDelay:1.5f];
        customViewHasShow = YES;
    }
}

- (void)hideCustomImageAndTitleAndMessage{
    [customView removeAllSubviews];
    [customView removeFromSuperview];
    customViewHasShow = NO;
}

+ (void)tapTheHUD:(UITapGestureRecognizer *)gestureRecognizer
{
    MBProgressHUD * hud = (MBProgressHUD *)gestureRecognizer.view;
    [hud hideAnimated:YES];
    [gestureRecognizer removeTarget:nil action:nil];
}

@end
