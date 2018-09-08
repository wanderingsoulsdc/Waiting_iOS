//
//  LiteShowBorderCardsCell.m
//  Waiting_iOS
//
//  Created by wander on 2018/7/2.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteShowBorderCardsCell.h"
#import "Masonry.h"
@interface LiteShowBorderCardsCell ()

@property(nonatomic, strong) UIView         * backView;

@property(nonatomic, strong) UIButton       * addButton;
@property(nonatomic, strong) UILabel        * addLabel;

@property(nonatomic, strong) UIView         * existBackView;
@property(nonatomic, strong) UIImageView    * deviceImageView;
@property(nonatomic, strong) UIImageView    * netImageView;
@property(nonatomic, strong) UIImageView    * customImageView;
@property(nonatomic, strong) UIImageView    * labelImageView;
@property(nonatomic, strong) UIImageView    * markImageView;

@property(nonatomic, strong) UILabel        * deviceNameLabel;
@property(nonatomic, strong) UILabel        * deviceMacLabel;
@property(nonatomic, strong) UILabel        * customLabel;
@property(nonatomic, strong) UILabel        * labelNumLabel;
@property(nonatomic, strong) UILabel        * customNumLabel;
@property(nonatomic, strong) UILabel        * netLabel;

@property(nonatomic, strong) UIButton       * bottomButton;
@property(nonatomic, strong) UIButton       * labelNumButton;
@property(nonatomic, strong) UIButton       * deviceNameButton;

@property(nonatomic, strong) UIView         * lineView;

@end

@implementation LiteShowBorderCardsCell
{
    LiteDeviceModel *_model;
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
    _backView.backgroundColor = UIColorWhite;
    _backView.layer.cornerRadius = 4;
    _backView.layer.masksToBounds = YES;
    [self addSubview:_backView];
    
    [self.backView addSubview:self.addButton];
    [self.backView addSubview:self.addLabel];
    
    [self.backView addSubview:self.existBackView];
    [self.existBackView addSubview:self.deviceImageView];
    [self.existBackView addSubview:self.deviceNameButton];
    [self.existBackView addSubview:self.deviceNameLabel];
    [self.existBackView addSubview:self.deviceMacLabel];
    [self.existBackView addSubview:self.netLabel];
    [self.existBackView addSubview:self.netImageView];
    [self.existBackView addSubview:self.customLabel];
    [self.existBackView addSubview:self.customImageView];
    [self.existBackView addSubview:self.customNumLabel];
    [self.existBackView addSubview:self.lineView];
    [self.existBackView addSubview:self.labelImageView];
    [self.existBackView addSubview:self.labelNumLabel];
    [self.existBackView addSubview:self.labelNumButton];
    [self.existBackView addSubview:self.markImageView];
    [self.existBackView addSubview:self.bottomButton];
    
}

- (void)layoutSubviewsUI
{
    [self.addButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.backView.mas_centerX);
        make.centerY.equalTo(self.backView.mas_centerY).offset(-20);
        make.width.height.equalTo(@80);
    }];
    
    [self.addLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.addButton.mas_bottom).offset(10);
        make.centerX.equalTo(self.backView.mas_centerX);
        make.height.equalTo(@20);
        make.width.greaterThanOrEqualTo(@100);
    }];
    [self.existBackView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.backView);
    }];
    [self.deviceImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.existBackView).offset(20);
        make.left.equalTo(self.existBackView).offset(18);
        make.height.width.equalTo(@42);
    }];
    [self.deviceNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.deviceImageView.mas_right).offset(15);
        make.right.equalTo(self.netLabel.mas_left);
        make.top.equalTo(self.deviceImageView.mas_top);
        make.height.equalTo(@22);
