//
//  UIViewController+NavigationItem.h
//  iPresale
//
//  Created by ChenQiuLiang on 15/8/10.
//  Copyright (c) 2015年 YS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (NavigationItem)

- (void)setBackBarButtonItem;
- (void)setLeftBarButtonTarget:(id)target Action:(SEL)action Image:(NSString *)image;
- (void)setLeftBarButtonTarget:(id)target Action:(SEL)action Image:(NSString *)image SelectedImage:(NSString *)selectedImage;
- (void)setRightBarButtonTarget:(id)target Action:(SEL)action Image:(NSString *)image SelectedImage:(NSString *)selectedImage;
- (void)setRightBarButtonTarget:(id)target Action:(SEL)action Title:(NSString *)title;

@end
