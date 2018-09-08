//
//  LiteAccountQualificationCell.m
//  Waiting_iOS
//
//  Created by wander on 2018/6/19.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteAccountQualificationCell.h"
#import <Masonry/Masonry.h>
#import "XZPickView.h"
#import "BHUserModel.h"

@interface LiteAccountQualificationCell ()<XZPickViewDelegate, XZPickViewDataSource,UITextFieldDelegate>

@property (nonatomic, strong) UIButton      * firstLevelTradesButton;
@property (nonatomic, strong) UIImageView   * firstLevelImageView;
@property (nonatomic, strong) UIButton      * secondLevelTradesButton;
@property (nonatomic, strong) UIImageView   * secondLevelImageView;
@property (nonatomic, strong) UIView        * LevelTradesView;  //行业信息视图
@property (nonatomic, strong) XZPickView    * pickView;         //行业选择器

@property (nonatomic, strong) UIImageView   * rightImageView;

@property (nonatomic, strong) UILabel       * leftTitleLabel;
@property (nonatomic, strong) UILabel       * rightTitleLabel;
@property (nonatomic, strong) UILabel       * markLabel;
@property (nonatomic, strong) UITextField   * textField;

@end

@implementation LiteAccountQualificationCell
{
    BOOL _isCreated;
    
    NSDictionary * _dict;
    
    NSArray      * _levelTradesArr;   //所有行业
    NSArray      * _subSourceData;    //二级行业(默认第一个一级行业)
}

#pragma mark - textfieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * str = [NSString stringWithFormat:@"%@%@",textField.text,string];
    //匹配数字,字母和中文
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^[a-zA-Z0-9\\u4E00-\\u9FA5]+$"];
    return [predicate evaluateWithObject:str] ? YES : NO;
}

-(void)textFieldDidChange:(UITextField *)textField{
    NSLog(@"%@",textField.text);
    if ([self.delegate respondsToSelector:@selector(businessNameResult:)]) {
        [self.delegate businessNameResult:textField.text];
    }
}

#pragma mark - PickViewDelegate

- (void)showPickView{
    if (!kArrayNotNull(_levelTradesArr)) {
        return;
    }
    [self.superview endEditing:YES];

    [self.pickView reloadData];
    [[UIApplication sharedApplication].keyWindow addSubview:self.pickView];
    [self.pickView show];
}


-(void)pickView:(XZPickView *)pickerView confirmButtonClick:(UIButton *)button{
    
    NSInteger left = [pickerView selectedRowInComponent:0];
    NSInteger right = [pickerView selectedRowInComponent:1];
    NSDictionary * dict  = [_levelTradesArr objectAtIndex:left];
    _subSourceData = dict[@"child"];
    [self.firstLevelTradesButton setTitle:dict[@"name"] forState:UIControlStateNormal];
    
    NSDictionary * subDict = [_subSourceData objectAtIndex:right];
    [self.secondLevelTradesButton setTitle:subDict[@"name"] forState:UIControlStateNormal];
    
    NSMutableDictionary *LevelTradesSelectResult = [NSMutableDictionary new];
    [LevelTradesSelectResult setValue:[NSString stringWithFormat:@"%@",[dict stringValueForKey:@"id" default:@""]] forKey:@"first"];
    [LevelTradesSelectResult setValue:[NSString stringWithFormat:@"%@",[subDict stringValueForKey:@"id" default:@""]] forKey:@"second"];
    
    
    if ([self.delegate respondsToSelector:@selector(LevelTradesSelectResult:)]) {
        [self.delegate LevelTradesSelectResult:LevelTradesSelectResult];
    }
}

-(NSInteger)numberOfComponentsInPickerView:(XZPickView *)pickerView{
    return 2;
}

-(NSInteger)pickerView:(XZPickView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    if (component == 0)
    {
        return _levelTradesArr.count;
    }
    else
    {
        return _subSourceData.count;
    }
}

-(void)pickerView:(XZPickView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    if (component == 0)
    {
        NSLog(@"一级分类点击了第 %ld 个选项", row);
        NSDictionary * dict  = [_levelTradesArr objectAtIndex:row];
        _subSourceData = dict[@"child"];
        
        [self.pickView pickReloadComponent:1];
        [self.pickView selectRow:0 inComponent:1 animated:YES];
    }
    else
    {
        NSLog(@"二级分类点击了第 %ld 选项", row);
    }
    
}

