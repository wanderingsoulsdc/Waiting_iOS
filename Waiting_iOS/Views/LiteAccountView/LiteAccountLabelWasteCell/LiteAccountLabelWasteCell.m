//
//  LiteAccountLabelWasteCell.m
//  Waiting_iOS
//
//  Created by wander on 2018/6/24.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteAccountLabelWasteCell.h"
#import <Masonry/Masonry.h>

@interface LiteAccountLabelWasteCell ()

@property (nonatomic, strong) UIView        * bgView;
@property (nonatomic, strong) UIView        * topView;
@property (nonatomic, strong) UIView        * lineView;
@property (nonatomic, strong) UILabel       * nameLabel;
@property (nonatomic, strong) UILabel       * addressLabel;
@property (nonatomic, strong) UILabel       * timeLabel;
@property (nonatomic, strong) UILabel       * customNumLabel;
@property (nonatomic, strong) UILabel       * customTitleLabel;

@property (nonatomic, strong) UIButton      * selectButton;

@property (nonatomic, strong) UIButton      * labelButton;
@property (nonatomic, strong) UIImageView   * locationImageView;

@end

@implementation LiteAccountLabelWasteCell
{
    BOOL _isCreated;
    
    LiteLabelModel * _model;
}

#pragma mark - CreateUI

- (void)lazyCreateUI
{
    if (_isCreated == YES)  return;
    
    // createUI
    self.contentView.backgroundColor = UIColorBackGround;
    
    [self.topView addSubview:self.labelButton];
    [self.topView addSubview:self.nameLabel];
    [self.topView addSubview:self.selectButton];
    [self.bgView addSubview:self.topView];
    
    [self.bgView addSubview:self.lineView];
    [self.bgView addSubview:self.locationImageView];
    [self.bgView addSubview:self.addressLabel];
    [self.bgView addSubview:self.timeLabel];
    [self.bgView addSubview:self.customNumLabel];
    [self.bgView addSubview:self.customTitleLabel];
    [self.contentView addSubview:self.bgView];
    
    _isCreated = YES;
}

#pragma mark - Config Cell's Data

- (void)configWithData:(LiteLabelModel *)model
{
    _model = model;
    [self lazyCreateUI];
    
    // config subViews with dict
    self.nameLabel.text = model.name;
    self.addressLabel.text = model.startAddress;
    self.customNumLabel.text = model.personNum;
    self.timeLabel.text = model.ctime;
    
    [self layoutSubviewsUI];
}

- (void)layoutSubviewsUI
{
    [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self.contentView).offset(10);
        make.right.equalTo(self.contentView).offset(-12);
        make.bottom.equalTo(self.contentView).offset(-2);
    }];
    
    [self.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.right.left.equalTo(self.bgView);
        make.height.equalTo(@44);
    }];
    //54*60
    [self.labelButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.topView).offset(12);
        make.height.equalTo(@20);
        make.width.equalTo(@17);
    }];
    
    [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.labelButton.mas_right).offset(12);
        make.centerY.equalTo(self.topView.mas_centerY);
        make.height.equalTo(@30);
        make.width.greaterThanOrEqualTo(@200);
    }];
    
    [self.selectButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.topView).offset(-10);
        make.centerY.equalTo(self.topView.mas_centerY);
        make.width.height.equalTo(@16);
    }];
    
    [self.lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.bgView);
        make.top.equalTo(self.topView.mas_bottom);
        make.height.equalTo(@1);
    }];
    //30*34
    [self.locationImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgView).offset(12);
        make.top.equalTo(self.lineView.mas_bottom).offset(18);
        make.width.equalTo(@15);
        make.height.equalTo(@17);
    }];
    
    [self.customNumLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bgView).offset(-12);
        make.top.equalTo(self.lineView.mas_bottom).offset(12);
        make.width.greaterThanOrEqualTo(@100);
        make.height.equalTo(@38);
    }];
    [self.customTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bgView).offset(-12);
        make.top.equalTo(self.customNumLabel.mas_bottom).offset(1);
        make.height.equalTo(@18);
        make.width.greaterThanOrEqualTo(@60);
    }];
    
    [self.addressLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.locationImageView.mas_right).offset(12);
        make.centerY.equalTo(self.locationImageView.mas_centerY);
        make.right.equalTo(self.customNumLabel.mas_left);
        make.height.equalTo(@18);
    }];
    
    [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgView).offset(12);
        make.height.equalTo(@18);
        make.bottom.equalTo(self.bgView).offset(-10);
        make.width.greaterThanOrEqualTo(@60);
    }];
}

#pragma mark - Privite Method

- (void)cellBecomeSelected{
    self.selectButton.selected = YES;
    self.labelButton.selected = YES;
    self.lineView.backgroundColor = UIColorWhite;
    self.bgView.backgroundColor = UIColorFromRGB(0xDDEAF9);
    self.timeLabel.textColor = UIColorDarkBlack;
}

- (void)cellBecomeUnselected{
    self.selectButton.selected = NO;
    self.labelButton.selected = NO;
    self.lineView.backgroundColor = UIColorFromRGB(0xF4F4F4);
    self.bgView.backgroundColor = UIColorWhite;
    self.timeLabel.textColor = UIColorlightGray;
}

#pragma mark - Getter

- (UIView *)bgView
{
    if (!_bgView)
    {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = UIColorWhite;
        _bgView.layer.cornerRadius = 4;
        _bgView.clipsToBounds = YES;
    }
    return _bgView;
}
- (UIView *)topView
{
    if (!_topView)
    {
        _topView = [[UIView alloc] init];
        _topView.backgroundColor = UIColorClearColor;
    }
    return _topView;
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
- (UILabel *)addressLabel
{
    if (!_addressLabel)
    {
        _addressLabel = [[UILabel alloc] init];
        _addressLabel.textColor = UIColorDarkBlack;
        _addressLabel.textAlignment = NSTextAlignmentLeft;
        _addressLabel.font = [UIFont systemFontOfSize:12];
    }
    return _addressLabel;
}

- (UILabel *)timeLabel
{
    if (!_timeLabel)
    {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textColor = UIColorlightGray;
        _timeLabel.textAlignment = NSTextAlignmentLeft;
        _timeLabel.numberOfLines = 0;
        _timeLabel.font = [UIFont systemFontOfSize:12];
    }
    return _timeLabel;
}

- (UILabel *)customNumLabel
{
    if (!_customNumLabel)
    {
        _customNumLabel = [[UILabel alloc] init];
        _customNumLabel.textColor = UIColorDarkBlack;
        _customNumLabel.textAlignment = NSTextAlignmentRight;
        _customNumLabel.numberOfLines = 0;
        _customNumLabel.font = [UIFont systemFontOfSize:32];
    }
    return _customNumLabel;
}

- (UILabel *)customTitleLabel
{
    if (!_customTitleLabel)
    {
        _customTitleLabel = [[UILabel alloc] init];
        _customTitleLabel.textColor = UIColorDarkBlack;
        _customTitleLabel.text = @"客户人数";
        _customTitleLabel.textAlignment = NSTextAlignmentRight;
        _customTitleLabel.font = [UIFont systemFontOfSize:12];
    }
    return _customTitleLabel;
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

- (UIImageView *)locationImageView
{
    if (!_locationImageView)
    {
        _locationImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"account_location_image"]];
    }
    return _locationImageView;
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
