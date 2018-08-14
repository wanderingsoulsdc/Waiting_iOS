//
//  LiteDeviceLabelListCell.m
//  Waiting_iOS
//
//  Created by wander on 2018/7/11.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteDeviceLabelListCell.h"
#import <Masonry/Masonry.h>

@interface LiteDeviceLabelListCell ()
@property (nonatomic, strong) UIView        * bgView;
@property (nonatomic, strong) UIView        * topView;
@property (nonatomic, strong) UIView        * lineView;
@property (nonatomic, strong) UILabel       * nameLabel;
@property (nonatomic, strong) UILabel       * addressLabel;
@property (nonatomic, strong) UILabel       * timeLabel;
@property (nonatomic, strong) UILabel       * customNumLabel;
@property (nonatomic, strong) UILabel       * customTitleLabel;

@property (nonatomic, strong) UIImageView   * rightArrowImageView;
@property (nonatomic, strong) UILabel       * rightStatusLabel;

@property (nonatomic, strong) UIButton      * labelButton;
@property (nonatomic, strong) UIImageView   * locationImageView;
@end

@implementation LiteDeviceLabelListCell
{
    BOOL _isCreated;
    
    LiteLabelModel * _model;
}


#pragma mark - ******* Create UI *******

- (void)lazyCreateUI
{
    if (_isCreated == YES)  return;
    
    // createUI
    self.contentView.backgroundColor = UIColorBackGround;
    
    [self.topView addSubview:self.labelButton];
    [self.topView addSubview:self.nameLabel];
    [self.topView addSubview:self.rightArrowImageView];
    [self.topView addSubview:self.rightStatusLabel];
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

#pragma mark - ******* Config Cell's Data *******

- (void)configWithData:(LiteLabelModel *)model
{
    _model = model;
    [self lazyCreateUI];
    
    // config subViews with dict
    self.nameLabel.text = model.name;
    self.addressLabel.text = model.startAddress;
    self.customNumLabel.text = model.personNum;
    self.timeLabel.text = model.ctime;
    //1 收集中 2 暂停 3 结束
    if ([model.status isEqualToString:@"1"]) { //收集中
        self.rightArrowImageView.hidden = YES;
        
        self.rightStatusLabel.hidden = NO;
        self.rightStatusLabel.text = @"正在创建中...";
        self.rightStatusLabel.textColor = UIColorFromRGB(0x5ED7BC);
    } else if ([model.status isEqualToString:@"2"]){  //暂停
        self.rightArrowImageView.hidden = YES;

        self.rightStatusLabel.hidden = NO;
        self.rightStatusLabel.text = @"已暂停创建";
        self.rightStatusLabel.textColor = UIColorAlert;
    } else {  //结束
        self.rightArrowImageView.hidden = NO;
        self.rightStatusLabel.hidden = YES;
    }
    
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
    
    [self.rightArrowImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.topView).offset(-10);
        make.centerY.equalTo(self.topView.mas_centerY);
        make.width.height.equalTo(@12);
    }];
    
    [self.rightStatusLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.topView).offset(-10);
        make.centerY.equalTo(self.topView.mas_centerY);
        make.height.equalTo(self.topView.mas_height);
        make.width.greaterThanOrEqualTo(@100);
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

#pragma mark - ******* Getter *******

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
        _lineView.backgroundColor = UIColorlightGray;
    }
    return _lineView;
}

- (UILabel *)nameLabel
{
    if (!_nameLabel)
    {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = UIColorDrakBlackText;
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
        _addressLabel.textColor = UIColorDrakBlackText;
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
        _customNumLabel.textColor = UIColorDrakBlackText;
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
        _customTitleLabel.textColor = UIColorDrakBlackText;
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

- (UIImageView *)rightArrowImageView{
    if (!_rightArrowImageView) {
        _rightArrowImageView = [[UIImageView alloc] init];
        _rightArrowImageView.image = [UIImage imageNamed:@"right_arrow_black"];
        _rightArrowImageView.contentMode = UIViewContentModeScaleAspectFit;
        _rightArrowImageView.hidden = YES;
    }
    return _rightArrowImageView;
}

- (UILabel *)rightStatusLabel
{
    if (!_rightStatusLabel)
    {
        _rightStatusLabel = [[UILabel alloc] init];
        _rightStatusLabel.textAlignment = NSTextAlignmentRight;
        _rightStatusLabel.font = [UIFont boldSystemFontOfSize:12];
        _rightStatusLabel.hidden = YES;
    }
    return _rightStatusLabel;
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
