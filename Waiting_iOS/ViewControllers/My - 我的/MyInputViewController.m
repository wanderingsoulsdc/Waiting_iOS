//
//  MyInputViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/9/16.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "MyInputViewController.h"

@interface MyInputViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint * topViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel    * titleLabel; //页面标题
@property (weak, nonatomic) IBOutlet UITextField * textfield; //用户名
@property (weak, nonatomic) IBOutlet UITextView * textView; //个人描述等

@property (weak, nonatomic) IBOutlet UIView     * nameView;  //名称等输入
@property (weak, nonatomic) IBOutlet UIView     * describeView; //描述等输入
@property (weak, nonatomic) IBOutlet UIView     * genderView;  //性别
@property (weak, nonatomic) IBOutlet UIView     * interestView; //爱好

//性别
@property (weak, nonatomic) IBOutlet UILabel    * manLabel;
@property (weak, nonatomic) IBOutlet UIButton   * manButton;
@property (weak, nonatomic) IBOutlet UIButton   * selectManButton;

@property (weak, nonatomic) IBOutlet UILabel    * wemanLabel;
@property (weak, nonatomic) IBOutlet UIButton   * wemanButton;
@property (weak, nonatomic) IBOutlet UIButton   * selectWemanButton;



@end

@implementation MyInputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
    
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - ******* UI Methods *******

- (void)createUI{
    self.topViewHeightConstraint.constant = kStatusBarAndNavigationBarHeight;
    
    if (kStringNotNull(self.titleStr)) {
        self.titleLabel.text = self.titleStr;
    }
    
    switch (self.inputType) {
        case MyInputTypeTextField:
            self.nameView.hidden = NO;
            break;
        case MyInputTypeTextView:
            self.describeView.hidden = NO;
            break;
        case MyInputTypeGender:
        {
            self.genderView.hidden = NO;
            self.manLabel.text = @"男";
            self.wemanLabel.text = @"女";
        }
            break;
        case MyInputTypeInterest:
            self.interestView.hidden = NO;
            break;
        default:
            break;
    }
}

#pragma mark - ******* Pravite Methods *******

//字符串长度转化为“字符”数
- (NSUInteger)stringLengthToCharacterNum:(NSString *)name{
    NSUInteger  character = 0;
    for(int i=0; i< [name length];i++){
        int a = [name characterAtIndex:i];
        if( a >= 0x2E80 && a <= 0x9FFF){ //判断是否为中日韩文字
            character +=2;
        }else{
            character +=1;
        }
    }
    
    return character;
    
}

#pragma mark - ******* Action *******
//选择性别
- (IBAction)selectGender:(UIButton *)button{
    
    if (button == self.selectManButton || button == self.manButton) {
        self.manButton.selected = YES;
        self.wemanButton.selected = NO;
        NSLog(@"选择男性");
    }else{
        self.manButton.selected = NO;
        self.wemanButton.selected = YES;
        NSLog(@"选择女性");
    }
}
//返回
- (IBAction)backButtonAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//右上角确认
- (IBAction)confirmButtonAction:(UIButton *)sender {
    
    if (self.inputType == MyInputTypeTextField) {
        if ([self.delegate respondsToSelector:@selector(inputResultString:inputType:)]) {
            [self.delegate inputResultString:self.textfield.text inputType:self.inputType];
        }
    }
    
    if(self.inputType == MyInputTypeTextView){
        if ([self.delegate respondsToSelector:@selector(inputResultString:inputType:)]) {
            [self.delegate inputResultString:self.textView.text inputType:self.inputType];
        }
    }
    
    if (self.inputType == MyInputTypeGender) {
        if ([self.delegate respondsToSelector:@selector(inputGenderSelectResult:)]) {
            NSMutableDictionary * genderDic = [[NSMutableDictionary alloc] init];
            if (self.manButton.selected) {
                [genderDic setObject:@"男" forKey:@"value"];
                [genderDic setObject:@"1" forKey:@"key"];
            } else {
                [genderDic setObject:@"女" forKey:@"value"];
                [genderDic setObject:@"0" forKey:@"key"];
            }
            [self.delegate inputGenderSelectResult:genderDic];
        }
    }
    
    if (self.inputType == MyInputTypeInterest) {
        
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - textfieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * content = [NSString stringWithFormat:@"%@%@",textField.text,string];
    
    if([self stringLengthToCharacterNum:content] > 32){ //最多输入32个字符
        return NO;
    }
    
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - ******* TextView Delegate *******

- (void)textViewDidChange:(UITextView *)textView
{
    
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text {
    
    NSMutableString * content = [NSMutableString stringWithString:textView.text];
    [content replaceCharactersInRange:range withString:text];
    
    if([self stringLengthToCharacterNum:content] > 100){ //最多输入100个字符
        return NO;
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
