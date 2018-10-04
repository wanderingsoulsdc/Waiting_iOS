//
//  MyRechargeViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/8/28.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "MyRechargeViewController.h"
#import "FSNetWorkManager.h"
// 1.首先导入支付包
#import <StoreKit/StoreKit.h>
#import "BHUserModel.h"

@interface MyRechargeViewController ()<SKPaymentTransactionObserver,SKProductsRequestDelegate>

@property (weak , nonatomic) IBOutlet NSLayoutConstraint * topViewTopConstraint; //顶部视图 距上约束
@property (weak , nonatomic) IBOutlet UILabel    * diamondLabel;     //钻石
@property (weak , nonatomic) IBOutlet UIButton   * MoneyOneButton;
@property (weak , nonatomic) IBOutlet UIButton   * MoneyTwoButton;
@property (weak , nonatomic) IBOutlet UIButton   * MoneyThreeButton;
@property (weak , nonatomic) IBOutlet UIButton   * MoneyFourButton;
@property (weak , nonatomic) IBOutlet UIButton   * MoneyFiveButton;
@property (weak , nonatomic) IBOutlet UIButton   * MoneySixButton;
@property (weak , nonatomic) IBOutlet UIButton   * MoneySevenButton;
@property (weak , nonatomic) IBOutlet UIButton   * MoneyEightButton;
@property (weak , nonatomic) IBOutlet UIButton   * MoneyNineButton;

@property (nonatomic , strong) UIButton * currentSelectButton;
@property (nonatomic , strong) NSString * currentSelectMoney;
@property (nonatomic , strong) NSString * currentProductID;
@property (nonatomic , strong) NSString * currentSelectDiamond;

@property (nonatomic , strong) NSArray  * chargeDataArr;


@end

@implementation MyRechargeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self createUI];
    [self requestAccountData];
    
    [self requestChargeData];
    // 4.设置支付服务
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

#pragma mark - ******* UI Methods *******

- (void)createUI{
    self.topViewTopConstraint.constant = kStatusBarHeight;
}

#pragma mark - ******* Action Methods *******

- (IBAction)moneySelectAction:(UIButton *)sender {

    if (sender == self.currentSelectButton) {
        return;
    }
    
    sender.layer.borderWidth = 1.5f;
    sender.layer.borderColor = UIColorFromRGB(0x9014FC).CGColor;
    
    NSDictionary *dataDic = self.chargeDataArr[sender.tag - 100];
    
    self.currentSelectDiamond = dataDic[@"name"];
    self.currentSelectMoney = dataDic[@"HKD"];
    self.currentProductID = dataDic[@"gid"];
    
    
    self.currentSelectButton.layer.borderWidth = 0.5f;
    self.currentSelectButton.layer.borderColor = UIColorFromRGB(0xE0E0E0).CGColor;
    
    self.currentSelectButton = sender;
}
- (IBAction)confirmButtonAction:(UIButton *)sender {
    
    NSLog(@"充值金额-> %@   会得到的钻石-> %@",self.currentSelectMoney,self.currentSelectDiamond);
    
    // 5.点击按钮的时候判断app是否允许apple支付
    //如果app允许applepay
    if ([SKPaymentQueue canMakePayments]) {
        NSLog(@"yes");
        
        // 6.请求苹果后台商品
        [self getRequestAppleProduct];
    }
    else
    {
        NSLog(@"not");
    }
    
}
- (IBAction)backAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - ******* Pravite *******
//设置按钮显示
- (void)setDiamond:(NSString *)diamond Money:(NSString *)money ForButton:(UIButton *)button{
    //第一行
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ",diamond] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16], NSForegroundColorAttributeName:UIColorFromRGB(0x9014FC)}];
    //钻石图
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = [UIImage imageNamed:@"my_diamond"];
    attachment.bounds = CGRectMake(0, -2, 16, 16);
    NSAttributedString *imageAttributed = [NSAttributedString attributedStringWithAttachment:attachment];
    [title appendAttributedString:imageAttributed];
    //第二行
    NSAttributedString *time = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@",money] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:UIColorFromRGB(0x666666)}];
    
    [title appendAttributedString:time];
    //段落设置
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    [paraStyle setLineSpacing:8]; //行距
    paraStyle.alignment = NSTextAlignmentCenter;
    [title addAttributes:@{NSParagraphStyleAttributeName:paraStyle} range:NSMakeRange(0, title.length)];
    
    button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [button setAttributedTitle:title forState:UIControlStateNormal];
    [button setAttributedTitle:title forState:UIControlStateSelected];
    
    button.layer.borderWidth = 0.5f;
    button.layer.borderColor = UIColorFromRGB(0xE0E0E0).CGColor;
}
//从接口得到数据后刷新充值页面
- (void)refreshData{
    for (int i = 0; i < self.chargeDataArr.count; i++) {
        NSDictionary *dataDic = self.chargeDataArr[i];
        UIButton *button = [self.view viewWithTag:100+i];
        button.hidden = NO;
        //设置金额
        [self setDiamond:dataDic[@"coin"] Money:dataDic[@"HKD"] ForButton:button];
    }
}

