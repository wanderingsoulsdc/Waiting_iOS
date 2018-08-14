//
//  LiteAlertLabel.h
//  Waiting_iOS
//
//  Created by wander on 2018/6/20.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LiteAlertLabel : UIView
/*
 *  titleLabel  警示文字
 *  属性与正常label相同
 */
@property (nonatomic, strong) UIImageView   *alertImageView;

@property (nonatomic, strong) UILabel       *titleLabel;
//初始化
- (instancetype)initWithFrame:(CGRect)frame;
//重新布局
- (void)layoutSubviews;
/*
 *  alertImageViewHidden 前面红色警告是否隐藏
 *  默认为 NO    即默认显示
 */
- (void)setAlertImageHidden:(BOOL)hidden;
@end
