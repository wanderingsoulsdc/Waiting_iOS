//
//  UIControl+repeat.h
//  iGanDong
//
//  Created by ChenQiuLiang on 16/5/26.
//  Copyright © 2016年 iGanDong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UIControlRepeatProtocal <NSObject>

@end

@interface UIControl (repeat)

// 可以用这个给重复点击加间隔，且需遵从协议
@property (nonatomic, assign) NSTimeInterval uxy_acceptEventInterval;
@property (nonatomic, assign) NSTimeInterval uxy_acceptedEventTime;

@end


// demo
// button.uxy_acceptEventInterval = 2;  2秒内重复点击无效