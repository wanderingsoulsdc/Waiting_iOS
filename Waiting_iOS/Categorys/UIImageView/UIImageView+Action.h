//
//  UIImageView+Action.h
//  iPresale
//
//  Created by ChenQiuLiang on 15/8/20.
//  Copyright (c) 2015年 YS. All rights reserved.
//



@interface UIImageView (Action)

/**
 *  为图片增加点击事件
 *
 *  @param delegate 响应事件的视图
 *  @param action   响应事件
 */
- (void)touchedInImageViewWithTarget:(id)delegate Action:(SEL)action;

@end
