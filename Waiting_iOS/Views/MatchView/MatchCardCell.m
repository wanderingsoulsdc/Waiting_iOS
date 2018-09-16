//
//  MatchCardCell.m
//  Waiting_iOS
//
//  Created by wander on 2018/8/26.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "MatchCardCell.h"
#import "Masonry.h"

@interface MatchCardCell ()


@property(nonatomic, strong) UIView         * backView;

@property(nonatomic, strong) UIImageView    * mainImageView;     //主图
@property(nonatomic, strong) UIImageView    * overlayImageView;       //蒙层

@property(nonatomic, strong) UILabel        * userNameLabel;
@property(nonatomic, strong) UILabel        * ageAndGenderLabel;

@property(nonatomic, strong) UIView         * photoNumView;
@property(nonatomic, strong) UIImageView    * photoNumImageView;
@property(nonatomic, strong) UILabel        * photoNumLabel;

@end

@implementation MatchCardCell
{
    BHUserModel *_model;
}
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView{
    
    _backView = [[UIView alloc] initWithFrame:self.bounds];
    _backView.backgroundColor = UIColorClearColor;
    [self addSubview:_backView];
    
    [self.backView addSubview:self.mainImageView];
    [self.backView addSubview:self.userNameLabel];
    [self.backView addSubview:self.ageAndGenderLabel];
    [self.backView addSubview:self.overlayImageView];

    [self.backView addSubview:self.photoNumView];
    [self.photoNumView addSubview:self.photoNumImageView];
    [self.photoNumView addSubview:self.photoNumLabel];
    
}

- (void)layoutSubviewsUI
{
    [self.mainImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.backView);
    }];
    
    [self.overlayImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.backView);
        make.height.equalTo(self.mainImageView.mas_height).multipliedBy(1.0f/4.0f);
    }];
    
    [self.ageAndGenderLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backView).offset(15);
        make.right.equalTo(self.backView).offset(-15);
        make.bottom.equalTo(self.backView).offset(-20);
        make.height.equalTo(@16);
    }];
    
    [self.userNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backView).offset(15);
        make.right.equalTo(self.backView).offset(-15);
        make.bottom.equalTo(self.ageAndGenderLabel.mas_top).offset(-15);
        make.height.equalTo(@22);
    }];
    
    [self.photoNumView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.backView).offset(-4);
        make.top.equalTo(self.backView).offset(4);
        make.height.equalTo(@24);
        make.width.equalTo(@54);
    }];
    
    [self.photoNumImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.photoNumView).offset(10);
        make.centerY.equalTo(self.photoNumView.mas_centerY);
        make.height.width.equalTo(@12);
    }];
    
    [self.photoNumLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.photoNumImageView.mas_right);
        make.top.bottom.right.equalTo(self.photoNumView);
    }];
}

- (void)configWithData:(BHUserModel *)model{
    _model = model;
    [self layoutSubviewsUI];
    
    self.photoNumLabel.text = [NSString stringWithFormat:@"%ld",[model.photoArray count]];
    self.userNameLabel.text = model.userName;
    self.ageAndGenderLabel.text = [NSString stringWithFormat:@"%@·%@岁",model.gender == 0 ? @"女":@"男",model.age];
    [self.mainImageView sd_setImageWithURL:[NSURL URLWithString:model.userHeadImageUrl] placeholderImage:[UIImage imageNamed:@"login_register_success"]];
}
#pragma mark - action

#pragma mark - getter

- (UIImageView *)mainImageView{
    if (!_mainImageView) {
        _mainImageView = [[UIImageView alloc] init];
        _mainImageView.image = [UIImage imageNamed:@"login_bg"];
        _mainImageView.layer.cornerRadius = 16.0f;
        _mainImageView.layer.masksToBounds = YES;
        _mainImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _mainImageView;
}

- (UIImageView *)overlayImageView{
    if (!_overlayImageView) {
        _overlayImageView = [[UIImageView alloc] init];
        _overlayImageView.image = [UIImage imageNamed:@"match_overlay"];
        _overlayImageView.contentMode = UIViewContentModeScaleToFill;
    }
    return _overlayImageView;
}

- (UIView *)photoNumView{
    if (!_photoNumView) {
        _photoNumView = [[UIView alloc] init];
        _photoNumView.backgroundColor = UIAlplaColorFromRGB(0x000000, 0.6);
        _photoNumView.layer.cornerRadius = 12.0f;
        _photoNumView.layer.masksToBounds = YES;
    }
    return _photoNumView;
}
- (UIImageView *)photoNumImageView{
    if (!_photoNumImageView) {
        _photoNumImageView = [[UIImageView alloc] init];
        _photoNumImageView.image = [UIImage imageNamed:@"match_photos"];
        _photoNumImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _photoNumImageView;
}
- (UILabel *)photoNumLabel{
    if (!_photoNumLabel) {
        _photoNumLabel = [[UILabel alloc] init];
        _photoNumLabel.text = @"99";
        _photoNumLabel.textAlignment = NSTextAlignmentCenter;
        _photoNumLabel.font = [UIFont systemFontOfSize:12];
        _photoNumLabel.textColor = UIAlplaColorFromRGB(0xFFFFFF, 0.7);
    }
    return _photoNumLabel;
}
- (UILabel *)userNameLabel{
    if (!_userNameLabel) {
        _userNameLabel = [[UILabel alloc] init];
        _userNameLabel.text = @"取个名字真难";
        _userNameLabel.textAlignment = NSTextAlignmentLeft;
        _userNameLabel.font = [UIFont systemFontOfSize:22];
        _userNameLabel.textColor = UIColorWhite;
    }
    return _userNameLabel;
}
- (UILabel *)ageAndGenderLabel{
    if (!_ageAndGenderLabel) {
        _ageAndGenderLabel = [[UILabel alloc] init];
        _ageAndGenderLabel.text = @"女 · 25岁";
        _ageAndGenderLabel.textAlignment = NSTextAlignmentLeft;
        _ageAndGenderLabel.font = [UIFont systemFontOfSize:16];
        _ageAndGenderLabel.textColor = UIColorWhite;
    }
    return _ageAndGenderLabel;
}
@end
