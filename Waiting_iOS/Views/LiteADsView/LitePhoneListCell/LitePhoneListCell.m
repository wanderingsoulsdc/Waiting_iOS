//
//  LitePhoneListCell.m
//  Waiting_iOS
//
//  Created by wander on 2018/7/23.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LitePhoneListCell.h"
#import <Masonry/Masonry.h>

@interface LitePhoneListCell ()

@property (nonatomic, strong) UIImageView * headImageView;
@property (nonatomic, strong) UIImageView * headSignImageView;

@property (nonatomic, strong) UILabel     * phoneLabel;
@property (nonatomic, strong) UILabel     * markLabel;

@property (nonatomic, strong) UIImageView * rightImageView;

@end

@implementation LitePhoneListCell
{
    BOOL _isCreated;
    
    LiteADsPhoneListModel * _model;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

#pragma mark - Config Cell's Data

- (void)configWithData:(LiteADsPhoneListModel *)model
{
    _model = model;
    
    [self lazyCreateUI];
    
    self.phoneLabel.text = model.phone;
    
    //1有意向，2黑名单，3未接通， 4空号 ，5无标记, 6无意向
    int markStatus = [model.mark intValue];
    
    switch (markStatus) {
        case 0:
            self.headSignImageView.hidden = YES;
            self.markLabel.backgroundColor = UIColorClearColor;
            self.markLabel.text = @"";
            break;
        case 1: //有意向
            self.headSignImageView.hidden = NO;
            self.markLabel.backgroundColor = UIColorFromRGB(0x5ED7BC);
            self.markLabel.text = @"有意向";
            break;
        case 2:
            break;
        case 3: //未接通
            self.headSignImageView.hidden = NO;
            self.markLabel.backgroundColor = UIColorFromRGB(0x4895F2);
            self.markLabel.text = @"未接通";
            break;
        case 4: //空号
            self.headSignImageView.hidden = NO;
            self.markLabel.backgroundColor = UIColorError;
            self.markLabel.text = @"空号";
            break;
        case 5: //无标记
            self.headSignImageView.hidden = NO;
            self.markLabel.backgroundColor = UIColorClearColor;
            self.markLabel.text = @"";
            break;
        case 6: //无意向
            self.headSignImageView.hidden = NO;
            self.markLabel.backgroundColor = UIColorAlert;
            self.markLabel.text = @"无意向";
            break;
        default:
            break;
    }
    // layoutSubviews
    [self layoutSubviewsUI];
}

- (void)lazyCreateUI
{
    if (_isCreated == YES)  return;
    // createUI
    self.contentView.backgroundColor = UIColorWhite;
    
    [self.contentView addSubview:self.headImageView];
    [self.contentView addSubview:self.phoneLabel];
    [self.contentView addSubview:self.markLabel];
    [self.contentView addSubview:self.headSignImageView];
    [self.contentView addSubview:self.rightImageView];
    
    _isCreated = YES;
}

- (void)layoutSubviewsUI
{
    [self.headImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(15);
        make.top.equalTo(self).offset(12);
        make.bottom.equalTo(self).offset(-12);
        make.width.equalTo(self.headImageView.mas_height);
    }];
    
    [self.headSignImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.headImageView.mas_right);
        make.bottom.equalTo(self.headImageView.mas_bottom);
        make.height.equalTo(self.headImageView.mas_height).multipliedBy(3.0/10.0);
        make.width.equalTo(self.headImageView.mas_width).multipliedBy(3.0/10.0);
    }];
    
    [self.phoneLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headImageView.mas_right).offset(12);
        make.top.equalTo(self.headImageView);
        make.height.equalTo(self.headImageView.mas_height);
        make.width.equalTo(@110);
    }];
    
    [self.markLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.phoneLabel.mas_centerY);
        make.left.equalTo(self.phoneLabel.mas_right).offset(0);
        make.height.equalTo(self.headImageView.mas_height).multipliedBy(1.0/3.0);
        make.width.equalTo(@50);
    }];
    
    [self.rightImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-15);
        make.centerY.equalTo(self);
        make.height.equalTo(@10);
        make.width.equalTo(self.rightImageView.mas_height).multipliedBy(7.0/12.0);
    }];
    
}

#pragma mark - Get

- (UIImageView *)headImageView
{
    if (!_headImageView)
    {
        _headImageView = [[UIImageView alloc] init];
        _headImageView.image = [UIImage imageNamed:@"phone_default_head"];
        _headImageView.contentMode = UIViewContentModeScaleToFill;
    }
    return _headImageView;
}

- (UIImageView *)headSignImageView
{
    if (!_headSignImageView)
    {
        _headSignImageView = [[UIImageView alloc] init];
        _headSignImageView.contentMode = UIViewContentModeScaleToFill;
        _headSignImageView.image = [UIImage imageNamed:@"phone_is_call"];
        _headSignImageView.hidden = YES;
    }
    return _headSignImageView;
}

- (UIImageView *)rightImageView
{
    if (!_rightImageView)
    {
        _rightImageView = [[UIImageView alloc] init];
        _rightImageView.image = [UIImage imageNamed:@"right_arrow_black"];
        _rightImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _rightImageView;
}
- (UILabel *)phoneLabel
{
    if (!_phoneLabel)
    {
        _phoneLabel = [[UILabel alloc] init];
        _phoneLabel.textColor = UIColorDarkBlack;
        _phoneLabel.textAlignment = NSTextAlignmentLeft;
        _phoneLabel.font = [UIFont systemFontOfSize:18];
    }
    return _phoneLabel;
}
- (UILabel *)markLabel
{
    if (!_markLabel)
    {
        _markLabel = [[UILabel alloc] init];
        _markLabel.textAlignment = NSTextAlignmentCenter;
        _markLabel.textColor = UIColorWhite;
        _markLabel.font = [UIFont systemFontOfSize:11];
        _markLabel.layer.cornerRadius = 3.0f;
        _markLabel.layer.masksToBounds = YES;
    }
    return _markLabel;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