//请求苹果商品
- (void)getRequestAppleProduct
{
    [ShowHUDTool showLoading];
    // 7.这里的 self.currentProductID 就对应着苹果后台的商品ID,他们是通过这个ID进行联系的。
    NSArray *product = [[NSArray alloc] initWithObjects:self.currentProductID,nil];
    
    NSSet *nsset = [NSSet setWithArray:product];
    
    // 8.初始化请求
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:nsset];
    request.delegate = self;
    
    // 9.开始请求
    [request start];
}

// 10.接收到产品的返回信息,然后用返回的商品信息进行发起购买请求
- (void) productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"-----------收到产品反馈信息--------------");
    [ShowHUDTool hideAlert];
    
    NSArray *product = response.products;
    NSLog(@"产品Product ID:%@",response.invalidProductIdentifiers);
    NSLog(@"产品付费数量: %d", (int)[product count]);
    
    //如果服务器没有产品
    if([product count] == 0){
        NSLog(@"nothing");
        [ShowHUDTool showBriefAlert:@"拉取支付信息失败"];
        return;
    }
    
    SKProduct *requestProduct = nil;
    for (SKProduct *pro in product) {
        
        NSLog(@"product info");
        NSLog(@"SKProduct 描述信息%@", [pro description]);
        NSLog(@"产品标题 %@" , [pro localizedTitle]);
        NSLog(@"产品描述信息: %@" , [pro localizedDescription]);
        NSLog(@"价格: %@" , [pro price]);
        NSLog(@"Product id: %@" , [pro productIdentifier]);
        
        // 11.如果后台消费条目的ID与我这里需要请求的一样（用于确保订单的正确性）
        if([pro.productIdentifier isEqualToString:self.currentProductID]){
            requestProduct = pro;
        }
    }
    
    // 12.发送购买请求
    SKPayment *payment = [SKPayment paymentWithProduct:requestProduct];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    [ShowHUDTool showLoading];
}

//请求失败
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    NSLog(@"error:%@", error);
    [ShowHUDTool hideAlert];
    [ShowHUDTool showBriefAlert:@"购买请求发送失败"];
}

//反馈请求的产品信息结束后
- (void)requestDidFinish:(SKRequest *)request{
    NSLog(@"信息反馈结束");
}

// 13.监听购买结果
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transaction{
    for(SKPaymentTransaction *tran in transaction){
        
        switch (tran.transactionState) {
            case SKPaymentTransactionStatePurchased:
                NSLog(@"交易完成");
                [self completeTransaction:tran];
                break;
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"商品添加进列表");
                
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"已经购买过商品");
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
                [ShowHUDTool hideAlert];
                break;
            case SKPaymentTransactionStateFailed:
                NSLog(@"交易失败");
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
                [ShowHUDTool hideAlert];
                [ShowHUDTool showBriefAlert:@"交易失败"];
                break;
            default:
                break;
        }
    }
}