-(NSString *)pickerView:(XZPickView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    if (component == 0)
    {
        NSDictionary * dict = [_levelTradesArr objectAtIndex:row];
        return dict[@"name"];
    }
    else
    {
        NSDictionary * dict = [_subSourceData objectAtIndex:row];
        return dict[@"name"];
    }
}



#pragma mark - Config Cell's Data

- (void)configWithData:(NSDictionary *)dict levelTradesData:(NSArray *)levelTradesArr
{
    _dict = dict;
    _levelTradesArr = levelTradesArr;

    if (kArrayNotNull(levelTradesArr)) {
        NSDictionary * dict  = [_levelTradesArr objectAtIndex:0];
        _subSourceData = dict[@"child"];
        [self analysisIndustryLevelName];
    }
    
    [self lazyCreateUI];
    
    NSString *title = [dict objectForKey:@"title"];
    
    if ([title isEqualToString:@"营业执照名称"]) {
        if (kStringNotNull([BHUserModel sharedInstance].businessName)) {
            self.textField.text = [BHUserModel sharedInstance].businessName;
        }
        self.textField.hidden = NO;
    }else if ([title isEqualToString:@"营业执照"]){
        self.rightImageView.hidden = NO;
        self.markLabel.hidden = NO;
        if (kStringNotNull(self.businessLicenceImg)) {
            self.markLabel.text = @"已上传";
        }else{
            self.markLabel.text = @"未上传";
        }
    }else if ([title isEqualToString:@"行业分类"]){
        self.LevelTradesView.hidden = NO;
    }
    
    self.leftTitleLabel.text = title;
    
    [self layoutSubviewsUI];
}

- (void)firstLevelTradesButtonAction:(UIButton *)sender
{
    NSLog(@"一级分类");
    [self showPickView];
}
- (void)secondLevelTradesButtonAction:(UIButton *)sender
{
    NSLog(@"二级分类");
    [self showPickView];
}
//解析默认分类
- (void)analysisIndustryLevelName
{
    if (kStringNotNull([BHUserModel sharedInstance].aptitudeOneId) && kStringNotNull([BHUserModel sharedInstance].aptitudeTwoId) && kArrayNotNull(_levelTradesArr) && kArrayNotNull(_subSourceData))
    {
        NSArray * tempSubSourceArr = [NSArray new];
        for (NSDictionary * dict in _levelTradesArr)
        {
            if ([[BHUserModel sharedInstance].aptitudeOneId isEqualToString:[dict stringValueForKey:@"id" default:@""]])
            {
                tempSubSourceArr = dict[@"child"];
                [self.firstLevelTradesButton setTitle:dict[@"name"] forState:UIControlStateNormal];
                break;
            }
        }
        for (NSDictionary * subDict in tempSubSourceArr)
        {
            if ([[BHUserModel sharedInstance].aptitudeTwoId isEqualToString:[subDict stringValueForKey:@"id" default:@""]])
            {
                [self.secondLevelTradesButton setTitle:subDict[@"name"] forState:UIControlStateNormal];
            }
        }
    }
}

- (void)lazyCreateUI
{
    if (_isCreated == YES)  return;
    // createUI
    [self.contentView addSubview:self.leftTitleLabel];
    [self.contentView addSubview:self.markLabel];
    [self.contentView addSubview:self.rightImageView];
    [self.contentView addSubview:self.rightTitleLabel];
    [self.contentView addSubview:self.textField];

    [self.LevelTradesView addSubview:self.firstLevelTradesButton];
    [self.LevelTradesView addSubview:self.firstLevelImageView];
    [self.LevelTradesView addSubview:self.secondLevelTradesButton];
    [self.LevelTradesView addSubview:self.secondLevelImageView];
    
    [self.contentView addSubview:self.LevelTradesView];
    
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
    
    [self.rightTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-15);
        make.centerY.equalTo(self.leftTitleLabel.mas_centerY);
        make.height.equalTo(@30);
        make.width.greaterThanOrEqualTo(@60);
    }];
    
    [self.textField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-15);
        make.centerY.equalTo(self.leftTitleLabel.mas_centerY);
        make.height.equalTo(@30);
        make.left.equalTo(self.leftTitleLabel.mas_right).offset(15);
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
    
    [self.LevelTradesView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-15);
        make.top.equalTo(self).offset(10);
        make.bottom.equalTo(self).offset(-10);
        make.left.equalTo(self.leftTitleLabel.mas_right);
    }];
    
    [self.secondLevelImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.LevelTradesView.mas_right);
        make.centerY.equalTo(self.LevelTradesView);
        make.height.width.equalTo(@12);
    }];
    
    [self.secondLevelTradesButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.secondLevelImageView.mas_left).offset(-5);
        make.top.equalTo(self).offset(10);
        make.bottom.equalTo(self).offset(-10);
        make.width.greaterThanOrEqualTo(@60);
    }];
    
    [self.firstLevelImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.secondLevelTradesButton.mas_left).offset(-5);
        make.centerY.equalTo(self.LevelTradesView);
        make.height.width.equalTo(@12);
    }];
    
    [self.firstLevelTradesButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.firstLevelImageView.mas_left).offset(-5);
        make.top.equalTo(self).offset(10);
        make.bottom.equalTo(self).offset(-10);
        make.width.greaterThanOrEqualTo(@60);
    }];
    
    /*
     self.secondLevelTradesButton.frame = CGRectMake(accessoryView.width-90, 0, 90, accessoryView.height);
     self.secondLevelImageView.frame = CGRectMake(self.secondLevelTradesButton.right-12, (accessoryView.height-12)/2, 12, 12);
     self.firstLevelTradesButton.frame = CGRectMake(accessoryView.width-self.secondLevelTradesButton.width-90, 0, 90, accessoryView.height);
     self.firstLevelImageView.frame = CGRectMake(self.firstLevelTradesButton.right-12, (accessoryView.height-12)/2, 12, 12);
     */
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

