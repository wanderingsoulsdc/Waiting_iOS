//
//  BHCountDownView.h
//  Treasure
//
//  Created by ChenQiuLiang on 2018/1/9.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BHCountDownViewDelegate <NSObject>

- (void)countDownFinish;

@end

@interface BHCountDownView : UIView

@property (nonatomic, assign) NSUInteger countDownTime;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * detailTitle;
@property (nonatomic, weak) id<BHCountDownViewDelegate> delegate;

- (instancetype)initWithView:(UIView *)view;    // view一般为self.view或[UIApplication sharedApplication].keyWindow;
- (void)show;   // 10秒后自动隐藏
- (void)hidden; // 主动隐藏


@end
