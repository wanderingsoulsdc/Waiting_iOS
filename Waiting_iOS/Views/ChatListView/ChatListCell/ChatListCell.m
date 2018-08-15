//
//  ChatListCell.m
//  Waiting_iOS
//
//  Created by wander on 2018/8/14.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "ChatListCell.h"
#import <Masonry/Masonry.h>

@interface ChatListCell ()

@property (nonatomic, strong) UIImageView * headImageView;
@property (nonatomic, strong) UILabel     * badgeLabel;

@property (nonatomic, strong) UILabel     * nameLabel;
@property (nonatomic, strong) UILabel     * contentLabel;  //计费时长
@property (nonatomic, strong) UILabel     * lastTimeLabel;  //通讯时间


@end

@implementation ChatListCell
{
    BOOL _isCreated;
    
    ChatListModel * _model;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

#pragma mark - Config Cell's Data

- (void)configWithData:(ChatListModel *)model
{
    _model = model;
    
    [self lazyCreateUI];

    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:model.headImageUrl] placeholderImage:[UIImage imageNamed:@"phone_default_head"]];
    self.nameLabel.text = model.userName;
    self.contentLabel.text = [NSString stringWithFormat:@"计费时长%@分钟",model.content];
    self.lastTimeLabel.text = [NSString stringWithFormat:@"%@ ",model.lastTime];
    self.badgeLabel.text = model.badge;

    // layoutSubviews
    [self layoutSubviewsUI];
}

- (void)lazyCreateUI
{
    if (_isCreated == YES)  return;
    // createUI
    self.contentView.backgroundColor = UIColorWhite;
    
    [self.contentView addSubview:self.headImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.lastTimeLabel];
    [self.contentView addSubview:self.badgeLabel];
    
    _isCreated = YES;
}

- (void)layoutSubviewsUI
{
    [self.headImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(15);
        make.top.equalTo(self).offset(10);
        make.bottom.equalTo(self).offset(-10);
        make.width.equalTo(self.headImageView.mas_height);
    }];
    
    [self.badgeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headImageView.mas_top);
        make.right.equalTo(self.headImageView.mas_right);
        make.height.equalTo(@16);
        make.width.greaterThanOrEqualTo(@16);
    }];
    
    [self.lastTimeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(15);
        make.right.equalTo(self).offset(-15);
        make.height.equalTo(@15);
        make.width.greaterThanOrEqualTo(@60);
    }];
    
    [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headImageView.mas_right).offset(15);
        make.top.equalTo(self).offset(18);
        make.height.equalTo(@18);
        make.right.equalTo(self.lastTimeLabel.mas_left).offset(-10);
    }];
    
    [self.contentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel);
        make.top.equalTo(self.nameLabel.mas_bottom).offset(12);
        make.right.equalTo(self).offset(-60);
        make.height.equalTo(@14);
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

- (UILabel *)nameLabel
{
    if (!_nameLabel)
    {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = UIColorFromRGB(0x333333);
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.font = [UIFont systemFontOfSize:18];
    }
    return _nameLabel;
}
- (UILabel *)badgeLabel
{
    if (!_badgeLabel)
    {
        _badgeLabel = [[UILabel alloc] init];
        _badgeLabel.backgroundColor = UIColorFromRGB(0xFF3E5C);
        _badgeLabel.textAlignment = NSTextAlignmentCenter;
        _badgeLabel.textColor = UIColorWhite;
        _badgeLabel.font = [UIFont systemFontOfSize:9];
        _badgeLabel.layer.cornerRadius = 8.0f;
        _badgeLabel.layer.masksToBounds = YES;
    }
    return _badgeLabel;
}

- (UILabel *)contentLabel
{
    if (!_contentLabel)
    {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.textColor = UIColorFromRGB(0x999999);
        _contentLabel.textAlignment = NSTextAlignmentLeft;
        _contentLabel.font = [UIFont systemFontOfSize:14];
    }
    return _contentLabel;
}

- (UILabel *)lastTimeLabel
{
    if (!_lastTimeLabel)
    {
        _lastTimeLabel = [[UILabel alloc] init];
        _lastTimeLabel.textColor = UIColorFromRGB(0xC8C8C8);
        _lastTimeLabel.textAlignment = NSTextAlignmentRight;
        _lastTimeLabel.font = [UIFont systemFontOfSize:12];
    }
    return _lastTimeLabel;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
