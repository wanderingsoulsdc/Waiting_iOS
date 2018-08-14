//
//  LiteAccountInvoiceReportCell.m
//  Waiting_iOS
//
//  Created by wander on 2018/6/21.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteAccountInvoiceReportCell.h"
#import <Masonry/Masonry.h>
#import "FSTools.h"

@interface LiteAccountInvoiceReportCell ()

@property (nonatomic, strong) UIView  * bgView;
@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * moneyLabel;
@property (nonatomic, strong) UILabel * markLabel;
@property (nonatomic, strong) UILabel * timeLabel;


@end

@implementation LiteAccountInvoiceReportCell
{
    BOOL _isCreated;
    
    LiteAccountInvoiceModel * _model;
}

#pragma mark - CreateUI

- (void)lazyCreateUI
{
    if (_isCreated == YES)  return;
    
    // createUI
    self.contentView.backgroundColor = UIColorBackGround;
    [self.bgView addSubview:self.nameLabel];
    [self.bgView addSubview:self.titleLabel];
    [self.bgView addSubview:self.moneyLabel];
    [self.bgView addSubview:self.markLabel];
    [self.bgView addSubview:self.timeLabel];
    [self.contentView addSubview:self.bgView];

    _isCreated = YES;
}

#pragma mark - Config Cell's Data

- (void)configWithData:(LiteAccountInvoiceModel *)model
{
    _model = model;
    [self lazyCreateUI];
    // config subViews with dict
    self.nameLabel.text = [NSString stringWithFormat:@"  %@",model.number];
    self.timeLabel.text = model.mtime;
    self.moneyLabel.text = model.credit;
    //发票处理状态 1 审核中 2 已快递 3 审核拒绝 4 取消申请 5 审核通过

    switch ([model.status integerValue]) {
        case 1:
            self.markLabel.text = @"审核中";
            self.markLabel.textColor = UIColorAlert;
            break;
        case 2:
            self.markLabel.text = @"已寄出";
            self.markLabel.textColor = UIColorFromRGB(0x5ED7BC);
            break;
        case 3:
            self.markLabel.text = @"审核拒绝";
            self.markLabel.textColor = UIColorError;
            break;
        case 4:
            self.markLabel.text = @"已撤销";
            self.markLabel.textColor = UIColorlightGray;
            break;
        case 5:
            self.markLabel.text = @"审核通过";
            self.markLabel.textColor = UIColorBlue;
            break;
    }
    
    [self layoutSubviewsUI];
}

- (void)layoutSubviewsUI
{
    [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self.contentView).offset(12);
        make.right.equalTo(self.contentView).offset(-12);
        make.bottom.equalTo(self.contentView);
    }];
    [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.bgView);
        make.height.equalTo(@38);
    }];
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgView).offset(12);
        make.top.equalTo(self.nameLabel.mas_bottom).offset(10);
        make.width.equalTo(@60);
        make.height.equalTo(@18);
    }];
    [self.moneyLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgView).offset(12);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(1);
        make.bottom.equalTo(self.bgView).offset(-10);
        make.width.greaterThanOrEqualTo(@60);
    }];
    [self.markLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bgView).offset(-12);
        make.top.equalTo(self.nameLabel.mas_bottom).offset(23);
        make.width.greaterThanOrEqualTo(@60);
        make.height.equalTo(@18);
    }];
    [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bgView).offset(-12);
        make.top.equalTo(self.markLabel.mas_bottom).offset(1);
        make.height.equalTo(@18);
        make.width.greaterThanOrEqualTo(@100);
    }];
}

#pragma mark - Privite Method


#pragma mark - Getter

- (UIView *)bgView
{
    if (!_bgView)
    {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = UIColorFromRGB(0xFFFFFF);
        _bgView.layer.cornerRadius = 4;
        _bgView.clipsToBounds = YES;
    }
    return _bgView;
}
- (UILabel *)nameLabel
{
    if (!_nameLabel)
    {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.backgroundColor = UIColorFromRGB(0xE3F0FE);
        _nameLabel.textColor = UIColorDrakBlackText;
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.font = [UIFont boldSystemFontOfSize:18];
    }
    return _nameLabel;
}
- (UILabel *)titleLabel
{
    if (!_titleLabel)
    {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = UIColorDrakBlackText;
        _titleLabel.text = @"发票金额";
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = [UIFont systemFontOfSize:12];
    }
    return _titleLabel;
}

- (UILabel *)moneyLabel
{
    if (!_moneyLabel)
    {
        _moneyLabel = [[UILabel alloc] init];
        _moneyLabel.textColor = UIColorDrakBlackText;
        _moneyLabel.textAlignment = NSTextAlignmentLeft;
        _moneyLabel.numberOfLines = 0;
        _moneyLabel.font = [UIFont systemFontOfSize:24];
    }
    return _moneyLabel;
}

- (UILabel *)markLabel
{
    if (!_markLabel)
    {
        _markLabel = [[UILabel alloc] init];
        _markLabel.textColor = UIColorFromRGB(0x6D8092);
        _markLabel.textAlignment = NSTextAlignmentRight;
        _markLabel.numberOfLines = 0;
        _markLabel.font = [UIFont systemFontOfSize:12];
    }
    return _markLabel;
}

- (UILabel *)timeLabel
{
    if (!_timeLabel)
    {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textColor = UIColorlightGray;
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.font = [UIFont systemFontOfSize:12];
    }
    return _timeLabel;
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
