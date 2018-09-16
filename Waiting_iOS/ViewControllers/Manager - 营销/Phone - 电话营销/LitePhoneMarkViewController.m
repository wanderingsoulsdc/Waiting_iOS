//
//  LitePhoneMarkViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/7/25.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LitePhoneMarkViewController.h"
#import "UITextView+Placeholder.h"
 
#import "FSNetWorkManager.h"
#import "Masonry.h"

@interface LitePhoneMarkViewController ()<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel    *phoneLabel;
@property (weak, nonatomic) IBOutlet UIButton   *confirmButton;
@property (weak, nonatomic) IBOutlet UIButton   *cancelButton;
@property (weak, nonatomic) IBOutlet UIView     *textBackView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contactServiceBottomConstraint;

@property (nonatomic , strong) NSString         * markString;//标记字符串
@property (nonatomic , strong) UITextView       * textView;  //备注

@property (weak, nonatomic) id<UIGestureRecognizerDelegate> restoreInteractivePopGestureDelegate;  //记录侧滑手势

@end

@implementation LitePhoneMarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"通话标记";
    self.view.backgroundColor = UIColorWhite;
    
    self.navigationItem.hidesBackButton = YES;
    //记录侧滑返回
    _restoreInteractivePopGestureDelegate = self.navigationController.interactivePopGestureRecognizer.delegate;

    
    [self createUI];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = _restoreInteractivePopGestureDelegate;
    };
    
    if (kStringNotNull(self.markString)) {
        self.phoneModel.mark = self.markString;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kPhoneMarkOperationNotification object:self.phoneModel];
}

#pragma mark - ******* UIGestureRecognizer Delegate *******

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return NO;
}

#pragma mark - ******* UI Methods *******

- (void)createUI{
    
    self.contactServiceBottomConstraint.constant = 20 + SafeAreaBottomHeight;
    
    self.phoneLabel.text = self.phoneModel.phone;
    
    _textView = [[UITextView alloc] init];
    _textView.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"您可以在此处输入备注信息" attributes:@{NSForegroundColorAttributeName: UIColorlightGray}];
    _textView.textColor = UIColorDarkBlack;
    _textView.textAlignment = NSTextAlignmentCenter;
    _textView.font = [UIFont systemFontOfSize:14];
    [_textView setContentInset:UIEdgeInsetsMake(0, 5 , 0 , 5)];//设置UITextView的内边距
    
    /**
     * 按照上面的操作 按钮的内容对津贴屏幕左边缘 不美观 可以添加一下代码实现间隔已达到美观
     * UIEdgeInsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right)
     *    top: 为正数：表示向下偏移  为负数：表示向上偏移
     *   left: 为正数：表示向右偏移  为负数：表示向左偏移
     * bottom: 为正数：表示向上偏移  为负数：表示向下偏移
     *  right: 为正数：表示向左偏移  为负数：表示向右偏移
     *
     **/
    
    _textView.layoutManager.allowsNonContiguousLayout = NO;
    _textView.scrollEnabled = YES;  //  如果scrollEnabled=NO，计算出来的还是不正确的，这里虽然设置为YES，但textView实际并不会滚动，并正确显示出来内容
    _textView.delegate = self;
    
    [self.textBackView addSubview:_textView];
    [_textView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.centerY.equalTo(self.textBackView);
        make.height.greaterThanOrEqualTo(@60);
    }];
    
    _confirmButton.layer.cornerRadius = 3;
    _confirmButton.layer.masksToBounds = YES;
    
    _cancelButton.layer.borderWidth = 1;
    _cancelButton.layer.borderColor = UIColorBlue.CGColor;
    _cancelButton.layer.cornerRadius = 3;
    _cancelButton.layer.masksToBounds = YES;
    
    _textBackView.layer.borderWidth = 1;
    _textBackView.layer.borderColor = UIColorlightGray.CGColor;
    _textBackView.layer.cornerRadius = 3;
    _textBackView.layer.masksToBounds = YES;
}

#pragma mark - ******* TextView Delegate *******

- (void)textViewDidChange:(UITextView *)textView
{

}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text {
    NSMutableString * str = [NSMutableString stringWithString:textView.text];
    [str replaceCharactersInRange:range withString:text];
    if (str.length > 60)
    {
        return NO;
    }
    return YES;
}

#pragma mark - ******* Request Methods *******
//添加标记
- (void)requestAddPhoneMark{
    WEAKSELF
    NSDictionary * params = @{@"cipherPhone":self.phoneModel.cipherPhone,@"signType":self.markString,@"content":self.textView.text,@"logId":self.logId,@"logTime":self.logTime};
    
    [FSNetWorkManager requestWithType:HttpRequestTypePost
                        withUrlString:kApiPhoneAddMark
                        withParaments:params withSuccessBlock:^(NSDictionary *object) {
                            NSLog(@"请求成功");
                            
                            if (NetResponseCheckStaus){
                                
                                [weakSelf.navigationController popViewControllerAnimated:YES];
                            }else{
                                [ShowHUDTool showBriefAlert:NetResponseMessage];
                            }
                        } withFailureBlock:^(NSError *error) {
                            
                            [ShowHUDTool showBriefAlert:NetRequestFailed];
                        }];
}

#pragma mark - ******* Action Methods *******

- (IBAction)confirmButtonAction:(UIButton *)sender {
    if (!kStringNotNull(self.markString)) {
        [ShowHUDTool showBriefAlert:@"请选择标记状态"];
        return;
    }
    
    if (self.textView.text.length > 30) {
        [ShowHUDTool showBriefAlert:@"备注信息不能超过30个字"];
        return;
    }
    
    [self requestAddPhoneMark];
    
}
- (IBAction)cancelButtonAction:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)markButtonSelect:(UIButton *)sender {
    if (sender.selected) {
        return;
    }else{
        for (int i = 0; i < 4; i++) {
            UIButton *button = [self.view viewWithTag:100 + i];
            button.selected = NO;
        }
        sender.selected = YES;
        switch (sender.tag) {
            case 100://有意向
                self.markString = @"1";
                break;
            case 101://无意向
                self.markString = @"6";
                break;
            case 102://空号
                self.markString = @"4";
                break;
            case 103://未接通
                self.markString = @"3";
                break;
            default:
                break;
        }
    }
}
- (IBAction)contactServiceAction:(UIButton *)sender {
      
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
