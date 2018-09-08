//
//  LiteAccountInvoiceView.m
//  Waiting_iOS
//
//  Created by wander on 2018/6/25.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteAccountInvoiceView.h"

@implementation LiteAccountInvoiceView
{
    invoiceViewType _type;
}

- (instancetype)initWithFrame:(CGRect)frame withType:(invoiceViewType)type{
    self = [super initWithFrame:frame];
    if (self) {
        _type = type;
        self.backgroundColor = UIColorWhite;
       
        [self addSubview:self.leftTitleLabel];
        [self addSubview:self.leftDetailTitleLabel];
        [self addSubview:self.markLabel];
        [self addSubview:self.rightImageView];
        [self addSubview:self.rightTitleLabel];
        [self addSubview:self.rightDetailReasonButton];
        
        [self addSubview:self.invoiceTypeButton];
        
        [self addSubview:self.textField];
        [self addSubview:self.lineView];
        [self addSubview:self.textView];
        
        if (type == typeTextField) {
            self.textField.hidden = NO;
        } else if (type == typeLabel){
            self.rightTitleLabel.hidden = NO;
        } else if (type == typeButton){
            self.invoiceTypeButton.hidden = NO;
        } else if (type == typeStatus){
            self.markLabel.hidden = NO;
            self.rightImageView.hidden = NO;
        } else if (type == typeTextView){
            self.textView.hidden = NO;
        }
        [self layoutSubviewsUI];
    }
    return self;
}

- (void)layoutSubviewsUI
{
    [self.leftTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(15);
        make.top.equalTo(self).offset(19);
        make.height.equalTo(@20);
        make.width.greaterThanOrEqualTo(@60);
    }];
    
    [self.leftDetailTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(15);
        make.top.equalTo(self.leftTitleLabel.mas_bottom).offset(8);
        make.height.equalTo(@17);
        make.width.greaterThanOrEqualTo(@150);
    }];
    
    [self.rightTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-15);
        make.centerY.equalTo(self.leftTitleLabel.mas_centerY);
        make.height.equalTo(@20);
        make.width.greaterThanOrEqualTo(@60);
    }];
    
    [self.rightDetailReasonButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-15);
        make.centerY.equalTo(self.leftDetailTitleLabel.mas_centerY);
        make.height.equalTo(@17);
        make.width.greaterThanOrEqualTo(@60);
    }];
    
    [self.rightImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-15);
        make.centerY.equalTo(self);
        make.height.equalTo(@10);
        make.width.equalTo(self.rightImageView.mas_height).multipliedBy(7.0/12.0);
    }];
    
    [self.markLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.leftTitleLabel.mas_centerY);
        make.right.equalTo(self.rightImageView.mas_left).offset(-15);
        make.height.equalTo(@20);
        make.width.greaterThanOrEqualTo(@60);
    }];
    
    [self.invoiceTypeButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-15);
        make.centerY.equalTo(self.leftTitleLabel.mas_centerY);
        make.height.equalTo(@30);
        make.width.greaterThanOrEqualTo(@100);
    }];
    
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-15);
        make.centerY.equalTo(self.leftTitleLabel.mas_centerY);
        make.height.equalTo(@30);
        make.width.equalTo(@240);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.equalTo(self);
        make.left.equalTo(self).offset(15);
        make.height.equalTo(@0.6);
    }];
    
    [self.invoiceTypeButton.superview layoutIfNeeded];
    
    [self layoutDeviceButton];
}

//按钮内文字和图片重新布局
- (void)layoutDeviceButton{
    CGFloat imageWidth = _invoiceTypeButton.imageView.bounds.size.width;
    CGFloat labelWidth = _invoiceTypeButton.titleLabel.bounds.size.width;
    _invoiceTypeButton.imageEdgeInsets = UIEdgeInsetsMake(1, labelWidth+3, -1, -(labelWidth+3));
    _invoiceTypeButton.titleEdgeInsets = UIEdgeInsetsMake(0, -imageWidth, 0, imageWidth);
}

#pragma mark - ******* Private Methods *******

- (void)setReplaceMoney:(NSString *)replaceMoney{
    _replaceMoney = replaceMoney;
    if ([replaceMoney floatValue] > 0) {
        self.leftDetailTitleLabel.hidden = NO;
        self.leftDetailTitleLabel.text = [NSString stringWithFormat:@"不可开发票金额%@元",replaceMoney];
        self.rightDetailReasonButton.hidden = NO;
    }else{
        self.leftDetailTitleLabel.hidden = YES;
        self.rightDetailReasonButton.hidden = YES;
    }
}

#pragma mark - action


- (void)invoiceTypeButtonAction:(UIButton *)sender
{
    [self.superview endEditing:YES];
    NSLog(@"发票类型选择");
    [self showPickView];
}

- (void)rightDetailReasonButtonAction:(UIButton *)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"rightDetailReasonButtonAction" object:nil];
}

#pragma mark - PickViewDelegate

- (void)showPickView{
    
    [self.pickView reloadData];
    [[UIApplication sharedApplication].keyWindow addSubview:self.pickView];
    [self.pickView show];
}


-(void)pickView:(XZPickView *)pickerView confirmButtonClick:(UIButton *)button{
    
    NSInteger index = [pickerView selectedRowInComponent:0];
//    if ([self.delegate respondsToSelector:@selector(invoiceTypeSelectResult:)]) {
//        [self.delegate invoiceTypeSelectResult:[NSString stringWithFormat:@"%ld",index]];
//    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"invoiceTypeSelectResult" object:[NSString stringWithFormat:@"%ld",index]];
}

