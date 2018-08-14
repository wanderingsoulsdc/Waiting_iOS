//
//  LiteDeviceLabelDetailViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/7/12.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteDeviceLabelDetailViewController.h"
#import "Masonry.h"
#import "FSNetWorkManager.h"

@interface LiteDeviceLabelDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel        * customNumLabel;
@property (weak, nonatomic) IBOutlet UILabel        * adressLabel;
@property (weak, nonatomic) IBOutlet UITextField    * labelNameTextField;
@property (weak, nonatomic) IBOutlet UILabel        * macLabel;
@property (weak, nonatomic) IBOutlet UILabel        * timeLabel;
@property (weak, nonatomic) IBOutlet UIButton       * changeButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *changeButtonBottomConstraint;

@property (nonatomic , strong) NSString             * currentLabelName;

@end

@implementation LiteDeviceLabelDetailViewController

#pragma mark - ******* Life Cycle *******

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"标签详情";
    
    [self layoutSubviews];
    
    [self requestLabelDetail];
    
    self.changeButton.userInteractionEnabled = NO;
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - ******* UI About *******
//视图布局
- (void)layoutSubviews{
    self.changeButtonBottomConstraint.constant = SafeAreaBottomHeight;
}

#pragma mark - ******* Action Methods *******
//删除标签
- (IBAction)labelDeleteAction:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确定要移除标签?" message:@"移除的标签会进入账户内的“标签垃圾桶”,您可以在重新启用标签。" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"再看看" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }];
    [alert addAction:cancelButton];
    
    UIAlertAction *button = [UIAlertAction actionWithTitle:@"移除" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //删除标签
        [self deleteDeviceLabel];
    }];
    [alert addAction:button];
    [self presentViewController:alert animated:YES completion:nil];
}
//修改按钮
- (IBAction)changeLabelNameAction:(id)sender {
    
    if (self.labelNameTextField.text.length > 16) {
        [ShowHUDTool showBriefAlert:@"设备名称不能超过16个字符"];
        return;          // 最多16位字符
    }
    //匹配数字,字母和中文
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^[a-zA-Z0-9-_\\u4E00-\\u9FA5]+$"];
    if ([predicate evaluateWithObject:self.labelNameTextField.text]) {
        [self changeLabelName];
    }else{
        [ShowHUDTool showBriefAlert:@"标签名称不能包含特殊字符"];
    }
}

#pragma mark - ******* Request *******

//按标签id获取标签详情
- (void)requestLabelDetail{
    
    NSDictionary * params = @{@"id":self.labelModel.labelID};
    
    [FSNetWorkManager requestWithType:HttpRequestTypeGet
                        withUrlString:kApiDeviceLabelDetail
                        withParaments:params withSuccessBlock:^(NSDictionary *object) {
                            NSLog(@"请求成功");
                            
                            if (NetResponseCheckStaus){
                                NSDictionary *dataDic = object[@"data"];
                                self.customNumLabel.text = [dataDic stringValueForKey:@"personNum" default:@""];
                                self.macLabel.text = [dataDic stringValueForKey:@"mac" default:@""];
                                self.labelNameTextField.text = self.currentLabelName = [dataDic stringValueForKey:@"name" default:@""];;
                                self.timeLabel.text = [dataDic stringValueForKey:@"ctime" default:@""];;
                                self.adressLabel.text = [dataDic stringValueForKey:@"startAddress" default:@""];
                            }else{
                                [ShowHUDTool showBriefAlert:NetResponseMessage];
                            }
                        } withFailureBlock:^(NSError *error) {
                            NSLog(@"error is %@", error);
                            [ShowHUDTool showBriefAlert:NetRequestFailed];
                        }];
}
//删除标签
- (void)deleteDeviceLabel{
    
    [FSNetWorkManager requestWithType:HttpRequestTypePost
                        withUrlString:kApiDeviceLabelUpdateDelete
                        withParaments:@{@"id":self.labelModel.labelID,@"status":@"2"}
                     withSuccessBlock:^(NSDictionary *object) {
                         NSLog(@"请求成功");
                         if (NetResponseCheckStaus){
                             if ([self.delegate respondsToSelector:@selector(deleteLabelSuccess:)]) {
                                 [self.delegate deleteLabelSuccess:self.labelModel];
                             }
                             [self.navigationController popViewControllerAnimated:YES];
                         }else{
                             [ShowHUDTool showBriefAlert:NetResponseMessage];
                         }
                     } withFailureBlock:^(NSError *error) {
                         NSLog(@"error is %@", error);
                         [ShowHUDTool showBriefAlert:NetRequestFailed];
                     }];
}

//修改标签名称
- (void)changeLabelName{
    
    self.changeButton.userInteractionEnabled = NO;
    
    NSDictionary * params = @{@"id":self.labelModel.labelID,@"name":self.labelNameTextField.text};
    
    [FSNetWorkManager requestWithType:HttpRequestTypePost
                        withUrlString:kApiEditDeviceLabel
                        withParaments:params withSuccessBlock:^(NSDictionary *object) {
                            NSLog(@"请求成功");
                            self.changeButton.userInteractionEnabled = YES;
                            
                            if (NetResponseCheckStaus){
                                [ShowHUDTool showBriefAlert:@"标签名称修改成功"];
                                self.labelModel.name = self.currentLabelName = self.labelNameTextField.text;
                                self.changeButton.userInteractionEnabled = NO;
                                self.changeButton.backgroundColor = UIColorlightGray;
                                if ([self.delegate respondsToSelector:@selector(changeLabelNameSuccess:)]) {
                                    [self.delegate changeLabelNameSuccess:self.labelModel];
                                }
                            }else{
                                [ShowHUDTool showBriefAlert:NetResponseMessage];
                            }
                        } withFailureBlock:^(NSError *error) {
                            NSLog(@"error is %@", error);
                            self.changeButton.userInteractionEnabled = YES;
                            [ShowHUDTool showBriefAlert:NetRequestFailed];
                        }];
}

#pragma mark - ******* Textfield Delegate *******

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@" "])
    {
        return NO;
    }
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (IBAction)textFieldDidChange:(UITextField *)sender {
    NSLog(@"%@",sender.text);
    if ([self.currentLabelName isEqualToString:sender.text]) { //和之前一样
        self.changeButton.userInteractionEnabled = NO;
        self.changeButton.backgroundColor = UIColorlightGray;
    } else {
        self.changeButton.userInteractionEnabled = YES;
        self.changeButton.backgroundColor = UIColorBlue;
    }
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