- (UITextField *)textField{
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.textColor = UIColorDarkBlack;
        _textField.textAlignment = NSTextAlignmentRight;
        _textField.font = [UIFont systemFontOfSize:14];
        _textField.borderStyle = UITextBorderStyleNone;
        _textField.hidden = YES;
        _textField.returnKeyType = UIReturnKeyDone;
        _textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入营业执照名称" attributes:@{NSForegroundColorAttributeName: UIColorFooderText}];
        [_textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _textField;
}

- (UILabel *)markLabel
{
    if (!_markLabel)
    {
        _markLabel = [[UILabel alloc] init];
        _markLabel.textAlignment = NSTextAlignmentCenter;
        _markLabel.textColor = UIColorDarkBlack;
        _markLabel.font = [UIFont systemFontOfSize:14];
        _markLabel.hidden = YES;
    }
    return _markLabel;
}

- (UIButton *)firstLevelTradesButton
{
    if (!_firstLevelTradesButton)
    {
        _firstLevelTradesButton = [[UIButton alloc] init];
        [_firstLevelTradesButton setTitleColor:UIColorDarkBlack forState:UIControlStateNormal];
        [_firstLevelTradesButton setTitle:@"一级分类" forState:UIControlStateNormal];
        _firstLevelTradesButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_firstLevelTradesButton addTarget:self action:@selector(firstLevelTradesButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _firstLevelTradesButton;
}
- (UIImageView *)firstLevelImageView
{
    if (!_firstLevelImageView)
    {
        _firstLevelImageView = [[UIImageView alloc] init];
        _firstLevelImageView.image = [UIImage imageNamed:@"down_triangle"];
        _firstLevelImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _firstLevelImageView;
}
- (UIButton *)secondLevelTradesButton
{
    if (!_secondLevelTradesButton)
    {
        _secondLevelTradesButton = [[UIButton alloc] init];
        [_secondLevelTradesButton setTitleColor:UIColorDarkBlack forState:UIControlStateNormal];
        [_secondLevelTradesButton setTitle:@"二级分类" forState:UIControlStateNormal];
        _secondLevelTradesButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_secondLevelTradesButton addTarget:self action:@selector(secondLevelTradesButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _secondLevelTradesButton;
}
- (UIImageView *)secondLevelImageView
{
    if (!_secondLevelImageView)
    {
        _secondLevelImageView = [[UIImageView alloc] init];
        _secondLevelImageView.image = [UIImage imageNamed:@"down_triangle"];
        _secondLevelImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _secondLevelImageView;
}

- (UIView *)LevelTradesView
{
    if (!_LevelTradesView)
    {
        _LevelTradesView = [[UIView alloc] init];
        _LevelTradesView.hidden = YES;
    }
    return _LevelTradesView;
}

-(XZPickView *)pickView{
    if(!_pickView){
        _pickView = [[XZPickView alloc]initWithFrame:[UIScreen mainScreen].bounds title:@""];
        _pickView.delegate = self;
        _pickView.dataSource = self;
    }
    return _pickView;
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
