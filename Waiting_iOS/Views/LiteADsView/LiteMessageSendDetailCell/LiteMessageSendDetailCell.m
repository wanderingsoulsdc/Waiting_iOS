//
//  LiteMessageSendDetailCell.m
//  Waiting_iOS
//
//  Created by wander on 2018/8/1.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteMessageSendDetailCell.h"
#import "Masonry.h"

@interface LiteMessageSendDetailCell ()

@property (nonatomic, strong) UIImageView * headImageView;
@property (nonatomic, strong) UIImageView * headSignImageView;

@property (nonatomic, strong) UILabel     * phoneLabel;
@property (nonatomic, strong) UILabel     * markLabel;

@property (nonatomic, strong) UIImageView * rightImageView;

@end

@implementation LiteMessageSendDetailCell
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
        _rightImageView.hidden = YES;
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
        _markLabel.hidden = YES;
    }
    return _markLabel;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
