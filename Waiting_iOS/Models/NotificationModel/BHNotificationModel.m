//
//  BHNotificationModel.m
//  Waiting_iOS
//
//  Created by ChenQiuLiang on 2017/11/30.
//Copyright © 2017年 BEHE. All rights reserved.
//

#import "BHNotificationModel.h"
#import "FSTools.h"

@implementation BHNotificationModel

- (CGFloat)cellHeight
{
    CGSize size = [FSTools sizeWithText:self.content Font:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(kScreenWidth - 30, CGFLOAT_MAX) withLineHeight:5];
    return size.height + 100; // 展开以后 计算高度
}

@end
