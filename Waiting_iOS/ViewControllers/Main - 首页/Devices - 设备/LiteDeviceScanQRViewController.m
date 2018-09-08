//
//  LiteDeviceScanQRViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/6/29.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteDeviceScanQRViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "KSScanQRCodeView.h"
#import "UIViewController+NavigationItem.h"
#import "FSNetWorkManager.h"
#import <Masonry/Masonry.h>
#import "NSString+Helper.h"
#import "FSDeviceManager.h"
#import "BHUserModel.h"
#import "LiteDeviceEditNameViewController.h"

@interface LiteDeviceScanQRViewController ()<AVCaptureMetadataOutputObjectsDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) AVCaptureDevice * device;
@property (strong, nonatomic) AVCaptureDeviceInput * input;
@property (strong, nonatomic) AVCaptureMetadataOutput * output;
@property (strong, nonatomic) AVCaptureSession * session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer * preview;
@property (strong, nonatomic) KSScanQRCodeView  *scanQRCodeV;

@property (nonatomic , strong) UIView           *navView;
@property (nonatomic , strong) UIButton         *backButton;
@property (nonatomic , strong) UILabel          *midTitleLabel;
@property (nonatomic , strong) UILabel          *bottomTitleLabel;

@end

@implementation LiteDeviceScanQRViewController

#pragma mark - Class Method

// 判断是否有打开摄像头的权限
- (BOOL)checkPermissions
{
    NSString * mediaType = AVMediaTypeVideo;
    
    AVAuthorizationStatus  authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    
    if (authorizationStatus == AVAuthorizationStatusRestricted|| authorizationStatus == AVAuthorizationStatusDenied) {
        
        //        [ShowHUDTool showHUDWithImageWithTitle:@"摄像头访问受限"];
        UIAlertView * alertView=[[UIAlertView alloc]initWithTitle:@"摄像头访问受限" message:@"请在设备的'设置-隐私-相机'中允许访问相机" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        // 展示出来
        [alertView show];
        
        return NO;
        
    }
    else if (authorizationStatus == AVAuthorizationStatusNotDetermined)
    {
        WEAKSELF;
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
            STRONGSELF;
            if (granted)
            {
                NSLog(@"Granted access to %@", mediaType);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf defaultConfiguration];
                });
            }
            else
            {
                NSLog(@"Not granted access to %@", mediaType);
            }
        }];
        return NO;
    }
    else{
        return YES;
    }
}

// 生成二维码
+ (UIImage *)outputQRCodeImgWithText:(NSString *)text size:(CGFloat)size{
    
    // 生成二维码
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKey:@"inputMessage"];
    CIImage *image = [filter outputImage];
    
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    //原图
    UIImage *outputImage = [UIImage imageWithCGImage:scaledImage];
    UIGraphicsBeginImageContextWithOptions(outputImage.size, NO, [[UIScreen mainScreen] scale]);
    [outputImage drawInRect:CGRectMake(0,0 , size, size)];
    
    return outputImage;
}

#pragma mark - Life circle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.delegate = self;
    self.view.backgroundColor = [UIColor blackColor];

//    [self setLeftBarButtonTarget:self Action:@selector(leftBarButtonAction:) Title:@"取消"];
    
#if TARGET_IPHONE_SIMULATOR//模拟器
    
#elif TARGET_OS_IPHONE//真机
    [self defaultConfiguration];
#endif
    
    self.title = @"添加设备";
    
    [self.view addSubview:self.navView];
    [self.navView addSubview:self.backButton];
    [self.navView addSubview:self.midTitleLabel];
    [self.view addSubview:self.scanQRCodeV];
    [self.view addSubview:self.bottomTitleLabel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    // layout subviews
    [self layoutSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//    UINavigationBar *navigationBar = self.navigationController.navigationBar;
//    navigationBar.barTintColor = UIColorFromRGB(0x302C2C);
//    navigationBar.tintColor = UIColorWhite;
//    [navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
//                                            UIColorWhite, NSForegroundColorAttributeName, [UIFont systemFontOfSize:17], NSFontAttributeName, nil]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

//    UINavigationBar *navigationBar = self.navigationController.navigationBar;
//    navigationBar.barTintColor = [UIColor whiteColor];
//    navigationBar.tintColor = UIColorDarkBlack;
//    [navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
//                                            UIColorDarkBlack, NSForegroundColorAttributeName, [UIFont systemFontOfSize:17], NSFontAttributeName, nil]];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.session startRunning];
}

- (void)layoutSubviews {
    //You should set subviews constrainsts or frame here
    [self.navView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.mas_equalTo(kStatusBarAndNavigationBarHeight);
    }];
    
    [self.backButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.navView).offset(15);
        make.bottom.equalTo(self.navView);
        make.height.equalTo(@44);
        make.width.equalTo(@40);
    }];
    
    [self.midTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.navView.mas_centerX);
        make.height.equalTo(@44);
        make.bottom.equalTo(self.navView);
        make.width.equalTo(@70);
    }];
    
    [self.scanQRCodeV mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navView.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    [self.bottomTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(50);
        make.right.equalTo(self.view).offset(-50);
        make.bottom.equalTo(self.view).offset(-(24 + SafeAreaBottomHeight));
        make.height.greaterThanOrEqualTo(@34);
    }];
    
    [self.scanQRCodeV.superview layoutIfNeeded];
    
    //修正扫描区域
    CGFloat topMargin = 0.0f;
    topMargin = (kScreenHeight/3-35);
    CGFloat screenHeight = self.view.frame.size.height;
    CGFloat screenWidth = self.view.frame.size.width;
    CGRect cropRect = CGRectMake((screenWidth - self.scanQRCodeV.transparentArea.width) / 2 - 20,
                                 topMargin - 10,
                                 self.scanQRCodeV.transparentArea.width + 40,
                                 self.scanQRCodeV.transparentArea.height + 40);
    [_output setRectOfInterest:CGRectMake(cropRect.origin.y / screenHeight,
                                          cropRect.origin.x / screenWidth,
                                          cropRect.size.height / screenHeight,
                                          cropRect.size.width / screenWidth)];
}

