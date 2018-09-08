//
//  LiteADsMessageListCell.m
//  Waiting_iOS
//
//  Created by wander on 2018/7/18.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteADsMessageListCell.h"
#import <Masonry/Masonry.h>

@interface LiteADsMessageListCell ()

@property (nonatomic, strong) UIImageView * headImageView;

@property (nonatomic, strong) UILabel     * titleLabel;
@property (nonatomic, strong) UILabel     * markLabel;
@property (nonatomic, strong) UILabel     * budgetLabel;  //花费

@property (nonatomic, strong) UIImageView * rightImageView;

@end

@implementation LiteADsMessageListCell
{
    BOOL _isCreated;
    
    LiteADsMessageListModel * _model;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

#pragma mark - Config Cell's Data

- (void)configWithData:(LiteADsMessageListModel *)model
{
    _model = model;
    
    [self lazyCreateUI];
    /*
     "id": 17, //订单id
     "orderName": "推送短信", //短信名称
     "successNum": 0, //成功数
     "budget": "9.00", //短信预算
     "reportSpend": "0.00", //实际花费
     "status": 4 //订单状态 1 发送中，2 发送成功，3 发送失败，4 审核中，5 审核拒绝
     */
    self.titleLabel.text = model.orderName;

    //1 发送中，2 发送成功，3 发送失败，4 审核中，5 审核拒绝
    int markStatus = [model.status intValue];
    
    switch (markStatus) {
        case 1: //发送中
            self.markLabel.textColor = UIColorFromRGB(0x4895F2);
            self.markLabel.text = @"发送中";
            self.budgetLabel.text = [NSString stringWithFormat:@"预扣费 %@",model.budget];
            break;
        case 2: //发送成功
            self.markLabel.textColor = UIColorFromRGB(0x4895F2);
            self.markLabel.text = [NSString stringWithFormat:@"发送成功 %@ 人",model.successNum];
            self.budgetLabel.text = [NSString stringWithFormat:@"实际扣费 %@",model.reportSpend];
            break;
        case 3: //发送失败
            self.markLabel.textColor = UIColorError;
            self.markLabel.text = @"发送失败";
            self.budgetLabel.text = [NSString stringWithFormat:@"预扣费 %@",model.budget];
            break;
        case 4: //审核中
            self.markLabel.textColor = UIColorAlert;
            self.markLabel.text = @"审核中";
            self.budgetLabel.text = [NSString stringWithFormat:@"预扣费 %@",model.budget];
            break;
        case 5: //审核拒绝
            self.markLabel.textColor = UIColorError;
            self.markLabel.text = @"审核拒绝";
            self.budgetLabel.text = [NSString stringWithFormat:@"预扣费 %@",model.budget];
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
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.budgetLabel];
    [self.contentView addSubview:self.markLabel];
    [self.contentView addSubview:self.rightImageView];
    
    _isCreated = YES;
}

- (void)layoutSubviewsUI
{
    [self.headImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(30);
        make.top.equalTo(self).offset(32);
        make.bottom.equalTo(self).offset(-32);
        make.width.equalTo(self.headImageView.mas_height);
    }];
    
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headImageView.mas_right).offset(30);
        make.top.equalTo(self).offset(23);
        make.height.equalTo(@22);
        make.right.equalTo(self).offset(-30);
    }];
    
    [self.budgetLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(4);
        make.height.equalTo(@17);
        make.width.greaterThanOrEqualTo(@90);
    }];
    
    [self.markLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.top.equalTo(self.budgetLabel.mas_bottom).offset(4);
        make.height.equalTo(@17);
        make.width.greaterThanOrEqualTo(@90);
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
        _headImageView.image = [UIImage imageNamed:@"message_default_head"];
        _headImageView.contentMode = UIViewContentModeScaleToFill;
    }
    return _headImageView;
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
- (UILabel *)titleLabel
{
    if (!_titleLabel)
    {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = UIColorDarkBlack;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = [UIFont systemFontOfSize:16];
    }
    return _titleLabel;
}
- (UILabel *)markLabel
{
    if (!_markLabel)
    {
        _markLabel = [[UILabel alloc] init];
        _markLabel.textAlignment = NSTextAlignmentLeft;
        _markLabel.font = [UIFont systemFontOfSize:12];
    }
    return _markLabel;
}

- (UILabel *)budgetLabel
{
    if (!_budgetLabel)
    {
        _budgetLabel = [[UILabel alloc] init];
        _budgetLabel.textColor = UIColorFromRGB(0x797E81);
        _budgetLabel.textAlignment = NSTextAlignmentLeft;
        _budgetLabel.font = [UIFont systemFontOfSize:12];
    }
    return _budgetLabel;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
