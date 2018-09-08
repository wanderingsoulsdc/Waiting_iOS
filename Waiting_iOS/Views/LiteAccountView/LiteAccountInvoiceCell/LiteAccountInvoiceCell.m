//
//  LiteAccountInvoiceCell.m
//  Waiting_iOS
//
//  Created by wander on 2018/6/24.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteAccountInvoiceCell.h"
#import <Masonry/Masonry.h>

@interface LiteAccountInvoiceCell ()

@property (nonatomic, strong) UILabel       * leftTitleLabel;
@property (nonatomic, strong) UILabel       * rightTitleLabel;

@end

@implementation LiteAccountInvoiceCell
{
    BOOL _isCreated;
    
    NSDictionary * _dic;
}


#pragma mark - Config Cell's Data

- (void)configWithData:(NSDictionary *)dic{
    _dic = dic;
    [self lazyCreateUI];
    
    NSString *title = dic[@"title"];
    NSString *content = dic[@"content"];
    self.leftTitleLabel.text = title;
    self.rightTitleLabel.text = content;
    [self layoutSubviewsUI];
    
    if ([title hasSuffix:@"纳税人证明"]) {
        if (kStringNotNull(content)) {
            self.rightTitleLabel.text = @"已上传";
        }else{
            self.rightTitleLabel.text = @"未上传";
        }
    }
    
    if ([title isEqualToString:@"收件地址"]) {
        self.rightTitleLabel.textAlignment = NSTextAlignmentLeft;
        self.rightTitleLabel.numberOfLines = 0;
        
       [self.rightTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(15);
            make.right.equalTo(self).offset(-15);
            make.top.equalTo(self.leftTitleLabel.mas_bottom).offset(5);
            make.height.greaterThanOrEqualTo(@30);
        }];
    }
}

- (void)lazyCreateUI
{
    if (_isCreated == YES)  return;
    // createUI
    [self.contentView addSubview:self.leftTitleLabel];
    [self.contentView addSubview:self.rightTitleLabel];

    _isCreated = YES;
}
- (void)layoutSubviewsUI
{
    [self.leftTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self).offset(15);
        make.height.equalTo(@30);
        make.width.greaterThanOrEqualTo(@60);
    }];
    
    [self.rightTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-15);
        make.centerY.equalTo(self.leftTitleLabel.mas_centerY);
        make.height.equalTo(@30);
        make.width.greaterThanOrEqualTo(@60);
    }];
}



#pragma mark - Get


- (UILabel *)leftTitleLabel
{
    if (!_leftTitleLabel)
    {
        _leftTitleLabel = [[UILabel alloc] init];
        _leftTitleLabel.textColor = UIColorDarkBlack;
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
        _rightTitleLabel.textColor = UIColorDarkBlack;
        _rightTitleLabel.textAlignment = NSTextAlignmentRight;
        _rightTitleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _rightTitleLabel;
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
