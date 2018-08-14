//
//  LiteAccountSetupCell.m
//  Waiting_iOS
//
//  Created by wander on 2018/6/15.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteAccountSetupCell.h"
#import <Masonry/Masonry.h>
#import "BHUserModel.h"

@interface LiteAccountSetupCell ()

@property (nonatomic, strong) UIImageView       * markImageView;
@property (nonatomic, strong) UIImageView       * rightImageView;

@property (nonatomic, strong) UILabel           * leftTitleLabel;   //左边
@property (nonatomic, strong) UILabel           * rightTitleLabel;  //右边
@property (nonatomic, strong) UILabel           * midTitleLabel;    //中间

@end

@implementation LiteAccountSetupCell
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
    NSString *location = [dict objectForKey:@"location"];
    
    if ([location isEqualToString:@"1"]) {
        //中间有文字
        self.midTitleLabel.text = title;
        self.rightImageView.hidden = YES;
    }else{
        self.leftTitleLabel.text = title;
    }
    
//    if (有更新) {
//        self.markImageView.hidden = NO;
//    }
    
    if ([title isEqualToString:@"手机号码"]) {
        if (kStringNotNull([BHUserModel sharedInstance].mobile)) {
            self.rightTitleLabel.text = [BHUserModel sharedInstance].mobile;
        } else {
            self.rightTitleLabel.text = @"未设置";
        }
        self.rightImageView.hidden = YES;
    }
    
    [self layoutSubviewsUI];
}

- (void)lazyCreateUI
{
    if (_isCreated == YES)  return;
    // createUI
    [self.contentView addSubview:self.leftTitleLabel];
    [self.contentView addSubview:self.midTitleLabel];
    [self.contentView addSubview:self.rightTitleLabel];
    [self.contentView addSubview:self.rightImageView];
    [self.contentView addSubview:self.markImageView];
    
    _isCreated = YES;
}

- (void)layoutSubviewsUI
{
    [self.leftTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(15);
        make.centerY.equalTo(self);
        make.height.equalTo(@30);
        make.width.greaterThanOrEqualTo(@60);
    }];
    
    [self.midTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self.leftTitleLabel.mas_centerY);
        make.height.equalTo(@30);
        make.width.greaterThanOrEqualTo(@100);
    }];
    
    [self.rightTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-15);
        make.centerY.equalTo(self.leftTitleLabel.mas_centerY);
        make.height.equalTo(@30);
        make.width.greaterThanOrEqualTo(@60);
    }];
    
    [self.rightImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-15);
        make.centerY.equalTo(self);
        make.height.equalTo(@10);
        make.width.equalTo(self.rightImageView.mas_height).multipliedBy(7.0/12.0);
    }];
    
    [self.markImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.rightImageView.mas_centerY);
        make.right.equalTo(self.rightImageView.mas_left).offset(-20);
        make.height.width.equalTo(@15);
    }];
}

#pragma mark - Get

- (UIImageView *)markImageView
{
    if (!_markImageView)
    {
        _markImageView = [[UIImageView alloc] init];
        _markImageView.image = [UIImage imageNamed:@"account_red_point"];
        _markImageView.contentMode = UIViewContentModeScaleToFill;
        _markImageView.hidden = YES;
    }
    return _markImageView;
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

- (UILabel *)leftTitleLabel
{
    if (!_leftTitleLabel)
    {
        _leftTitleLabel = [[UILabel alloc] init];
        _leftTitleLabel.textColor = UIColorDrakBlackText;
        _leftTitleLabel.textAlignment = NSTextAlignmentLeft;
        _leftTitleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _leftTitleLabel;
}

- (UILabel *)rightTitleLabel
{
    if (!_rightTitleLabel)
    {
        _rightTitleLabel = [[UILabel alloc] init];
        _rightTitleLabel.textColor = UIColorDrakBlackText;
        _rightTitleLabel.textAlignment = NSTextAlignmentRight;
        _rightTitleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _rightTitleLabel;
}

- (UILabel *)midTitleLabel
{
    if (!_midTitleLabel)
    {
        _midTitleLabel = [[UILabel alloc] init];
        _midTitleLabel.textAlignment = NSTextAlignmentCenter;
        _midTitleLabel.textColor = UIColorDrakBlackText;
        _midTitleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _midTitleLabel;
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
