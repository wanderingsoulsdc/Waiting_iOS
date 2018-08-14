//
//  FSTools.h
//  iPresale
//
//  Created by 陈秋亮 on 17/11/30.
//  Copyright (c) 2017年 YS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSTools : NSObject
/**
 *  将文字转成部分带颜色的attributedString
 *
 *  @param text  原文字
 *  @param color 字体颜色
 *  @param font 字体大小
 *  @param range 需要换颜色的字体
 *
 *  @return attributedStr
 */
+ (NSAttributedString *)attributedStringFromString:(NSString *)text color:(UIColor *)color font:(UIFont *)font range:(NSRange)range;

// UILabel 大小计算
+ (CGSize)sizeWithText:(NSString *)text Font:(UIFont *)font constrainedToSize:(CGSize)toSize;
+ (CGSize)sizeWithText:(NSString *)text Font:(UIFont *)font constrainedToSize:(CGSize)toSize withLineHeight:(float)lineHeight;

/**
 阿拉伯数字转中文格式
 @param arebic 阿拉伯数字 eg. 58
 @return 中文数字 eg. 五十八
 */
+(NSString *)ArebicNumberTranslateToChineseNumber:(NSString *)arebic;

@end
