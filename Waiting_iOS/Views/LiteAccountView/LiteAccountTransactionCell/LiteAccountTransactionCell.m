//
//  LiteAccountTransactionCell.m
//  Waiting_iOS
//
//  Created by wander on 2018/6/21.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteAccountTransactionCell.h"
#import <Masonry/Masonry.h>

@interface LiteAccountTransactionCell ()

@property (nonatomic, strong) UILabel     * titleLabel;
@property (nonatomic, strong) UILabel     * timeLabel;
@property (nonatomic, strong) UILabel     * markLabel;
@property (nonatomic, strong) UILabel     * moneyLabel;

@end

@implementation LiteAccountTransactionCell
{
    BOOL _isCreated;
    
    LiteAccountTransactionModel * _model;
}

#pragma mark - CreateUI

- (void)lazyCreateUI
{
    if (_isCreated == YES)  return;
    
    // createUI
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.markLabel];
    [self.contentView addSubview:self.moneyLabel];
    
    _isCreated = YES;
}

#pragma mark - Config Cell's Data

- (void)configWithData:(LiteAccountTransactionModel *)model
{
    _model = model;
    [self lazyCreateUI];
    
    if (self.type == TransactionCellTypeRecharge) {
        self.markLabel.hidden = NO;
        self.markLabel.text = @"充值成功";
    }
    
    self.titleLabel.text = model.transactionTitle;
    self.timeLabel.text = model.transactionTime;
    self.moneyLabel.text = model.transactionMoney;
    
    // layoutSubviews
    [self layoutSubviewsUI];
}

- (void)layoutSubviewsUI
{
    
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(14);
        make.left.equalTo(self).offset(15);
        make.height.equalTo(@20);
        make.width.greaterThanOrEqualTo(@40);
    }];
    
    [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom);
        make.left.equalTo(self).offset(15);
        make.height.equalTo(@20);
        make.width.greaterThanOrEqualTo(@120);
    }];
    [self.markLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom);
        make.left.equalTo(self.timeLabel.mas_right).offset(10);
        make.height.equalTo(@20);
        make.width.greaterThanOrEqualTo(@40);
    }];
    [self.moneyLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-15);
        make.centerY.equalTo(self);
        make.height.equalTo(@40);
        make.width.greaterThanOrEqualTo(@40);
    }];
}

#pragma mark - Get

- (UILabel *)titleLabel
{
    if (!_titleLabel)
    {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = UIColorDarkBlack;
        _titleLabel.text = @"烧开后翻滚吧我看了广播网别怪我了";
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.backgroundColor = [UIColor clearColor];
    }
    return _titleLabel;
}

- (UILabel *)timeLabel
{
    if (!_timeLabel)
    {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textColor = UIColorFromRGB(0x797E81);
        _timeLabel.text = @"2018.05.50 13:14:50";
        _timeLabel.textAlignment = NSTextAlignmentLeft;
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.backgroundColor = [UIColor clearColor];
    }
    return _timeLabel;
}

- (UILabel *)markLabel
{
    if (!_markLabel)
    {
        _markLabel = [[UILabel alloc] init];
        _markLabel.textColor = UIColorFromRGB(0x5ED7BC);
        _markLabel.text = @"充值成功";
        _markLabel.textAlignment = NSTextAlignmentLeft;
        _markLabel.font = [UIFont systemFontOfSize:12];
        _markLabel.backgroundColor = [UIColor clearColor];
        _markLabel.hidden = YES;
    }
    return _markLabel;
}

- (UILabel *)moneyLabel
{
    if (!_moneyLabel)
    {
        _moneyLabel = [[UILabel alloc] init];
        _moneyLabel.textColor = UIColorBlue;
        _moneyLabel.text = @"223.85";
        _moneyLabel.textAlignment = NSTextAlignmentRight;
        _moneyLabel.font = [UIFont systemFontOfSize:24];
        _moneyLabel.backgroundColor = [UIColor clearColor];
    }
    return _moneyLabel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
