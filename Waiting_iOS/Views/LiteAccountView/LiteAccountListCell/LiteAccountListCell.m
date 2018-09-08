//
//  LiteAccountListCell.m
//  Waiting_iOS
//
//  Created by wander on 2018/6/15.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteAccountListCell.h"
#import <Masonry/Masonry.h>
#import "BHUserModel.h"

@interface LiteAccountListCell ()

@property (nonatomic, strong) UIImageView * leftImageView;
@property (nonatomic, strong) UIImageView * rightImageView;

@property (nonatomic, strong) UILabel     * titleLabel;
@property (nonatomic, strong) UILabel     * markLabel;

@end

@implementation LiteAccountListCell
{
    BOOL _isCreated;
    
    NSDictionary * _dict;
}

#pragma mark - Config Cell's Data

- (void)configWithData:(NSDictionary *)dict
{
    _dict = dict;
    
    [self lazyCreateUI];
    
    NSString *title = [dict objectForKey:@"title"];
    NSString *image = [dict objectForKey:@"image"];

    if ([title isEqualToString:@"资质信息"]) {
            self.markLabel.hidden = NO;
            switch ([[BHUserModel sharedInstance].auditStatus integerValue]) {
                case 0:
                    self.markLabel.text = @"审核中";
                    self.markLabel.textColor = UIColorAlert;
                    break;
                case 1:
                    self.markLabel.text = @"审核通过";
                    self.markLabel.textColor = UIColorBlue;
                    break;
                case 2:
                    self.markLabel.text = @"审核拒绝";
                    self.markLabel.textColor = UIColorError;
                    break;
                default:
                    self.markLabel.text = @"未上传";
                    self.markLabel.textColor = UIColorBlue;
                    break;
                }
    }

    self.leftImageView.image = [UIImage imageNamed:image];
    self.titleLabel.text = title;

    [self layoutSubviewsUI];
}

- (void)lazyCreateUI
{
    if (_isCreated == YES)  return;
    // createUI
    [self.contentView addSubview:self.leftImageView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.rightImageView];
    [self.contentView addSubview:self.markLabel];
    
    _isCreated = YES;
}

- (void)layoutSubviewsUI
{
    [self.leftImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(15);
        make.top.equalTo(self).offset(14);
        make.bottom.equalTo(self).offset(-14);
        make.width.equalTo(self.leftImageView.mas_height);
    }];
    
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.leftImageView.mas_right).offset(12);
            make.centerY.equalTo(self.leftImageView.mas_centerY);
            make.height.equalTo(self.leftImageView.mas_height);
            make.width.greaterThanOrEqualTo(@100);
    }];
    
    [self.rightImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-15);
        make.centerY.equalTo(self);
        make.height.equalTo(@10);
        make.width.equalTo(self.rightImageView.mas_height).multipliedBy(7.0/12.0);
    }];
        
    [self.markLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.titleLabel.mas_centerY);
        make.right.equalTo(self.rightImageView.mas_left).offset(-15);
        make.height.equalTo(@20);
        make.width.greaterThanOrEqualTo(@60);
    }];
}

#pragma mark - Get

- (UIImageView *)leftImageView
{
    if (!_leftImageView)
    {
        _leftImageView = [[UIImageView alloc] init];
        _leftImageView.image = [UIImage imageNamed:@"phone_default_head"];
        _leftImageView.contentMode = UIViewContentModeScaleToFill;
    }
    return _leftImageView;
}

- (UIImageView *)rightImageView
{
    if (!_rightImageView)
    {
        _rightImageView = [[UIImageView alloc] init];
        _rightImageView.contentMode = UIViewContentModeScaleAspectFit;
        _rightImageView.image = [UIImage imageNamed:@"right_arrow_black"];
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
        _titleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _titleLabel;
}
- (UILabel *)markLabel
{
    if (!_markLabel)
    {
        _markLabel = [[UILabel alloc] init];
        _markLabel.textAlignment = NSTextAlignmentCenter;
        _markLabel.textColor = UIColorFromRGB(0x5ED7BC);
        _markLabel.font = [UIFont systemFontOfSize:14];
        _markLabel.hidden = YES;
    }
    return _markLabel;
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
