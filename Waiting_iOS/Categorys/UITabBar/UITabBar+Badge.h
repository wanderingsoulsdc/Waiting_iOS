//
//  UITabBar+Badge.h
//  Waiting_iOS
//
//  Created by ChenQiuLiang on 2017/12/25.
//  Copyright © 2017年 BEHE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBar (Badge)

- (void)showBadgeOnItemIndex:(NSInteger)index;   //显示小红点

- (void)hideBadgeOnItemIndex:(NSInteger)index; //隐藏小红点

@end