-(NSInteger)numberOfComponentsInPickerView:(XZPickView *)pickerView{
    return 1;
}

-(NSInteger)pickerView:(XZPickView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    return 2;
}

-(void)pickerView:(XZPickView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    if (row == 0)
    {
        NSLog(@"点击了 %@", @"增值税普通发票");
        [self.invoiceTypeButton setTitle:@"增值税普通发票" forState:UIControlStateNormal];
    }else{
        NSLog(@"点击了 %@", @"增值税专用发票");
        [self.invoiceTypeButton setTitle:@"增值税专用发票" forState:UIControlStateNormal];
    }
}

-(NSString *)pickerView:(XZPickView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    if (row == 0)
    {
        return @"增值税普通发票";
    }else{
        return @"增值税专用发票";
    }
}

#pragma mark - Get

- (UIImageView *)rightImageView
{
    if (!_rightImageView)
    {
        _rightImageView = [[UIImageView alloc] init];
        _rightImageView.contentMode = UIViewContentModeScaleAspectFit;
        _rightImageView.image = [UIImage imageNamed:@"right_arrow_black"];
        _rightImageView.hidden = YES;
    }
    return _rightImageView;
}

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

- (UILabel *)leftDetailTitleLabel
{
    if (!_leftDetailTitleLabel)
    {
        _leftDetailTitleLabel = [[UILabel alloc] init];
        _leftDetailTitleLabel.textColor = UIColorFromRGB(0x797E81);
        _leftDetailTitleLabel.textAlignment = NSTextAlignmentLeft;
        _leftDetailTitleLabel.font = [UIFont systemFontOfSize:12];
        _leftDetailTitleLabel.hidden = YES;
    }
    return _leftDetailTitleLabel;
}

- (UILabel *)rightTitleLabel
{
    if (!_rightTitleLabel)
    {
        _rightTitleLabel = [[UILabel alloc] init];
        _rightTitleLabel.textColor = UIColorDarkBlack;
        _rightTitleLabel.textAlignment = NSTextAlignmentRight;
        _rightTitleLabel.font = [UIFont systemFontOfSize:14];
        _rightTitleLabel.hidden = YES;
    }
    return _rightTitleLabel;
}

- (UIButton *)rightDetailReasonButton
{
    if (!_rightDetailReasonButton)
    {
        _rightDetailReasonButton = [[UIButton alloc] init];
        [_rightDetailReasonButton setTitleColor:UIColorBlue forState:UIControlStateNormal];
        [_rightDetailReasonButton setTitle:@"查看原因" forState:UIControlStateNormal];
        _rightDetailReasonButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_rightDetailReasonButton addTarget:self action:@selector(rightDetailReasonButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _rightDetailReasonButton.hidden = YES;
    }
    return _rightDetailReasonButton;
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

- (UIButton *)invoiceTypeButton
{
    if (!_invoiceTypeButton)
    {
        _invoiceTypeButton = [[UIButton alloc] init];
        [_invoiceTypeButton setTitleColor:UIColorDarkBlack forState:UIControlStateNormal];
        [_invoiceTypeButton setTitle:@"增值税普通发票" forState:UIControlStateNormal];
        _invoiceTypeButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_invoiceTypeButton addTarget:self action:@selector(invoiceTypeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_invoiceTypeButton setImage:[UIImage imageNamed:@"down_triangle"] forState:UIControlStateNormal];
        _invoiceTypeButton.adjustsImageWhenHighlighted = NO;// 取消图片的高亮状态
        
        _invoiceTypeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;// 水平右对齐
        _invoiceTypeButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;// 垂直居中对齐
        _invoiceTypeButton.hidden = YES;
    }
    return _invoiceTypeButton;
}

- (UITextField *)textField{
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.textColor = UIColorDarkBlack;
        _textField.textAlignment = NSTextAlignmentRight;
        _textField.font = [UIFont systemFontOfSize:14];
        _textField.borderStyle = UITextBorderStyleNone;
        _textField.hidden = YES;
        _textField.returnKeyType = UIReturnKeyDone;
        //        _textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入验证码" attributes:@{NSForegroundColorAttributeName: UIColorFooderText}];
        //        _textField.keyboardType = UIKeyboardTypeNumberPad;
        
    }
    return _textField;
}

- (UITextView *)textView{
    if (!_textView) {
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(15, 15+35, kScreenWidth - 30, 30)];
        _textView.placeholder = @"请输入收件地址";
        _textView.textColor = UIColorDarkBlack;
        _textView.textAlignment = NSTextAlignmentLeft;
        _textView.font = [UIFont systemFontOfSize:14];
        [_textView setContentInset:UIEdgeInsetsMake(-10, -5, -15, -5)];//设置UITextView的内边距
        _textView.layoutManager.allowsNonContiguousLayout = NO;
        _textView.scrollEnabled = YES;  //  如果scrollEnabled=NO，计算出来的还是不正确的，这里虽然设置为YES，但textView实际并不会滚动，并正确显示出来内容
        _textView.hidden = YES;
    }
    return _textView;
}

-(XZPickView *)pickView{
    if(!_pickView){
        _pickView = [[XZPickView alloc]initWithFrame:[UIScreen mainScreen].bounds title:@""];
        _pickView.delegate = self;
        _pickView.dataSource = self;
    }
    return _pickView;
}

-(UIView *)lineView{
    if(!_lineView){
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = UIColorlightGray;
    }
    return _lineView;
}


@end
