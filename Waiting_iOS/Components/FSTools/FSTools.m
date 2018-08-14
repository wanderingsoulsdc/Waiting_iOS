//
//  FSTools.h
//  iPresale
//
//  Created by 陈秋亮 on 17/11/30.
//  Copyright (c) 2017年 YS. All rights reserved.
//

#import "FSTools.h"
@implementation FSTools

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
+ (NSAttributedString *)attributedStringFromString:(NSString *)text color:(UIColor *)color font:(UIFont *)font range:(NSRange)range {
    NSMutableAttributedString * priceAttributeStr = [[NSMutableAttributedString alloc] initWithString:text];
    [priceAttributeStr addAttribute:NSForegroundColorAttributeName value:color range:range];
    [priceAttributeStr addAttribute:NSFontAttributeName value:font range:range];
    return priceAttributeStr;

}



#pragma mark UILabel 大小计算

+ (CGSize)sizeWithText:(NSString *)text Font:(UIFont *)font constrainedToSize:(CGSize)toSize
{
    CGSize size ;
    text = [NSString stringWithFormat:@"%@",text];
    NSStringDrawingOptions option =NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin;
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    
    CGRect rect = [text boundingRectWithSize:toSize options:option attributes:attributes context:nil];
    size = rect.size;
    return size;
}

/**
 *  设置文字高度或者宽度和行间距
 *
 *  @param text       内容
 *  @param font       字体大小
 *  @param toSize     最大size
 *  @param lineHeight 行高
 *
 *  @return size
 */
+ (CGSize)sizeWithText:(NSString *)text Font:(UIFont *)font constrainedToSize:(CGSize)toSize withLineHeight:(float)lineHeight
{
    CGSize size ;
    NSStringDrawingOptions option =NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin;
    NSDictionary *attributes = [NSDictionary dictionary];
    if ([text isEqualToString:@""] == NO && text != nil) {
        NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc]initWithString:text];
        NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        [paragraphStyle setLineSpacing:lineHeight];//调整行间距
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [text length])];
        attributes = @{NSFontAttributeName:font,NSParagraphStyleAttributeName:paragraphStyle};
    }
    
    //dictionaryWithObject:font forKey:NSFontAttributeName];
    
    CGRect rect = [text boundingRectWithSize:toSize options:option attributes:attributes context:nil];
    size = rect.size;
    return size;
}


/**
 阿拉伯数字转中文格式
 @param arebic 阿拉伯数字 eg. 58
 @return 中文数字 eg. 五十八
 */
+(NSString *)ArebicNumberTranslateToChineseNumber:(NSString *)arebic
{
    NSString *str = arebic;
    NSArray *arabic_numerals = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0"];
    NSArray *chinese_numerals = @[@"一",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九",@"零"];
    NSArray *digits = @[@"个",@"十",@"百",@"千",@"万",@"十",@"百",@"千",@"亿",@"十",@"百",@"千",@"兆"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:chinese_numerals forKeys:arabic_numerals];
    
    NSMutableArray *sums = [NSMutableArray array];
    for (int i = 0; i < str.length; i ++) {
        NSString *substr = [str substringWithRange:NSMakeRange(i, 1)];
        NSString *a = [dictionary objectForKey:substr];
        NSString *b = digits[str.length -i-1];
        NSString *sum = [a stringByAppendingString:b];
        if ([a isEqualToString:chinese_numerals[9]])
        {
            if([b isEqualToString:digits[4]] || [b isEqualToString:digits[8]])
            {
                sum = b;
                if ([[sums lastObject] isEqualToString:chinese_numerals[9]])
                {
                    [sums removeLastObject];
                }
            }else
            {
                sum = chinese_numerals[9];
            }
            
            if ([[sums lastObject] isEqualToString:sum])
            {
                continue;
            }
        }
        
        [sums addObject:sum];
    }
    
    NSString *sumStr = [sums componentsJoinedByString:@""];
    NSString *chinese = [sumStr substringToIndex:sumStr.length-1];
    NSLog(@"%@",str);
    NSLog(@"%@",chinese);
    return chinese;
}

@end
