//
//  GuideView.h
//  iGanDong
//
//  Created by ChenQiuLiang on 16/8/30.
//  Copyright © 2016年 iGanDong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GuideView : UIView

+ (BOOL)isNeedShowGuideView;

/**
 *  初始化方法
 *
 *  @param imageArray 图片数组，可以为图片名称/图片实例
 *
 *  @return 实例化对象
 */
- (instancetype)fs_initWithImageArray:(NSArray *)imageArray;

@end


/*
 在进入APP后需要展示的页面，添加以下代码
 
 #import "GuideView.h"
 
 #define SharedApp ((AppDelegate*)[[UIApplication sharedApplication] delegate])
 GuideView * guideView = [[GuideView alloc] fs_initWithImageArray:nil];
 [SharedApp.window addSubview:guideView];
 
 */