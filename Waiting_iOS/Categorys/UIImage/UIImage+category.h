//
//  YNIMage+category.h
//  JKAppcationUIKit
//
//  Created by qiyun on 16/6/13.
//  Copyright © 2016年 qiyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage(category)

- (UIImage *)imageCompressWithScaledToSize:(CGSize)size;
- (UIImage *)imageCompressWithScale:(float)scale;
- (UIImage *)getImageWithUnsaturatedPixels;
- (UIImage *)getImageWithTint:(UIColor *)color withIntensity:(float)alpha;
+ (UIImage *)createImageWithColor:(UIColor *)color size:(CGSize)size;
+ (unsigned char *)UIImageToByteArray:(UIImage*)image;

@end
