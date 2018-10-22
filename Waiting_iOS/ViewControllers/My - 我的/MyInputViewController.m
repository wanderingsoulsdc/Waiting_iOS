//
//  MyInputViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/9/16.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "MyInputViewController.h"
#import "MyInterestCell.h"

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

//爱好
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * interestTableViewBottomConstraint; //爱好选择tableview距下约束
@property (weak, nonatomic) IBOutlet UITableView * interestTableView;
@property (nonatomic , strong) NSMutableArray   * interestSelectArr; //兴趣选择数组


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
    self.interestTableViewBottomConstraint.constant = SafeAreaBottomHeight;
    [self.interestTableView registerNib:[UINib nibWithNibName:NSStringFromClass([MyInterestCell class]) bundle:nil] forCellReuseIdentifier:@"MyInterestCell"];
    
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
            self.manLabel.text = ZBLocalized(@"Male", nil);
            self.wemanLabel.text = ZBLocalized(@"Female", nil);
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
                [genderDic setObject:ZBLocalized(@"Male", nil) forKey:@"value"];
                [genderDic setObject:@"1" forKey:@"key"];
            } else {
                [genderDic setObject:ZBLocalized(@"Female", nil) forKey:@"value"];
                [genderDic setObject:@"0" forKey:@"key"];
            }
            [self.delegate inputGenderSelectResult:genderDic];
        }
    }
    
    if (self.inputType == MyInputTypeInterest) {
        if ([self.delegate respondsToSelector:@selector(inputHobbySelectResult:)]) {
            [self.delegate inputHobbySelectResult:self.interestSelectArr];
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - ******* UITableView Delegate *******

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.interestArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"MyInterestCell";
    MyInterestCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"MyInterestCell" owner:nil options:nil].firstObject;
        NSLog(@"cell create at row:%ld", (long)indexPath.row);//此处要使用loadnib方式！
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary * dic = self.interestArr[indexPath.row];
    [cell configWithData:dic];
    
    if ([self.interestSelectArr containsObject:dic]) {
        [cell cellBecomeSelected];
    }else{ //选择该标签
        [cell cellBecomeUnselected];
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01f;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyInterestCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    NSDictionary * dic = [self.interestArr objectAtIndex:indexPath.row];
    
    if ([self.interestSelectArr containsObject:dic]) { //删除选择
        [cell cellBecomeUnselected];
        //记录选择数组删除该标签
        [self.interestSelectArr removeObject:dic];
    }else{ //选择该标签
        if (self.interestSelectArr.count < 3) {
            [cell cellBecomeSelected];
            [self.interestSelectArr addObject:dic];
        }
        //记录选择数组添加该标签
    }
    NSLog(@"点击了cell");
}


#pragma mark - ******* Textfield Delegate *******

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

#pragma mark - ******* Getter *******

- (NSMutableArray *)interestSelectArr
{
    if (!_interestSelectArr)
    {
        _interestSelectArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _interestSelectArr;
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
