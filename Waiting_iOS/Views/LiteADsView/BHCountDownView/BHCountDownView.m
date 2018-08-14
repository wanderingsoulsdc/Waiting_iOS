//
//  BHCountDownView.m
//  Treasure
//
//  Created by ChenQiuLiang on 2018/1/9.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "BHCountDownView.h"
#import <Masonry/Masonry.h>

@interface BHCountDownView ()

@property (nonatomic, strong) UIView      * bgView;
@property (nonatomic, strong) UIImageView * circleImageView;
@property (nonatomic, strong) UILabel     * countDownLabel;
@property (nonatomic, strong) UILabel     * titleLabel;
@property (nonatomic, strong) UILabel     * detailLabel;

@end

@implementation BHCountDownView
{
    UIView * _inShowView;
    NSTimer * _timer;
    CGFloat angle;
}

- (void)dealloc
{
    [_timer invalidate];
}

- (id)initWithView:(UIView *)view {
    NSAssert(view, @"View must not be nil.");
    _inShowView = view ? view : [UIApplication sharedApplication].keyWindow;
    return [self initWithFrame:view.bounds];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.bgView];
        [self addSubview:self.circleImageView];
        [self addSubview:self.countDownLabel];
        [self addSubview:self.titleLabel];
        [self addSubview:self.detailLabel];
        [_inShowView addSubview:self];
    }
    return self;
}

#pragma mark - PublicMethod


- (void)show
{
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    self.countDownLabel.text = [NSString stringWithFormat:@"%ld", self.countDownTime];
    self.titleLabel.text = self.title;
    self.detailLabel.text = self.detailTitle;
    [self layoutSubviewsUI];
    
    // 倒计时
    _timer = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(countDownAction:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    
    // 动画
    [self startAnimation];
}

- (void)hidden
{
    [_timer invalidate];
    [self.bgView removeFromSuperview];
    [self.circleImageView removeFromSuperview];
    [self.countDownLabel removeFromSuperview];
    [self.titleLabel removeFromSuperview];
    [self.detailLabel removeFromSuperview];
    [self removeFromSuperview];
}

- (void)countDownAction:(NSTimer *)sender
{
    self.countDownTime -- ;
    self.countDownLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)self.countDownTime];
    
    if (self.countDownTime == 0)
    {
        if ([self.delegate respondsToSelector:@selector(countDownFinish)])
        {
            [self.delegate countDownFinish];
        }
        [sender invalidate];
        [self.bgView removeFromSuperview];
        [self.circleImageView removeFromSuperview];
        [self.countDownLabel removeFromSuperview];
        [self.titleLabel removeFromSuperview];
        [self.detailLabel removeFromSuperview];
        [self removeFromSuperview];
    }
}

#pragma mark - Privite Method

- (void)layoutSubviewsUI
{
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(self);
        make.width.height.equalTo(@260);
    }];
    [self.circleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bgView);
        make.centerY.equalTo(self.bgView).offset(-40);
        make.width.height.equalTo(@80);
    }];
    [self.countDownLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(self.circleImageView);
        make.height.equalTo(@20);
        make.width.equalTo(@40);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.circleImageView.mas_bottom).offset(30);
        make.width.equalTo(self.bgView);
        make.height.equalTo(@20);
    }];
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.width.height.equalTo(self.titleLabel);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(5);
    }];
}

-(void)startAnimation
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.04];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(endAnimation)];
    self.circleImageView.transform = CGAffineTransformMakeRotation(angle * (M_PI / 180.0f));
    [UIView commitAnimations];
}

-(void)endAnimation
{
    angle += 10;
    if (_timer == nil)
    {
        return;
    }
    else
    {
        [self startAnimation];
    }
}

#pragma mark - Get

- (UIView *)bgView
{
    if (!_bgView)
    {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor whiteColor];
        _bgView.layer.cornerRadius = 3;
        _bgView.clipsToBounds = YES;
    }
    return _bgView;
}
- (UIImageView *)circleImageView
{
    if (!_circleImageView)
    {
        _circleImageView = [[UIImageView alloc] init];
        _circleImageView.image = [UIImage imageNamed:@"circle"];
        _circleImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _circleImageView;
}
- (UILabel *)countDownLabel
{
    if (!_countDownLabel)
    {
        _countDownLabel = [[UILabel alloc] init];
        _countDownLabel.font = [UIFont systemFontOfSize:22];
        _countDownLabel.textColor = UIColorBlue;
        _countDownLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _countDownLabel;
}
- (UILabel *)titleLabel
{
    if (!_titleLabel)
    {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
        _titleLabel.textColor = UIColorFromRGB(0x6D8092);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}
- (UILabel *)detailLabel
{
    if (!_detailLabel)
    {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = [UIFont systemFontOfSize:14];
        _detailLabel.textColor = UIColorFromRGB(0x6D8092);
        _detailLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _detailLabel;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
