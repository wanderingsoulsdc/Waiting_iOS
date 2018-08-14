//
//  LiteAlertLabel.m
//  Waiting_iOS
//
//  Created by wander on 2018/6/20.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteAlertLabel.h"
#import <Masonry/Masonry.h>

@interface LiteAlertLabel ()

@property (nonatomic, assign) BOOL          alertImageViewHidden;

@end

@implementation LiteAlertLabel

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = UIColorFromRGB(0xF5E7E5);
        CALayer * layer=[self layer];
        [layer setCornerRadius:3];          //设置那个圆角
        [layer setBorderWidth:0.8];         //设置边框线的宽
        [layer setBorderColor:[UIColorFromRGB(0xFE4C24) CGColor]];   //设置边框线的颜色
        [layer setMasksToBounds:YES];       //是否设置边框以及是否可见
        
        self.alertImageViewHidden = NO;
        
        [self addSubview:self.alertImageView];
        [self addSubview:self.titleLabel];
        [self layoutSubviews];
    }
    return self;
}

- (void)layoutSubviews {
    
    if (self.alertImageViewHidden) {
        
        self.alertImageView.hidden = self.alertImageViewHidden;
        
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(10);
            make.top.equalTo(self).offset(7);
            make.right.equalTo(self).offset(-10);
            make.bottom.equalTo(self).offset(-7);
        }];
    }else{
        [self.alertImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.width.equalTo(@16);
            make.left.equalTo(self).offset(10);
            make.centerY.equalTo(self);
        }];
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.alertImageView.mas_right).offset(7);
            make.top.equalTo(self).offset(7);
            make.right.equalTo(self).offset(-10);
            make.bottom.equalTo(self).offset(-7);
        }];
    }
    
    
}

- (void)setAlertImageHidden:(BOOL)hidden{
    self.alertImageViewHidden = hidden;
    [self layoutSubviews];
}

#pragma mark - getter

- (UIImageView *)alertImageView{
    if (!_alertImageView)
    {
        _alertImageView = [[UIImageView alloc] init];
        _alertImageView.image = [UIImage imageNamed:@"account_alert_tips"];
        _alertImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _alertImageView;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.textColor = UIColorAlert;
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.backgroundColor = [UIColor clearColor];
    }
    return _titleLabel;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
