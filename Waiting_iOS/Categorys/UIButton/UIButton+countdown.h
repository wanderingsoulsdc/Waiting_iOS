//
//  UIButton+countdown.h
//  iGanDong
//
//  Created by ChenQiuLiang on 16/5/26.
//  Copyright © 2016年 iGanDong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JxbScaleSetting : NSObject
@property(nonatomic,assign)BOOL         enable;     //倒计时进行中按钮可否点击，默认不能
@property(nonatomic,strong)NSString     *strCommon;//按钮可用时的文本
@property(nonatomic,strong)NSString     *strPrefix;//倒计时前缀
@property(nonatomic,strong)NSString     *strSuffix;//倒计时后缀
@property(nonatomic,strong)NSString     *attributeString;// 倒计时开始后，需要变色的文本
@property(nonatomic,strong)UIColor      *attributeColor;// 倒计时开始后，需要变色的文本的颜色
@property(nonatomic,assign)int          indexStart;//开始从几倒计时
@property(nonatomic,strong)UIColor      *colorDisable;//倒计时的背景颜色
@property(nonatomic,strong)UIColor      *colorCommon;//按钮可用时的背景颜色
@property(nonatomic,strong)UIColor      *colorTitle;//文本可用时的颜色
@property(nonatomic,strong)UIColor      *colorTitleDisable; //文本不可用时的颜色
@property(nonatomic,strong)NSMutableAttributedString *attributedTitle;  // button设置的attributedTitle
@end

@interface UIButton (countdown)

/**
 *  开始倒计时，此时按钮disable
 *
 *  @param setting 设置
 */
- (void)startWithSetting:(JxbScaleSetting*)setting;

/**
 *  移除倒计时
 */

- (void)endSetting;

@end