//        make.width.equalTo(@160);
    }];
    [self.deviceMacLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.deviceNameLabel.mas_left);
        make.top.equalTo(self.deviceNameLabel.mas_bottom);
        make.height.equalTo(@20);
        make.width.equalTo(@160);
    }];
    
    [self.netImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.existBackView).offset(-10);
        make.top.equalTo(self.deviceImageView.mas_top);
        make.height.width.equalTo(@22);
    }];
    [self.netLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.netImageView.mas_left).offset(-5);
        make.top.equalTo(self.deviceImageView.mas_top);
        make.height.equalTo(@22);
        make.width.equalTo(@40);
    }];
    [self.deviceNameButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.deviceImageView.mas_top);
        make.bottom.equalTo(self.deviceImageView.mas_bottom);
        make.left.equalTo(self.deviceNameLabel.mas_left);
        make.width.equalTo(@160);
    }];

    [self.customImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.deviceNameLabel.mas_left);
        make.top.equalTo(self.deviceMacLabel.mas_bottom).offset(20);
        make.height.width.equalTo(@24);
    }];

    [self.customLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.customImageView.mas_right).offset(10);
        make.top.equalTo(self.customImageView.mas_top);
        make.height.equalTo(@24);
        make.width.equalTo(@90);
    }];
    [self.customNumLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.existBackView).offset(-10);
        make.top.equalTo(self.customImageView.mas_top);
        make.height.equalTo(@24);
        make.width.greaterThanOrEqualTo(@50);
    }];
    
    [self.lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.existBackView).offset(-10);
        make.top.equalTo(self.customImageView.mas_bottom).offset(10);
        make.left.equalTo(self.deviceNameLabel.mas_left);
        make.height.equalTo(@0.5);
    }];
    
    [self.labelImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.deviceNameLabel.mas_left);
        make.top.equalTo(self.lineView.mas_bottom).offset(10);
        make.height.width.equalTo(@24);
    }];
    
    [self.labelNumLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.labelImageView.mas_right).offset(10);
        make.top.equalTo(self.labelImageView.mas_top);
        make.height.equalTo(@24);
        make.width.equalTo(@120);
    }];
    
    [self.markImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.existBackView).offset(-10);
        make.centerY.equalTo(self.labelImageView.mas_centerY);
        make.height.width.equalTo(@14);
    }];
    [self.labelNumButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.labelImageView.mas_top);
        make.bottom.equalTo(self.labelImageView.mas_bottom);
        make.left.equalTo(self.labelImageView.mas_left);
        make.right.equalTo(self.existBackView).offset(-10);
    }];
    [self.bottomButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.labelImageView.mas_bottom).offset(16);
        make.centerX.equalTo(self.existBackView.mas_centerX);
        make.height.equalTo(@38);
        make.width.equalTo(@176);
    }];
    
}

- (void)configWithData:(LiteDeviceModel *)model{
    _model = model;
    [self layoutSubviewsUI];
    if (self.type == typeDeviceExist) { //存在设备
        self.existBackView.hidden = NO;
        self.addButton.hidden = YES;
        self.addLabel.hidden = YES;
        self.deviceNameLabel.text = model.deviceName;
        self.deviceMacLabel.text = model.mac;
        if ([model.netStatus isEqualToString:@"1"]) {
            //未联网
            self.netLabel.text = @"未联网";
            self.netLabel.textColor = UIColorlightGray;
            self.netImageView.image = [UIImage imageNamed:@"main_device_net_off"];
        }else{
            self.netLabel.text = @"已联网";
            self.netLabel.textColor = UIColorFromRGB(0x5ED7BC);
            self.netImageView.image = [UIImage imageNamed:@"main_device_net"];
        }
        if ([model.labelNum integerValue] > 0) {
            self.labelNumLabel.text = [NSString stringWithFormat:@"已创建%@个标签",model.labelNum];
            self.labelNumButton.userInteractionEnabled = YES;
            self.markImageView.hidden = NO;
        }else{
            self.labelNumLabel.text = @"未创建标签";
            self.labelNumButton.userInteractionEnabled = NO;
            self.markImageView.hidden = YES;
        }
        self.customNumLabel.text = model.personNum;
        if ([model.sign isEqualToString:@"1"]) {//1 正在工作中 2 已暂停工作 3 创建标签
            [self.bottomButton setTitle:@"正在创建标签中..." forState:UIControlStateNormal];
            [self.bottomButton setImage:[UIImage imageNamed:@"main_device_collect"] forState:UIControlStateNormal];
            self.bottomButton.imageEdgeInsets = UIEdgeInsetsMake(0, -8, 0, 8);
//            if ([model.netStatus isEqualToString:@"1"]) { //未联网
//                self.bottomButton.backgroundColor = UIColorlightGray;
//                self.bottomButton.userInteractionEnabled = NO;
//            }else{
                self.bottomButton.backgroundColor = UIColorBlue;
                self.bottomButton.userInteractionEnabled = YES;
//            }
        }else if ([model.sign isEqualToString:@"2"]){
            [self.bottomButton setTitle:@"已暂停工作" forState:UIControlStateNormal];
            [self.bottomButton setImage:nil forState:UIControlStateNormal];
//            if ([model.netStatus isEqualToString:@"1"]) { //未联网
//                self.bottomButton.backgroundColor = UIColorlightGray;
//                self.bottomButton.userInteractionEnabled = NO;
//            }else{
                self.bottomButton.backgroundColor = UIColorAlert;
                self.bottomButton.userInteractionEnabled = YES;
//            }
        }else{
            [self.bottomButton setTitle:@"创建标签" forState:UIControlStateNormal];
            [self.bottomButton setImage:nil forState:UIControlStateNormal];
            self.bottomButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
            if ([model.netStatus isEqualToString:@"1"]) { //未联网
                self.bottomButton.backgroundColor = UIColorlightGray;
                self.bottomButton.userInteractionEnabled = NO;
            }else{
                self.bottomButton.backgroundColor = UIColorBlue;
                self.bottomButton.userInteractionEnabled = YES;
            }
        }
        
    }else{
        self.addButton.hidden =NO;
        self.addLabel.hidden = NO;
        self.existBackView.hidden = YES;
    }
}
#pragma mark - action

