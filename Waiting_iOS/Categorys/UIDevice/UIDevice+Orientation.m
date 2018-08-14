//
//  UIDevice+Orientation.m
//  Waiting_iOS
//
//  Created by ChenQiuLiang on 2018/1/30.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "UIDevice+Orientation.h"

@implementation UIDevice (Orientation)

+ (void)switchNewOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    NSNumber * resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
    [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];
    NSNumber * orientationTarget = [NSNumber numberWithInt:interfaceOrientation];
    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
    
}

@end
