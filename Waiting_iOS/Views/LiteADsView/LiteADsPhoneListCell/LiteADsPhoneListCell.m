//
//  LiteADsPhoneListCell.m
//  Waiting_iOS
//
//  Created by wander on 2018/7/18.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteADsPhoneListCell.h"
#import <Masonry/Masonry.h>

@interface LiteADsPhoneListCell ()

@property (nonatomic, strong) UIImageView * headImageView;
@property (nonatomic, strong) UIImageView * headSignImageView;

@property (nonatomic, strong) UILabel     * phoneLabel;
@property (nonatomic, strong) UILabel     * markLabel;
@property (nonatomic, strong) UILabel     * callTimeLabel;  //计费时长
@property (nonatomic, strong) UILabel     * lastTimeLabel;  //通讯时间

@property (nonatomic, strong) UIImageView * rightImageView;

@end

@implementation LiteADsPhoneListCell
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

    self.headSignImageView.image = [UIImage imageNamed:@"phone_is_call"];
    self.phoneLabel.text = model.phone;
    self.callTimeLabel.text = [NSString stringWithFormat:@"计费时长%@分钟",model.talkTime];
    if (IS_IPHONE5) {
        self.lastTimeLabel.text = [NSString stringWithFormat:@"%@ ",model.startTime];
    }else{
        self.lastTimeLabel.text = [NSString stringWithFormat:@"通讯时间 %@ ",model.startTime];
    }
    //1有意向，2黑名单，3未接通， 4空号 ，5无标记, 6无意向
    int markStatus = [model.mark intValue];

    switch (markStatus) {
        case 0:
            break;
        case 1: //有意向
            self.markLabel.backgroundColor = UIColorFromRGB(0x5ED7BC);
            self.markLabel.text = @"有意向";
            break;
        case 2:
            break;
        case 3: //未接通
            self.markLabel.backgroundColor = UIColorFromRGB(0x4895F2);
            self.markLabel.text = @"未接通";
            break;
        case 4: //空号
            self.markLabel.backgroundColor = UIColorError;
            self.markLabel.text = @"空号";
            break;
        case 5: //无标记
            self.markLabel.backgroundColor = UIColorClearColor;
            self.markLabel.text = @"";
            break;
        case 6: //无意向
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
    [self.contentView addSubview:self.callTimeLabel];
    [self.contentView addSubview:self.lastTimeLabel];
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
        make.height.equalTo(self.headImageView.mas_height).multipliedBy(1.0/2.0);
        make.width.equalTo(@110);
    }];
        
    [self.markLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.phoneLabel.mas_centerY);
        make.left.equalTo(self.phoneLabel.mas_right).offset(0);
        make.height.equalTo(self.headImageView.mas_height).multipliedBy(1.0/3.0);
        make.width.equalTo(@50);
    }];
        
    [self.callTimeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.phoneLabel);
        make.top.equalTo(self.phoneLabel.mas_bottom);
        make.height.equalTo(self.phoneLabel.mas_height);
        make.width.greaterThanOrEqualTo(@90);
    }];
    
    [self.lastTimeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.phoneLabel.mas_bottom);
        make.height.equalTo(self.phoneLabel.mas_height);
        make.right.equalTo(self).offset(-35);
        make.width.greaterThanOrEqualTo(@180);
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
        _phoneLabel.textColor = UIColorDrakBlackText;
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

- (UILabel *)callTimeLabel
{
    if (!_callTimeLabel)
    {
        _callTimeLabel = [[UILabel alloc] init];
        _callTimeLabel.textColor = UIColorFromRGB(0x797E81);
        _callTimeLabel.textAlignment = NSTextAlignmentLeft;
        _callTimeLabel.font = [UIFont systemFontOfSize:12];
    }
    return _callTimeLabel;
}

- (UILabel *)lastTimeLabel
{
    if (!_lastTimeLabel)
    {
        _lastTimeLabel = [[UILabel alloc] init];
        _lastTimeLabel.textColor = UIColorFromRGB(0x797E81);
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
