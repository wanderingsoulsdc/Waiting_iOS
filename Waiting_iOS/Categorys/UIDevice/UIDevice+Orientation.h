//
//  UIDevice+Orientation.h
//  Waiting_iOS
//
//  Created by ChenQiuLiang on 2018/1/30.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (Orientation)

/**
 * @interfaceOrientation 输入要强制转屏的方向
 */
+ (void)switchNewOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end