#pragma mark - UINavigationControllerDelegate
// 将要显示控制器
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // 判断要显示的控制器是否是自己
    BOOL isSelfVC = [viewController isKindOfClass:[self class]];
    if (isSelfVC) {
        [self.navigationController setNavigationBarHidden:isSelfVC animated:YES];
    }
}

#pragma mark - SystemDelegate


#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    NSString *stringValue;
    if ([metadataObjects count] > 0){
        // 停止扫描
        [self.session stopRunning];
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
        
        NSLog(@"scanQR string is:%@", stringValue);
        [self dealWithScanQRString:stringValue];
    }
}

- (void)applicationWillEnterForeground:(NSNotification*)note {
    [self.session startRunning];
}
- (void)applicationDidEnterBackground:(NSNotification*)note {
    [self.session stopRunning];
}

#pragma mark - 优惠券校验

//- (void)checkCouponIsValid:(NSString *)couponNumber
//{
//    NSDictionary * params = @{@"qr":couponNumber};
//    [FSNetWorkManager requestWithType:HttpRequestTypeGet
//                        withUrlString:kApiCouponCheckIsValid
//                        withParaments:params
//                     withSuccessBlock:^(NSDictionary *object) {
//
//                         if (NetResponseCheckStaus)
//                         {
//                             BHCouponUsedViewController * couponUsedVC = [[BHCouponUsedViewController alloc] init];
//                             couponUsedVC.url = [NSString stringWithFormat:@"%@?qr=%@",kApiWebCouponUsed, couponNumber];
//                             [self.navigationController pushViewController:couponUsedVC animated:YES];
//                         }
//                         else
//                         {
//                             [ShowHUDTool showBriefAlert:@"优惠券不合法"];
//                             [self.session startRunning];
//                         }
//                     } withFailureBlock:^(NSError *error) {
//                         [ShowHUDTool showBriefAlert:NetRequestFailed];
//                         [self.session startRunning];
//                     }];
//}

#pragma mark - 检测探针

- (BOOL)isMacNumber:(NSString *)macNum
{
    NSString * MAC = @"^([A-Fa-f0-9]{2}:){5}[A-Fa-f0-9]{2}$";
    NSString * noSymbolMac = @"^[A-Fa-f0-9]{12}$";
    
    NSPredicate *regextestMac = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MAC];
    NSPredicate *regextestMacWithOutSymbol = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", noSymbolMac];
    
    if ([regextestMac evaluateWithObject:macNum] == YES)
    {
        return YES;
    }
    else if ([regextestMacWithOutSymbol evaluateWithObject:macNum] == YES)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)checkMacStatus:(NSString *)mac
{
    [FSNetWorkManager requestWithType:HttpRequestTypeGet
                        withUrlString:kApiDeviceCheckMac
                        withParaments:@{@"mac":mac} withSuccessBlock:^(NSDictionary *object) {
                            NSLog(@"请求成功");
                            
                            if (NetResponseCheckStaus){
                                LiteDeviceEditNameViewController *vc = [[LiteDeviceEditNameViewController alloc] init];
                                vc.mac = mac;
                                [self.navigationController pushViewController:vc animated:YES];
                                [self.session stopRunning];
                            }else{
                                [ShowHUDTool showBriefAlert:NetResponseMessage];
                                [self.session startRunning];
                            }
                            
                        } withFailureBlock:^(NSError *error) {
                            NSLog(@"error is %@", error);
                            [ShowHUDTool showBriefAlert:NetRequestFailed];
                            [self.session startRunning];
                        }];
    
}