// 14.交易结束,当交易结束后还要去appstore上验证支付信息是否都正确,只有所有都正确后,我们就可以给用户方法我们的虚拟物品了。
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    NSString * str = [[NSString alloc] initWithData:transaction.transactionReceipt encoding:NSUTF8StringEncoding];
    
    NSString *environment=[self environmentForReceipt:str];
    NSLog(@"----- 完成交易调用的方法completeTransaction 1--------%@",environment);
    
    
    // 验证凭据，获取到苹果返回的交易凭据
    // appStoreReceiptURL iOS7.0增加的，购买交易完成后，会将凭据存放在该地址
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    // 从沙盒中获取到购买凭据
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
    /**
     20      BASE64 常用的编码方案，通常用于数据传输，以及加密算法的基础算法，传输过程中能够保证数据传输的稳定性
     21      BASE64是可以编码和解码的
     22      */
    NSString *encodeStr = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
    NSString *sendString = [NSString stringWithFormat:@"{\"receipt-data\" : \"%@\"}", encodeStr];
    NSLog(@"_____%@",sendString);
    NSURL *StoreURL=nil;
    if ([environment isEqualToString:@"environment=Sandbox"]) {
        
        StoreURL= [[NSURL alloc] initWithString: @"https://sandbox.itunes.apple.com/verifyReceipt"];
    }
    else{
        
        StoreURL= [[NSURL alloc] initWithString: @"https://buy.itunes.apple.com/verifyReceipt"];
    }
    //这个二进制数据由服务器进行验证；zl
    NSData *postData = [NSData dataWithBytes:[sendString UTF8String] length:[sendString length]];
    
    NSLog(@"++++++%@",postData);
    NSMutableURLRequest *connectionRequest = [NSMutableURLRequest requestWithURL:StoreURL];
    
    [connectionRequest setHTTPMethod:@"POST"];
    [connectionRequest setTimeoutInterval:50.0];//120.0---50.0zl
    [connectionRequest setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    [connectionRequest setHTTPBody:postData];
    
    //开始请求
    NSError *error=nil;
    NSData *responseData=[NSURLConnection sendSynchronousRequest:connectionRequest returningResponse:nil error:&error];
    if (error) {
        [ShowHUDTool hideAlert];
        NSLog(@"验证购买过程中发生错误，错误信息：%@",error.localizedDescription);
        return;
    }
    NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
    NSLog(@"请求成功后的数据:%@",dic);
    //这里可以等待上面请求的数据完成后并且state = 0 验证凭据成功来判断后进入自己服务器逻辑的判断,也可以直接进行服务器逻辑的判断,验证凭据也就是一个安全的问题。楼主这里没有用state = 0 来判断。
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    NSString *product = transaction.payment.productIdentifier;
    
    NSLog(@"transaction.payment.productIdentifier++++%@",product);
    
    if ([product length] > 0){
        NSArray *tt = [product componentsSeparatedByString:@"."];
        NSString *bookid = [tt lastObject];
        if([bookid length] > 0)
        {   NSLog(@"打印bookid%@",bookid);
            //这里可以做操作 把用户对应的虚拟物品通过自己服务器进行下发操作 , 或者在这里通过判断得到用户将会得到多少虚拟物品
            //在后面（[self getApplePayDataToServerRequsetWith:transaction];的地方）上传上面自己的服务器。
        }
    }
    //此方法为将这一次操作上传给我本地服务器,记得在上传成功过后一定要记得销毁本次操作。
    //调用[[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    [self getApplePayDataToServerRequsetWith:transaction];
}

