//
//  BHLoadFailedView.m
//  Treasure
//
//  Created by ChenQiuLiang on 2017/7/21.
//  Copyright © 2017年 BEHE. All rights reserved.
//

#import "BHLoadFailedView.h"

@interface BHLoadFailedView ()

@end

@implementation BHLoadFailedView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addSubview:self.loadFailedImageView];
        [self addSubview:self.loadFailedLabel];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.loadFailedImageView];
        [self addSubview:self.loadFailedLabel];
    }
    return self;
}

#pragma mark - layout

- (void)layoutSubviews
{
    self.loadFailedImageView.frame = CGRectMake(0, 0, 161, 160);
    self.loadFailedImageView.centerX = self.width/2;
    self.loadFailedImageView.centerY = self.height/2 - 62;
    
    self.loadFailedLabel.frame = CGRectMake(0, 0, kScreenWidth, 40);
    self.loadFailedLabel.centerY = self.height/2 + 40;
}

#pragma mark - Get

- (UIImageView *)loadFailedImageView
{
    if (!_loadFailedImageView)
    {
        _loadFailedImageView = [[UIImageView alloc] init];
        _loadFailedImageView.image = [UIImage imageNamed:@"load_failed"];
        _loadFailedImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _loadFailedImageView;
}

- (UILabel *)loadFailedLabel
{
    if (!_loadFailedLabel)
    {
        _loadFailedLabel = [[UILabel alloc] init];
        _loadFailedLabel.text = @"网络异常，请检查网络...\n点击刷新...";
        _loadFailedLabel.textAlignment = NSTextAlignmentCenter;
        _loadFailedLabel.textColor = UIColorGray;
        _loadFailedLabel.numberOfLines = 0;
        _loadFailedLabel.font = [UIFont systemFontOfSize:14];
    }
    return _loadFailedLabel;
}

#pragma mark -

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
