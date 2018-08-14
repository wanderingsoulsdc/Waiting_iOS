//
//  UIViewController+NavigationItem.m
//  iPresale
//
//  Created by ChenQiuLiang on 15/8/10.
//  Copyright (c) 2015年 YS. All rights reserved.
//

#import "UIViewController+NavigationItem.h"

@implementation UIViewController (NavigationItem)

/* 设置返回按钮的样式 */
- (void)setBackBarButtonItem
{
//    UIBarButtonItem *backBarItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    UIImage *backBarItemImage = [[UIImage imageNamed:@"nav_back"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 25, 0, 0)];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backBarItemImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//    self.navigationItem.backBarButtonItem = backBarItem;
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(NSIntegerMin, NSIntegerMin) forBarMetrics:UIBarMetricsDefault];
}

/*左侧按键*/
- (void)setLeftBarButtonTarget:(id)target Action:(SEL)action Image:(NSString *)image
{
    UIButton *LeftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    LeftBtn.frame = CGRectMake(20, 0, 30, 30);
    if (IOS_VERSION >= 11)
    {
        LeftBtn.frame = CGRectMake(-5, 1, 30, 30);
    }
    //    [LeftBtn setBackgroundImage:[UIImage imageNamed:imgString] forState:UIControlStateNormal];
    //    [LeftBtn setBackgroundImage:[UIImage imageNamed:imgHight] forState:UIControlStateHighlighted];
    [LeftBtn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView * leftImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:image]];
    leftImgView.bounds = CGRectMake(0, 5, 20, 20);
    leftImgView.center = LeftBtn.center;
    [LeftBtn addSubview:leftImgView];
    
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:LeftBtn];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    /**
     *  width为负数时，相当于btn向右移动width数值个像素，由于按钮本身和边界间距为5pix，所以width设为-5时，间距正好调整
     *  为0；width为正数时，正好相反，相当于往左移动width数值个像素
     */
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        negativeSpacer.width = -28;
    }else{
        negativeSpacer.width = -5;
    }
    NSMutableArray *buttonArray= [NSMutableArray arrayWithObjects:negativeSpacer, leftBarItem, nil];
    self.navigationItem.leftBarButtonItems = buttonArray;
}

/*左侧按键*/
- (void)setLeftBarButtonTarget:(id)target Action:(SEL)action Image:(NSString *)image SelectedImage:(NSString *)selectedImage {
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.contentMode = UIViewContentModeScaleAspectFit;
    leftBtn.frame = CGRectMake(0, 0, 20.0, 15.5); // 40*31
    [leftBtn setBackgroundImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [leftBtn setBackgroundImage:[UIImage imageNamed:selectedImage] forState:UIControlStateHighlighted];
    [leftBtn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    
    NSMutableArray *buttonArray= [NSMutableArray arrayWithObjects:negativeSpacer,rightBarItem, nil];
    self.navigationItem.leftBarButtonItems = buttonArray;
}

/*右侧按键*/
- (void)setRightBarButtonTarget:(id)target Action:(SEL)action Image:(NSString *)image SelectedImage:(NSString *)selectedImage {
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.contentMode = UIViewContentModeScaleAspectFit;
    rightBtn.frame = CGRectMake(0, 0, 20, 20); // 40*31
    [rightBtn setBackgroundImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [rightBtn setBackgroundImage:[UIImage imageNamed:selectedImage] forState:UIControlStateHighlighted];
    [rightBtn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    
    NSMutableArray *buttonArray= [NSMutableArray arrayWithObjects:negativeSpacer,rightBarItem, nil];
    self.navigationItem.rightBarButtonItems = buttonArray;
}

/*右侧按键*/
- (void)setRightBarButtonTarget:(id)target Action:(SEL)action Title:(NSString *)title {
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.contentMode = UIViewContentModeScaleAspectFit;
    rightBtn.frame = CGRectMake(0, 0, 40.0, 20); // 40*31
    [rightBtn setTitle:title forState:UIControlStateNormal];
//    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightBtn setTitleColor:UIColorFromRGB(0x96A4B3) forState:UIControlStateNormal];
    rightBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [rightBtn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    
    NSMutableArray *buttonArray= [NSMutableArray arrayWithObjects:negativeSpacer,rightBarItem, nil];
    self.navigationItem.rightBarButtonItems = buttonArray;
}

@end
