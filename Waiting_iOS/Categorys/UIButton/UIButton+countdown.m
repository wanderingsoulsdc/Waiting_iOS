//
//  UIButton+countdown.m
//  iGanDong
//
//  Created by ChenQiuLiang on 16/5/26.
//  Copyright © 2016年 iGanDong. All rights reserved.
//

#import "UIButton+countdown.h"

@implementation JxbScaleSetting
@end

@implementation UIButton (countdown)

- (void)scale:(JxbScaleSetting*)setting {
    self.titleLabel.transform = CGAffineTransformMakeScale(1, 1);
    self.titleLabel.alpha     = 1;
    [self setTitleColor:setting.colorTitle ? setting.colorTitle : [UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitleColor:setting.colorTitleDisable ? setting.colorTitleDisable : [UIColor whiteColor] forState:UIControlStateDisabled];
    if (setting.indexStart > 0)
    {
        self.backgroundColor = setting.colorDisable ? setting.colorDisable : [UIColor lightGrayColor];
        [self setEnabled:setting.enable];
        NSString* title = [NSString stringWithFormat:@"   %@%d%@   ",(setting.strPrefix ? setting.strPrefix : @""),setting.indexStart,(setting.strSuffix ? setting.strSuffix : @"")];
        NSLog(@"%@",title);
        if (setting.attributeString && setting.attributeColor)
        {
            NSString * attrubuteString = [NSString stringWithFormat:@"%d%@", setting.indexStart, setting.attributeString];
            NSRange range = [title rangeOfString:attrubuteString];
            NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc]initWithString:title];
            [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:setting.attributeColor range:range];
            [self setAttributedTitle:mutableAttributedString forState:UIControlStateNormal];
        }
        else
        {
            [self setTitle:title forState:UIControlStateNormal];
        }
        
//        __weak typeof (self) wSelf = self;
//        [UIView animateWithDuration:1 animations:^{
//            self.titleLabel.transform = CGAffineTransformMakeScale(1.2, 1.2);
//            self.titleLabel.alpha     = 0.0;
//        } completion:^(BOOL b){
//            setting.indexStart--;
//            [wSelf scale:setting];
//        }];
        setting.indexStart--;
        [self performSelector:@selector(scale:) withObject:setting afterDelay:1];
    }
    else {
        self.backgroundColor = setting.colorCommon ? setting.colorCommon : [UIColor redColor];
        [self setEnabled:YES];
        if (setting.attributedTitle)
        {
            [self setAttributedTitle:setting.attributedTitle forState:UIControlStateNormal];
        }
        else
        {
            [self setTitle:setting.strCommon forState:UIControlStateNormal];
        }
    }
}

#pragma mark - 启动函数
- (void)startWithSetting:(JxbScaleSetting *)setting {
    [self scale:setting];
}

- (void)endSetting{
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
}

@end
