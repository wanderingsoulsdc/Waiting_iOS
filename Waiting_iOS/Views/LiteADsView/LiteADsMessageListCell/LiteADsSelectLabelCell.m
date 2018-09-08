//
//  LiteADsSelectLabelCell.m
//  Waiting_iOS
//
//  Created by wander on 2018/7/19.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteADsSelectLabelCell.h"
#import <Masonry/Masonry.h>

@interface LiteADsSelectLabelCell ()

@property (nonatomic, strong) UIView        * bgView;

@property (nonatomic, strong) UIButton      * labelButton;
@property (nonatomic, strong) UILabel       * nameLabel;

@property (nonatomic, strong) UILabel       * markLabel;
@property (nonatomic, strong) UILabel       * customNumLabel;

@property (nonatomic, strong) UIButton      * selectButton;

@property (nonatomic, strong) UIView        * lineView;

@end

@implementation LiteADsSelectLabelCell
{
    BOOL _isCreated;
    
    LiteLabelModel * _model;
}

#pragma mark - CreateUI

- (void)lazyCreateUI
{
    if (_isCreated == YES)  return;
    
    // createUI
    self.contentView.backgroundColor = UIColorWhite;
    
    [self.contentView addSubview:self.bgView];
    [self.bgView addSubview:self.labelButton];
    [self.bgView addSubview:self.nameLabel];
    [self.bgView addSubview:self.selectButton];
    [self.bgView addSubview:self.markLabel];
    [self.bgView addSubview:self.customNumLabel];
    [self.bgView addSubview:self.lineView];

    _isCreated = YES;
}

#pragma mark - Config Cell's Data

- (void)configWithData:(LiteLabelModel *)model
{
    _model = model;
    [self lazyCreateUI];
    
    // config subViews with dict
    self.nameLabel.text = model.name;

    switch ([model.status integerValue]) {
        case 1:
        case 2:
            self.markLabel.hidden = NO;
            break;
        case 3:
            self.markLabel.hidden = YES;
            break;
        default:
            self.markLabel.hidden = YES;
            break;
    }
    
    NSString * registerString = [NSString stringWithFormat:@"%@ 人",model.personNum];
    NSString * registerAttributeString = @"人";
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc]initWithString:registerString];
    [mutableAttributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:NSMakeRange(registerString.length - registerAttributeString.length, registerAttributeString.length)];
    self.customNumLabel.attributedText = mutableAttributedString;
    
    [self layoutSubviewsUI];
}

- (void)layoutSubviewsUI
{
    [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self.contentView);
    }];
    //54*60
    [self.labelButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgView).offset(12);
        make.centerY.equalTo(self.bgView);
        make.height.equalTo(@20);
        make.width.equalTo(@17);
    }];
    
    [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.labelButton.mas_right).offset(12);
        make.centerY.equalTo(self.bgView);
        make.height.equalTo(@30);
        make.width.greaterThanOrEqualTo(@50).priorityLow();
    }];
    
    [self.selectButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bgView).offset(-10);
        make.centerY.equalTo(self.bgView);
        make.width.height.equalTo(@16);
    }];
    
    
    [self.customNumLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.selectButton.mas_left).offset(-20);
        make.centerY.equalTo(self.bgView);
        make.width.greaterThanOrEqualTo(@100).priorityHigh();
        make.height.equalTo(@38);
    }];
    
    [self.markLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel.mas_right).offset(12);
        make.right.equalTo(self.customNumLabel.mas_left).offset(-12);
        make.centerY.equalTo(self.bgView);
        make.width.greaterThanOrEqualTo(@70);
        make.height.equalTo(@18);
    }];
    [self.lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.bgView);
        make.height.equalTo(@0.7);
    }];
    
}

#pragma mark - Privite Method

- (void)cellBecomeSelected{
    self.selectButton.selected = YES;
    self.labelButton.selected = YES;
    self.bgView.backgroundColor = UIColorFromRGB(0xDAEAFC);
    self.lineView.backgroundColor = UIColorWhite;
}

- (void)cellBecomeUnselected{
    self.selectButton.selected = NO;
    self.labelButton.selected = NO;
    self.bgView.backgroundColor = UIColorWhite;
    self.lineView.backgroundColor = UIColorFromRGB(0xF4F4F4);
}

#pragma mark - Getter
- (UIView *)bgView
{
    if (!_bgView)
    {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = UIColorWhite;
    }
    return _bgView;
}

- (UILabel *)nameLabel
{
    if (!_nameLabel)
    {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = UIColorDarkBlack;
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.font = [UIFont boldSystemFontOfSize:16];
    }
    return _nameLabel;
}
- (UILabel *)markLabel
{
    if (!_markLabel)
    {
        _markLabel = [[UILabel alloc] init];
        _markLabel.textColor = UIColorFromRGB(0x5ED7BC);
        _markLabel.text = @"正在创建中..";
        _markLabel.textAlignment = NSTextAlignmentLeft;
        _markLabel.font = [UIFont systemFontOfSize:12];
    }
    return _markLabel;
}

- (UIView *)lineView
{
    if (!_lineView)
    {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = UIColorFromRGB(0xF4F4F4);
    }
    return _lineView;
}

- (UILabel *)customNumLabel
{
    if (!_customNumLabel)
    {
        _customNumLabel = [[UILabel alloc] init];
        _customNumLabel.textColor = UIColorDarkBlack;
        _customNumLabel.textAlignment = NSTextAlignmentRight;
        _customNumLabel.numberOfLines = 0;
        _customNumLabel.font = [UIFont systemFontOfSize:20];
    }
    return _customNumLabel;
}

- (UIButton *)labelButton
{
    if (!_labelButton)
    {
        _labelButton = [[UIButton alloc] init];
        [_labelButton setImage:[UIImage imageNamed:@"account_label_image_unselect"] forState:UIControlStateNormal];
        [_labelButton setImage:[UIImage imageNamed:@"account_label_image_select"] forState:UIControlStateSelected];
        _labelButton.userInteractionEnabled = NO;
    }
    return _labelButton;
}

- (UIButton *)selectButton{
    if (!_selectButton) {
        _selectButton = [[UIButton alloc] init];
        [_selectButton setImage:[UIImage imageNamed:@"account_recharge_unselected"] forState:UIControlStateNormal];
        [_selectButton setImage:[UIImage imageNamed:@"account_recharge_selected"] forState:UIControlStateSelected];
        _selectButton.userInteractionEnabled = NO;
    }
    return _selectButton;
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