#pragma mark - CustomDelegate


#pragma mark - Event response
// button、gesture, etc

- (void)leftBarButtonAction:(UIButton *)sender
{
    NSLog(@"取消");
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Private methods

- (void)dealWithScanQRString:(NSString *)stringValue
{
    NSLog(@"添加设备");
    if (![self isMacNumber:stringValue])
    {
        [ShowHUDTool showBriefAlert:@"二维码错误"];
        [self.session startRunning];
        return;
    }
    if (stringValue.length == 12)
    {
        NSMutableArray * subArray = [NSMutableArray arrayWithCapacity:6];
        for (NSInteger i = 0 ; i < 6 ; i ++)
        {
            NSString * subString = [stringValue substringWithRange:NSMakeRange(2*i, 2)];
            [subArray addObject:subString];
        }
        stringValue = [subArray componentsJoinedByString:@":"];
    }
    NSString * mac = [stringValue lowercaseString];
    
    [self checkMacStatus:mac];
}

- (void)defaultConfiguration{
    if (![self checkPermissions])
    {
        self.view.backgroundColor = [UIColor blackColor];
        return;
    }
    
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    self.session = [[AVCaptureSession alloc]init];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([self.session canAddInput:self.input])      [self.session addInput:self.input];
    if ([self.session canAddOutput:self.output])    [self.session addOutput:self.output];
    
    // 条码类型 AVMetadataObjectTypeQRCode
    //    _output.metadataObjectTypes =  _output.availableMetadataObjectTypes;
    //    _output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    _output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    
    // //扫描框的位置和大小
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    _preview.videoGravity = AVLayerVideoGravityResize;
    _preview.frame = [UIScreen mainScreen].bounds;
    [self.view.layer insertSublayer:_preview atIndex:0];
    [self.session startRunning];
}

- (void)setLeftBarButtonTarget:(id)target Action:(SEL)action Title:(NSString *)title {
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.contentMode = UIViewContentModeScaleAspectFit;
    leftBtn.frame = CGRectMake(0, 0, 40.0, 20); // 40*31
    [leftBtn setTitle:title forState:UIControlStateNormal];
    [leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    leftBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    leftBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [leftBtn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    
    NSMutableArray *buttonArray= [NSMutableArray arrayWithObjects:leftBarItem, negativeSpacer, nil];
    self.navigationItem.leftBarButtonItems = buttonArray;
}

#pragma mark - Getters and Setters
// initialize views here, etc

- (KSScanQRCodeView *)scanQRCodeV{
    if (!_scanQRCodeV) {
        _scanQRCodeV = [[KSScanQRCodeView alloc] initWithFrame:self.view.frame];
        _scanQRCodeV.transparentArea = CGSizeMake(kScreenHeight/3, kScreenHeight/3);
        _scanQRCodeV.backgroundColor = [UIColor clearColor];
        _scanQRCodeV.type = self.type;
        _scanQRCodeV.topMargin = (kScreenHeight/3-35);
    }
    return _scanQRCodeV;
}

- (UIView *)navView{
    if (!_navView) {
        _navView = [[UIView alloc] init];
        _navView.backgroundColor = UIColorDarkBlack;
    }
    return _navView;
}

- (UIButton *)backButton{
    if (!_backButton) {
        _backButton = [[UIButton alloc] init];
        [_backButton setTitle:@"取消" forState:UIControlStateNormal];
        [_backButton setTitleColor:UIColorWhite forState:UIControlStateNormal];
        _backButton.titleLabel.font = [UIFont systemFontOfSize:17];
        [_backButton addTarget:self action:@selector(leftBarButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UILabel *)midTitleLabel{
    if (!_midTitleLabel) {
        _midTitleLabel = [[UILabel alloc] init];
        _midTitleLabel.textColor = UIColorWhite;
        _midTitleLabel.text = @"添加设备";
        _midTitleLabel.textAlignment = NSTextAlignmentCenter;
        _midTitleLabel.font = [UIFont systemFontOfSize:17];
    }
    return _midTitleLabel;
}

- (UILabel *)bottomTitleLabel{
    if (!_bottomTitleLabel) {
        _bottomTitleLabel = [[UILabel alloc] init];
        _bottomTitleLabel.textColor = UIColorWhite;
//        _bottomTitleLabel.text = @"如果您修改过招财喵密码，请按照使用说明上的方式连接，或联系客服：400-1234-5678";
        _bottomTitleLabel.numberOfLines = 0;
        _bottomTitleLabel.textAlignment = NSTextAlignmentCenter;
        _bottomTitleLabel.font = [UIFont systemFontOfSize:12];
    }
    return _bottomTitleLabel;
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
