//
//  LiteAccountQualificationICPCell.m
//  Waiting_iOS
//
//  Created by wander on 2018/6/19.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteAccountQualificationICPCell.h"
#import <Masonry/Masonry.h>
#import "UIImageView+AFNetworking.h"

@interface LiteAccountQualificationICPCell () <UITextFieldDelegate>

@property (nonatomic, strong) UILabel     * cellTitleLabel;
@property (nonatomic, strong) UIView      * bgView;

@property (nonatomic, strong) UIImageView * qualificationImageView;
@property (nonatomic, strong) UILabel     * remindTitleLabel;
@property (nonatomic, strong) UILabel     * remindDetailLabel;

@end

@implementation LiteAccountQualificationICPCell
{
    BOOL _isCreated;
    
    NSDictionary * _dict;
}

#pragma mark - CreateUI

- (void)lazyCreateUI
{
    if (_isCreated == YES)  return;
    
    // createUI
    self.backgroundColor = UIColorFromRGB(0xF4F4F4);
    [self.contentView addSubview:self.bgView];
    [self.contentView addSubview:self.qualificationImageView];
    [self.contentView addSubview:self.remindTitleLabel];
    [self.contentView addSubview:self.remindDetailLabel];
    
    _isCreated = YES;
}

#pragma mark - Config Cell's Data

- (void)configWithData:(NSDictionary *)dic
{
    _dict = dic;
    [self lazyCreateUI];
    UIImage *image = [dic objectForKey:@"image"];
    NSString *imageUrl = [dic objectForKey:@"imageUrl"];
    
    if (image)
    {
        self.qualificationImageView.image = image;
    }
    else if (imageUrl)
    {
        NSString * urlString = [NSString stringWithFormat:@"%@%@",kApiHostPort,imageUrl];
        [self.qualificationImageView setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:@"add"]];
    }
    else
    {
        self.qualificationImageView.image = [UIImage imageNamed:@"add"];
    }
    if (self.type == ICPCellTypeBusinessLicense) {
        self.remindTitleLabel.text = @"上传营业执照";
    } else if (self.type == ICPCellTypeTaxpayerCertify) {
        self.remindTitleLabel.text = @"上传银行纳税人证明";
    } else if (self.type == ICPCellTypeBankLicense) {
        self.remindTitleLabel.text = @"上传银行开户许可证";
    }
    
    // layoutSubviews
    [self layoutSubviewsUI];
}

- (void)layoutSubviewsUI
{
    
    [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.top.equalTo(self);
    }];

    [self.qualificationImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(12);
        make.left.equalTo(self).offset(12);
        make.width.height.equalTo(@60);
    }];
    [self.remindTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.qualificationImageView);
        make.left.equalTo(self.qualificationImageView.mas_right).offset(12);
        make.right.equalTo(self);
        make.height.equalTo(@20);
    }];
    [self.remindDetailLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.remindTitleLabel);
        make.top.equalTo(self.remindTitleLabel.mas_bottom);
        make.bottom.equalTo(self);
    }];
}

#pragma mark - Event response

- (void)qualificationImageViewAction
{
    NSLog(@"点击图片");
    if ([self.delegate respondsToSelector:@selector(clickImageView)])
    {
        [self.delegate clickImageView];
    }
}

#pragma mark - Get

- (UILabel *)cellTitleLabel
{
    if (!_cellTitleLabel)
    {
        _cellTitleLabel = [[UILabel alloc] init];
        _cellTitleLabel.textColor = UIColorDrakBlackNav;
        _cellTitleLabel.textAlignment = NSTextAlignmentLeft;
        _cellTitleLabel.font = [UIFont systemFontOfSize:14];
        _cellTitleLabel.backgroundColor = [UIColor clearColor];
    }
    return _cellTitleLabel;
}

- (UIView *)bgView
{
    if (!_bgView)
    {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    }
    return _bgView;
}

- (UIImageView *)qualificationImageView
{
    if (!_qualificationImageView)
    {
        _qualificationImageView = [[UIImageView alloc] init];
        _qualificationImageView.image = [UIImage imageNamed:@"add"];
        _qualificationImageView.contentMode = UIViewContentModeScaleAspectFit;
        _qualificationImageView.layer.borderWidth = 1;
        _qualificationImageView.layer.borderColor = UIColorGray.CGColor;
        _qualificationImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(qualificationImageViewAction)];
        [_qualificationImageView addGestureRecognizer:tap];
    }
    return _qualificationImageView;
}
- (UILabel *)remindTitleLabel
{
    if (!_remindTitleLabel)
    {
        _remindTitleLabel = [[UILabel alloc] init];
        _remindTitleLabel.text = @"上传营业执照";
        _remindTitleLabel.font = [UIFont systemFontOfSize:16];
        _remindTitleLabel.textAlignment = NSTextAlignmentLeft;
        _remindTitleLabel.textColor = UIColorDrakBlackNav;
    }
    return _remindTitleLabel;
}
- (UILabel *)remindDetailLabel
{
    if (!_remindDetailLabel)
    {
        _remindDetailLabel = [[UILabel alloc] init];
        NSString * remindDetailStr = @"• 扫描图片或正面拍照\n• 保证信息清晰可见\n• 请上传JPG格式的图片\n• 图片大小如超过500k，系统会自动压缩";
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 6;// 字体的行间距
        NSDictionary *attributes = @{
                                     NSFontAttributeName:[UIFont systemFontOfSize:15],
                                     NSParagraphStyleAttributeName:paragraphStyle
                                     };
        _remindDetailLabel.attributedText = [[NSAttributedString alloc] initWithString:remindDetailStr attributes:attributes];
        _remindDetailLabel.textColor = UIColorGray;
        _remindDetailLabel.numberOfLines = 0;
        _remindDetailLabel.textAlignment = NSTextAlignmentLeft;
        _remindDetailLabel.font = [UIFont systemFontOfSize:14];
    }
    return _remindDetailLabel;
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