-(NSString * )environmentForReceipt:(NSString * )str
{
    str= [str stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    str = [str stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    
    str=[str stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    str=[str stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    NSArray * arr=[str componentsSeparatedByString:@";"];
    
    //存储收据环境的变量
    NSString * environment=arr[2];
    return environment;
}


#pragma mark - ******* Request *******
//获取充值数据列表
- (void)requestChargeData{
    WEAKSELF
    NSDictionary * params = @{};
    
    [FSNetWorkManager requestWithType:HttpRequestTypePost
                        withUrlString:kApiAccountGetChargeData
                        withParaments:params withSuccessBlock:^(NSDictionary *object) {
                            NSLog(@"请求成功");
                            
                            if (NetResponseCheckStaus){
                                weakSelf.chargeDataArr = object[@"data"];
                                [weakSelf refreshData];
                            }else{
                                [ShowHUDTool showBriefAlert:NetResponseMessage];
                            }
                        } withFailureBlock:^(NSError *error) {
                            [ShowHUDTool showBriefAlert:NetRequestFailed];
                            [self.navigationController popViewControllerAnimated:YES];
                        }];
}

//与服务器做充值校验,成功刷新钻石
- (void)getApplePayDataToServerRequsetWith:(SKPaymentTransaction *)transaction{
    
//    //初始化为合法
//    if (transaction.payment.productIdentifier !=nil) {
//
//        // 验证凭据，获取到苹果返回的交易凭据
//        // appStoreReceiptURL iOS7.0增加的，购买交易完成后，会将凭据存放在该地址
//        NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
//        // 从沙盒中获取到购买凭据
//        NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
//        /**
//         20      BASE64 常用的编码方案，通常用于数据传输，以及加密算法的基础算法，传输过程中能够保证数据传输的稳定性
//         21      BASE64是可以编码和解码的
//         22      */
//        NSString *receiptStr = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
//
//
//        //将数据http post请求发送到我的服务器
//        NSURL* url = [NSURL URLWithString:kApiAccountDoRecharge];
//        NSMutableURLRequest * theRequest = [NSMutableURLRequest requestWithURL:url];
//        [theRequest setHTTPMethod:@"POST"];
//        [theRequest addValue:[BHUserModel sharedInstance].token forHTTPHeaderField:@"token"];
//
//        NSString * sendString = [NSString stringWithFormat:@"gid=%@&state=%ld&transaction=%@&receipt=%@&payment=%@",transaction.payment.productIdentifier,(long)transaction.transactionState,transaction.transactionIdentifier,receiptStr,@"apple"];
//        NSLog(@"+++sendString:%@+++",sendString);
//
//        [theRequest setHTTPBody:[NSData dataWithBytes:[sendString UTF8String] length:[sendString length]]];
//
//        //发送同步请求  因为你将使用自己的服务器返回的数据来判断是否成功
//        NSURLResponse   * response = [[NSURLResponse alloc] init];
//        NSError         * error =  [[NSError alloc] init];
//        NSMutableData   * receiveData = (NSMutableData *)[NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
//
//        if (error)
//        {   // 超时或无网络
//            //验证失败
//            return;
//        }
//
//        // json解析
//        NSDictionary *object = [NSJSONSerialization JSONObjectWithData:receiveData
//                                                               options:NSJSONReadingAllowFragments
//                                                                 error:nil];
//        if (NetResponseCheckStaus){
//            NSLog(@"验证成功");
//            [ShowHUDTool showBriefAlert:NetResponseMessage];
//            [self requestAccountData];
//        }else{
//            NSLog(@"服务状态验证未通过");
//        }
//    }
//    else
//    {
//        NSLog(@"无效的商品ID");
//    }

    
    
    
    
    
    
    // 验证凭据，获取到苹果返回的交易凭据
    // appStoreReceiptURL iOS7.0增加的，购买交易完成后，会将凭据存放在该地址
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    // 从沙盒中获取到购买凭据
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
    /**
     20      BASE64 常用的编码方案，通常用于数据传输，以及加密算法的基础算法，传输过程中能够保证数据传输的稳定性
     21      BASE64是可以编码和解码的
     22      */
    NSString *receiptStr = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];

    WEAKSELF
    NSDictionary * params = @{@"gid":transaction.payment.productIdentifier,
                              @"state":[NSString stringWithFormat:@"%ld",transaction.transactionState],
                              @"transaction":transaction.transactionIdentifier,
                              @"receipt":receiptStr,
                              @"payment":@"apple"
                              };
    [FSNetWorkManager requestWithType:HttpRequestTypePost
                        withUrlString:kApiAccountDoRecharge
                        withParaments:params
                     withSuccessBlock:^(NSDictionary *object) {

                         if (NetResponseCheckStaus)
                         {
                             NSLog(@"请求成功");
                             [ShowHUDTool hideAlert];
                             [ShowHUDTool showBriefAlert:NetResponseMessage];
                             [weakSelf requestAccountData];
                         }
                         else
                         {
                             [ShowHUDTool hideAlert];
                             [ShowHUDTool showBriefAlert:NetResponseMessage];
                         }
                     } withFailureBlock:^(NSError *error) {
                         NSLog(@"error is:%@", error);
                         [ShowHUDTool hideAlert];
                         [ShowHUDTool showBriefAlert:NetRequestFailed];
                     }];
}

//请求账户数据获得钻石数量
- (void)requestAccountData
{
    WEAKSELF
    [FSNetWorkManager requestWithType:HttpRequestTypePost
                        withUrlString:kApiAccountGetAccountData
                        withParaments:nil
                     withSuccessBlock:^(NSDictionary *object) {
                         
                         if (NetResponseCheckStaus)
                         {
                             NSLog(@"请求成功");
                             NSDictionary *dic = object[@"data"][@"account"];
                             [BHUserModel sharedInstance].diamond = [dic stringValueForKey:@"usable" default:@"0"];
                             weakSelf.diamondLabel.text = [BHUserModel sharedInstance].diamond;
                         }
                         else
                         {
                             [ShowHUDTool showBriefAlert:NetResponseMessage];
                         }
                     } withFailureBlock:^(NSError *error) {
                         NSLog(@"error is:%@", error);
                         [ShowHUDTool showBriefAlert:NetRequestFailed];
                     }];
}

#pragma mark - ******* Getter *******

//结束后一定要销毁
- (void)dealloc
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
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