- (void)addButtonAction:(UIButton *)button{
    NSLog(@"点击cell里的添加按钮");
    if ([self.delegate respondsToSelector:@selector(buttonAction:deviceModel:)]) {
        [self.delegate buttonAction:ActionTypeAddDevice deviceModel:nil];
    }
}

- (void)deviceNameButtonActon:(UIButton *)button{
    NSLog(@"点击cell里的设备名称");
    if ([self.delegate respondsToSelector:@selector(buttonAction:deviceModel:)]) {
        [self.delegate buttonAction:ActionTypeDeviceName deviceModel:_model];
    }
}

- (void)labelNumButtonActon:(UIButton *)button{
    NSLog(@"点击cell里的已创建标签按钮");
    if ([self.delegate respondsToSelector:@selector(buttonAction:deviceModel:)]) {
        [self.delegate buttonAction:ActionTypeLabelNum deviceModel:_model];
    }
}

- (void)bottomButtonActon:(UIButton *)button{
    NSLog(@"点击cell里的创建标签按钮");
    if ([self.delegate respondsToSelector:@selector(buttonAction:deviceModel:)]) {
        [self.delegate buttonAction:ActionTypeBottom deviceModel:_model];
    }
}

#pragma mark - getter

- (UIButton *)addButton{
    if (!_addButton) {
        _addButton = [[UIButton alloc] init];
        [_addButton setImage:[UIImage imageNamed:@"account_invoice_add"] forState:UIControlStateNormal];
        [_addButton addTarget:self action:@selector(addButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _addButton.hidden = YES;
    }
    return _addButton;
}

- (UILabel *)addLabel{
    if (!_addLabel) {
        _addLabel = [[UILabel alloc] init];
        _addLabel.text = @"添加一个新的设备";
        _addLabel.textAlignment = NSTextAlignmentCenter;
        _addLabel.font = [UIFont systemFontOfSize:12];
        _addLabel.textColor = UIColorBlue;
        _addLabel.hidden = YES;
    }
    return _addLabel;
}

- (UIImageView *)deviceImageView{
    if (!_deviceImageView) {
        _deviceImageView = [[UIImageView alloc] init];
        _deviceImageView.image = [UIImage imageNamed:@"main_device_logo"];
        _deviceImageView.contentMode = UIViewContentModeScaleAspectFit;
//        _deviceImageView.hidden = YES;
    }
    return _deviceImageView;
}
- (UIImageView *)customImageView{
    if (!_customImageView) {
        _customImageView = [[UIImageView alloc] init];
        _customImageView.image = [UIImage imageNamed:@"main_today_custom"];
        _customImageView.contentMode = UIViewContentModeScaleAspectFit;
//        _customImageView.hidden = YES;
    }
    return _customImageView;
}
- (UIImageView *)netImageView{
    if (!_netImageView) {
        _netImageView = [[UIImageView alloc] init];
        _netImageView.image = [UIImage imageNamed:@"main_device_net"];
        _netImageView.contentMode = UIViewContentModeScaleAspectFit;
//        _netImageView.hidden = YES;
    }
    return _netImageView;
}
- (UIImageView *)labelImageView{
    if (!_labelImageView) {
        _labelImageView = [[UIImageView alloc] init];
        _labelImageView.image = [UIImage imageNamed:@"account_label_image_select"];
        _labelImageView.contentMode = UIViewContentModeScaleAspectFit;
//        _labelImageView.hidden = YES;
    }
    return _labelImageView;
}
- (UIImageView *)markImageView{
    if (!_markImageView) {
        _markImageView = [[UIImageView alloc] init];
        _markImageView.image = [UIImage imageNamed:@"right_arrow_black"];
        _markImageView.contentMode = UIViewContentModeScaleAspectFit;
        _markImageView.hidden = YES;
    }
    return _markImageView;
}

- (UILabel *)deviceNameLabel{
    if (!_deviceNameLabel) {
        _deviceNameLabel = [[UILabel alloc] init];
        _deviceNameLabel.text = @"设备名称";
        _deviceNameLabel.textAlignment = NSTextAlignmentLeft;
        _deviceNameLabel.font = [UIFont systemFontOfSize:16];
        _deviceNameLabel.textColor = UIColorDarkBlack;
//        _deviceNameLabel.hidden = YES;
    }
    return _deviceNameLabel;
}
- (UILabel *)deviceMacLabel{
    if (!_deviceMacLabel) {
        _deviceMacLabel = [[UILabel alloc] init];
        _deviceMacLabel.text = @"f4:31:c3:02:8c:72";
        _deviceMacLabel.textAlignment = NSTextAlignmentLeft;
        _deviceMacLabel.font = [UIFont systemFontOfSize:12];
        _deviceMacLabel.textColor = UIColorlightGray;
//        _deviceMacLabel.hidden = YES;
    }
    return _deviceMacLabel;
}
- (UILabel *)netLabel{
    if (!_netLabel) {
        _netLabel = [[UILabel alloc] init];
        _netLabel.text = @"未联网";
        _netLabel.textAlignment = NSTextAlignmentRight;
        _netLabel.font = [UIFont systemFontOfSize:12];
        _netLabel.textColor = UIColorlightGray;
//        _netLabel.hidden = YES;
    }
    return _netLabel;
}
- (UILabel *)customLabel{
    if (!_customLabel) {
        _customLabel = [[UILabel alloc] init];
        _customLabel.text = @"今日客户人数";
        _customLabel.textAlignment = NSTextAlignmentLeft;
        _customLabel.font = [UIFont systemFontOfSize:12];
        _customLabel.textColor = UIColorDarkBlack;
//        _customLabel.hidden = YES;
    }
    return _customLabel;
}
- (UILabel *)customNumLabel{
    if (!_customNumLabel) {
        _customNumLabel = [[UILabel alloc] init];
        _customNumLabel.text = @"0";
        _customNumLabel.textAlignment = NSTextAlignmentRight;
        _customNumLabel.font = [UIFont systemFontOfSize:20];
        _customNumLabel.textColor = UIColorDarkBlack;
//        _customNumLabel.hidden = YES;
    }
    return _customNumLabel;
}
- (UILabel *)labelNumLabel{
    if (!_labelNumLabel) {
        _labelNumLabel = [[UILabel alloc] init];
        _labelNumLabel.text = @"未创建标签";
        _labelNumLabel.textAlignment = NSTextAlignmentLeft;
        _labelNumLabel.font = [UIFont systemFontOfSize:12];
        _labelNumLabel.textColor = UIColorDarkBlack;
//        _labelNumLabel.hidden = YES;
    }
    return _labelNumLabel;
}

- (UIButton *)deviceNameButton{
    if (!_deviceNameButton) {
        _deviceNameButton = [[UIButton alloc] init];
        _deviceNameButton.backgroundColor = UIColorClearColor;
        [_deviceNameButton addTarget:self action:@selector(deviceNameButtonActon:) forControlEvents:UIControlEventTouchUpInside];
//        _deviceNameButton.hidden = YES;
    }
    return _deviceNameButton;
}

- (UIButton *)labelNumButton{
    if (!_labelNumButton) {
        _labelNumButton = [[UIButton alloc] init];
        _labelNumButton.backgroundColor = UIColorClearColor;
        [_labelNumButton addTarget:self action:@selector(labelNumButtonActon:) forControlEvents:UIControlEventTouchUpInside];
//        _labelNumButton.hidden = YES;
    }
    return _labelNumButton;
}

- (UIButton *)bottomButton{
    if (!_bottomButton) {
        _bottomButton = [[UIButton alloc] init];
        _bottomButton.backgroundColor = UIColorBlue;
        [_bottomButton setTitle:@"创建标签" forState:UIControlStateNormal];
        _bottomButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _bottomButton.layer.cornerRadius = 19; //height =38
        _bottomButton.layer.masksToBounds = YES;
        [_bottomButton addTarget:self action:@selector(bottomButtonActon:) forControlEvents:UIControlEventTouchUpInside];
//        _bottomButton.hidden = YES;
    }
    return _bottomButton;
}

- (UIView *)existBackView{
    if (!_existBackView) {
        _existBackView = [[UIView alloc] init];
        _existBackView.backgroundColor = UIColorClearColor;
        _existBackView.hidden = YES;
    }
    return _existBackView;
}

- (UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = UIColorlightGray;
    }
    return _lineView;
}

@end
