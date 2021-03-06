//
//  MyEditInfoViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/8/28.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "MyEditInfoViewController.h"
#import "FSNetWorkManager.h"
#import "ZLPhotoActionSheet.h"
#import <RSKImageCropper/RSKImageCropper.h>
#import "UIImage+category.h"
#import "FSNetWorkManager.h"
#import "BHUserModel.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import "NSArray+JSONString.h"
#import "PGDatePickManager.h"
#import "MyInputViewController.h"
#import <TTGTagCollectionView/TTGTextTagCollectionView.h>


typedef enum : NSUInteger {
    UploadImageTypeHead,
    UploadImageTypeOther,
} UploadImageType;

@interface MyEditInfoViewController ()< UINavigationControllerDelegate , UIImagePickerControllerDelegate , RSKImageCropViewControllerDelegate , RSKImageCropViewControllerDataSource , PGDatePickerDelegate , MyInputViewControllerDelegate >
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * topViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * scrollViewBottomConstraint;

@property (weak, nonatomic) IBOutlet UILabel * titleLabel;
@property (weak, nonatomic) IBOutlet UILabel * userNameTitleLabel;//用户名title
@property (weak, nonatomic) IBOutlet UILabel * birthdayTitleLabel;//生日title
@property (weak, nonatomic) IBOutlet UILabel * genderTitleLabel;//性别title
@property (weak, nonatomic) IBOutlet UILabel * hobbyTitleLabel;//爱好title
@property (weak, nonatomic) IBOutlet UILabel * remarkTitleLabel;//简介title

@property (nonatomic , strong) ZLPhotoActionSheet       * albumActionSheet; //相册
@property (nonatomic , strong) UIButton                 * currentButton;//当前选的头像
@property (nonatomic , strong) NSMutableArray           * picArr;       //照片数组
@property (nonatomic , strong) NSString                 * headUrlStr;   //头像图片链接
@property (nonatomic , strong) NSString                 * birthdayStr;  //生日
@property (nonatomic , strong) NSString                 * userNameStr;  //用户名
@property (nonatomic , strong) NSString                 * genderKey;    //性别(0 or 1)
@property (nonatomic , strong) NSString                 * describeStr;  //个人简介
@property (nonatomic , strong) NSMutableArray           * interestArr;  //兴趣爱好数组(处理完的文字数组)
@property (nonatomic , strong) NSMutableArray           * interestKeyArr;  //兴趣爱好key数组

@property (nonatomic , strong) TTGTextTagCollectionView * tagView; //兴趣爱好标签视图
@property (weak, nonatomic) IBOutlet UIView             * tagBackView;//兴趣爱好标签背景视图

@property (nonatomic , strong) NSMutableArray           * allInterestArr;//所有的兴趣爱好数组

@property (nonatomic , assign) UploadImageType          currentUploadType;   //当前上传类型

@property (weak, nonatomic) IBOutlet UIButton           * headButton; //大头像
@property (weak, nonatomic) IBOutlet UIButton           * userNameButton; //用户名按钮
@property (weak, nonatomic) IBOutlet UIButton           * birthdayButton; //生日按钮
@property (weak, nonatomic) IBOutlet UIButton           * genderButton; //性别按钮
@property (weak, nonatomic) IBOutlet UILabel            * describeLabel; //个人简介


@property (nonatomic , strong) PGDatePickManager        * datePickManager; //日期选择管理器

@end

@implementation MyEditInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
    [self requestUserInfo];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

#pragma mark - ******* UI Methods *******

- (void)createUI{
    self.topViewHeightConstraint.constant = kStatusBarAndNavigationBarHeight;
    self.scrollViewBottomConstraint.constant = SafeAreaBottomHeight;
    [self createTextByLanguage];
    [self createTagView];
}

//根据语言切换文字
- (void)createTextByLanguage{
    self.titleLabel.text = ZBLocalized(@"Edit", nil);
    self.userNameTitleLabel.text = ZBLocalized(@"Username", nil);
    self.birthdayTitleLabel.text = ZBLocalized(@"Date of birth", nil);
    self.genderTitleLabel.text = ZBLocalized(@"Gender", nil);
    self.hobbyTitleLabel.text = ZBLocalized(@"Hobby", nil);
    self.remarkTitleLabel.text = ZBLocalized(@"What's Up", nil);
}

- (void)createTagView{
    _tagView = [TTGTextTagCollectionView new];
    _tagView.enableTagSelection = NO;
    _tagView.alignment = TTGTagCollectionAlignmentRight;
    _tagView.translatesAutoresizingMaskIntoConstraints = NO;
    _tagView.numberOfLines = 1;
    //    _tagView.layer.borderColor = [UIColor grayColor].CGColor;
    //    _tagView.layer.borderWidth = 1;
    // Style1
    TTGTextTagConfig *config = _tagView.defaultConfig;
    
    config.tagTextFont = [UIFont boldSystemFontOfSize:12.5f];
    
    config.tagTextColor = UIColorFromRGB(0x9014FC);
    config.tagSelectedTextColor = [UIColor colorWithRed:83/255.0 green:148/255.0 blue:1 alpha:1.00];
    
    config.tagBackgroundColor = [UIColor clearColor];
    config.tagSelectedBackgroundColor = [UIColor colorWithRed:0.97 green:0.64 blue:0.27 alpha:1.00];
    
    config.tagBorderColor = UIColorFromRGB(0x9014FC);
    config.tagSelectedBorderColor = [UIColor colorWithRed:0.18 green:0.19 blue:0.22 alpha:1.00];
    config.tagBorderWidth = 1;
    config.tagSelectedBorderWidth = 0;
    
    config.tagShadowColor = [UIColor clearColor];
    config.tagShadowOffset = CGSizeMake(0, 0.3);
    config.tagShadowOpacity = 0;
    config.tagShadowRadius = 0;
    
    config.tagCornerRadius = 4;
    
    [self.tagBackView addSubview:_tagView];
    
    [_tagView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.tagBackView);
    }];
}

- (void)reloadUserInfo{
    self.headUrlStr = [BHUserModel sharedInstance].userHeadImageUrl;
    self.userNameStr = [BHUserModel sharedInstance].userName;
    self.birthdayStr = [BHUserModel sharedInstance].birthday;
    self.genderKey = [BHUserModel sharedInstance].gender;
    self.picArr = [[BHUserModel sharedInstance].photoArray mutableCopy];
    self.interestArr = [[BHUserModel sharedInstance].hobbyArray mutableCopy];
    self.describeStr = [BHUserModel sharedInstance].remark;

    [self.userNameButton setTitle:self.userNameStr forState:UIControlStateNormal];
    [self.birthdayButton setTitle:self.birthdayStr forState:UIControlStateNormal];
    [self.genderButton setTitle:[BHUserModel sharedInstance].gender_txt forState:UIControlStateNormal];
    [self.headButton sd_setImageWithURL:[NSURL URLWithString:self.headUrlStr] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"my_info_add"]];
    self.describeLabel.text = self.describeStr;
    
    if (kArrayNotNull(self.interestArr)) {
        [_tagView removeAllTags];
        [_tagView addTags:self.interestArr];
    }else{
        [_tagView addTags:@[]];
    }
    [_tagView reload];
    
    [self sortDisplayOtherImage];
}

#pragma mark - ******* Action *******
//返回
- (IBAction)backButtonAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
//点击头像
- (IBAction)headButtonAction:(UIButton *)sender {
    self.currentUploadType = UploadImageTypeHead;
    [self selectUploadImageStyle];
}

- (IBAction)otherImageButtonAction:(UIButton *)sender {
    self.currentButton = sender;
    self.currentUploadType = UploadImageTypeOther;
    [self selectUploadImageStyle];
}

//点击用户名
- (IBAction)userNameButtonAction:(UIButton *)sender {
    MyInputViewController * vc = [[MyInputViewController alloc] init];
    vc.inputType = MyInputTypeTextField;
    vc.titleStr = ZBLocalized(@"Username", nil);
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

//点击生日
- (IBAction)birthdayButtonAction:(UIButton *)sender {
    [self presentViewController:self.datePickManager animated:false completion:nil];
}
//点击性别
- (IBAction)genderButtonAction:(UIButton *)sender {
    MyInputViewController * vc = [[MyInputViewController alloc] init];
    vc.inputType = MyInputTypeGender;
    vc.titleStr = ZBLocalized(@"Gender", nil);
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}
//点击兴趣爱好
- (IBAction)interestButtonAction:(UIButton *)sender {
    MyInputViewController * vc = [[MyInputViewController alloc] init];
    vc.inputType = MyInputTypeInterest;
    vc.titleStr = ZBLocalized(@"Hobby", nil);
    vc.interestArr = self.allInterestArr;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}
//点击个人描述
- (IBAction)describeAction:(UIButton *)sender {
    MyInputViewController * vc = [[MyInputViewController alloc] init];
    vc.inputType = MyInputTypeTextView;
    vc.titleStr = ZBLocalized(@"What's Up", nil);
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}
//右上角确认
- (IBAction)uploadUserInfoButtonAction:(UIButton *)sender {
    [self uploadUserInfo];
}
#pragma mark - ******* Common Delegate *******
//输入结果
- (void)inputResultString:(NSString *)string inputType:(MyInputType)type{
    if (type == MyInputTypeTextField) {
        self.userNameStr = string;
        [self.userNameButton setTitle:string  forState:UIControlStateNormal];
    }else if(type == MyInputTypeTextView){
        self.describeStr = string;
        self.describeLabel.text = self.describeStr;
    }
}
//年龄选择结果
- (void)inputGenderSelectResult:(NSDictionary *)dic{
    NSString * genderStr = [dic objectForKey:@"value"];
    
    [self.genderButton setTitle:genderStr forState:UIControlStateNormal];
    self.genderKey = [dic objectForKey:@"key"];
}

//爱好选择结果
- (void)inputHobbySelectResult:(NSArray *)arr{
    self.interestArr = [[self dealInterestArr:arr] mutableCopy];
    if (kArrayNotNull(self.interestArr)) {
        [_tagView removeAllTags];
        [_tagView addTags:self.interestArr];
    }else{
        [_tagView addTags:@[]];
    }
    [_tagView reload];
    
    if (kArrayNotNull(arr)) {
        for (NSDictionary * dic in arr) {
            NSString  * keyStr = [dic objectForKey:@"key"];
            [self.interestKeyArr addObject:keyStr];
        }
    } else {
        self.interestKeyArr = [NSMutableArray new];
    }
}

#pragma mark - ******* PGDatePicker Delegate *******

- (void)datePicker:(PGDatePicker *)datePicker didSelectDate:(NSDateComponents *)dateComponents {
    NSLog(@"year = %ld month = %ld day = %ld", (long)dateComponents.year , (long)dateComponents.month , (long)dateComponents.day);
    self.birthdayStr = [NSString stringWithFormat:@"%ld-%02ld-%02ld",(long)dateComponents.year , (long)dateComponents.month, (long)dateComponents.day];
    [self.birthdayButton setTitle:self.birthdayStr  forState:UIControlStateNormal];
}

#pragma mark - ******* Request *******
//请求用户信息
- (void)requestUserInfo{
    WEAKSELF
    NSDictionary * params = @{};
    
    [FSNetWorkManager requestWithType:HttpRequestTypePost
                        withUrlString:kApiAccountGetUserInfo
                        withParaments:params withSuccessBlock:^(NSDictionary *object) {
                            NSLog(@"请求成功");
                            
                            if (NetResponseCheckStaus){
                                [[BHUserModel sharedInstance] analysisUserInfoWithDictionary:object];
                                NSDictionary *dataDic = object[@"data"][@"userInfo"];
                                [BHUserModel sharedInstance].hobbyArray = [self dealInterestArr:[dataDic objectForKey:@"hobby"]];
                                [weakSelf reloadUserInfo];
                                
                                weakSelf.allInterestArr = object[@"data"][@"userTags"];
                            }else{
                                [ShowHUDTool showBriefAlert:NetResponseMessage];
                            }
                        } withFailureBlock:^(NSError *error) {
                            
                            [ShowHUDTool showBriefAlert:NetRequestFailed];
                        }];
}

//用户信息上传
- (void)uploadUserInfo{
    WEAKSELF
    NSString * picArrStr = @"";
    if (kArrayNotNull(self.picArr)) {
        picArrStr = [self.picArr JsonString];
    }
    
    NSString * interestKeyArrStr = @"";
    if (kArrayNotNull(self.interestKeyArr)) {
        interestKeyArrStr = [self.interestKeyArr JsonString];
    }
    
    NSDictionary * params = @{@"nickname":self.userNameStr,
                              @"birthday":self.birthdayStr,
                              @"photo":self.headUrlStr,
                              @"gender":self.genderKey,
                              @"remark":self.describeStr,
                              @"hobby":interestKeyArrStr,
                              @"picArr":picArrStr,
                              };

    [FSNetWorkManager requestWithType:HttpRequestTypePost
                        withUrlString:kApiAccountSaveUserInfo
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


#pragma mark - ******* Pravite *******
//处理已有的兴趣爱好数组
- (NSArray *)dealInterestArr:(NSArray *)interestArr{
    NSMutableArray * array = [NSMutableArray new];
    if (kArrayNotNull(interestArr)) {
        for (NSDictionary * dic in interestArr) {
            NSString  * str = [dic objectForKey:@"value"];
            [array addObject:str];
        }
        return [array copy];
    } else {
        return [NSArray new];
    }
}

//选择上传类型
- (void)selectUploadImageStyle
{
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:ZBLocalized(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    [actionSheet addAction:cancelButton];
    
    UIAlertAction *cameraButton = [UIAlertAction actionWithTitle:ZBLocalized(@"Take a photo", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self checkPermissionWithType:1];
    }];
    [actionSheet addAction:cameraButton];
    
    UIAlertAction *albumButton = [UIAlertAction actionWithTitle:ZBLocalized(@"Choose from an album", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self checkPermissionWithType:2];
    }];
    [actionSheet addAction:albumButton];
    
    if (self.currentUploadType == UploadImageTypeOther) {
        if (self.currentButton.tag - 100 < self.picArr.count) {
            UIAlertAction *delegateButton = [UIAlertAction actionWithTitle:ZBLocalized(@"Delete", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self.picArr removeObjectAtIndex:self.currentButton.tag - 100];
                [self sortDisplayOtherImage];
            }];
            [actionSheet addAction:delegateButton];
        }
    }
    
    [self presentViewController:actionSheet animated:YES completion:nil];
    
}

//重新处理资料图片的排序显示(删除或新增图片)
- (void)sortDisplayOtherImage{
    for (int i = 0; i < 5 ; i ++) {
        UIButton *button = [self.view viewWithTag:100+i];
        if (i < self.picArr.count) {
            [button sd_setImageWithURL:[NSURL URLWithString:self.picArr[i]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"my_info_add"]];
        } else {
            [button sd_setImageWithURL:[NSURL URLWithString:self.picArr[i]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"my_info_add"]];
        }
    }
}

//检查权限
- (void)checkPermissionWithType:(int)type{
    if (type == 1)
    {
        NSLog(@"拍照");
        
        /// 先判断摄像头硬件是否好用
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            // 用户是否允许摄像头使用
            NSString * mediaType = AVMediaTypeVideo;
            AVAuthorizationStatus  authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
            // 不允许弹出提示框
            if (authorizationStatus == AVAuthorizationStatusRestricted|| authorizationStatus == AVAuthorizationStatusDenied) {
                //无相册访问权限
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:ZBLocalized(@"Please allow Waiting to access your camera in the iphone settings", nil) preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action1 = [UIAlertAction actionWithTitle:ZBLocalized(@"Got it", nil) style:UIAlertActionStyleDefault handler:nil];
                [alert addAction:action1];
                
                UIAlertAction *action = [UIAlertAction actionWithTitle:ZBLocalized(@"Setting", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    NSURL *applicationUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    if ([[UIApplication sharedApplication] canOpenURL:applicationUrl]) {
                        [[UIApplication sharedApplication] openURL:applicationUrl];
                    }
                }];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
                return;
            }else{
                // 这里是摄像头可以使用的处理逻辑
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.sourceType = UIImagePickerControllerSourceTypeCamera;
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                controller.delegate = self;
                [self presentViewController:controller
                                   animated:YES
                                 completion:^(void){
                                     NSLog(@"Picker View Controller is presented");
                                 }];
            }
        } else {
            // 硬件问题提示
            [ShowHUDTool showBriefAlert:ZBLocalized(@"Camera is not available, please check your phone camera device", nil)];
        }
    }
    else if (type == 2)
    {
        NSLog(@"从相册选择");
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusRestricted ||
            status == PHAuthorizationStatusDenied) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:ZBLocalized(@"Please allow Waiting to access your photos in the iPhone settings.", nil) preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action1 = [UIAlertAction actionWithTitle:ZBLocalized(@"Got it", nil) style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:action1];
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:ZBLocalized(@"Setting", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSURL *applicationUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([[UIApplication sharedApplication] canOpenURL:applicationUrl]) {
                    [[UIApplication sharedApplication] openURL:applicationUrl];
                }
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        } else {
            [self.albumActionSheet showPhotoLibrary];
        }
    }
}
#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *portraitImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self dealWithPortraitImage:portraitImage];
}


#pragma mark - RSKImageCropViewControllerDelegate

- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage usingCropRect:(CGRect)cropRect rotationAngle:(CGFloat)rotationAngle
{
    //压缩后的图片
    UIImage * necessaryImage = [croppedImage imageCompressWithScaledToSize:CGSizeMake(500, 500)];
    [self uploadImage:necessaryImage];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (CGRect)imageCropViewControllerCustomMaskRect:(RSKImageCropViewController *)controller
{
    CGFloat width = 500;    //宽度
    CGFloat height = 500;  //高度
    
    
    CGSize maskSize;
    //floor函数  向下取整 3.6 取 3
    CGFloat maxWidth = floor((kScreenWidth - 40)/10) * 10;
    CGFloat maxHeight = floor((kScreenHeight - 80)/10) * 10;
    if (width / height > kScreenWidth / kScreenHeight)
    {
        CGFloat maskSizeHeight= maxWidth * height / width;
        maskSize = CGSizeMake(maskSizeHeight * width / height, maskSizeHeight);
    }
    else
    {
        CGFloat maskSizeWidth = maxHeight * width / height;
        maskSize = CGSizeMake(maskSizeWidth, maskSizeWidth * height / width);
    }
    
    CGFloat viewWidth = CGRectGetWidth(controller.view.frame);
    CGFloat viewHeight = CGRectGetHeight(controller.view.frame);
    
    CGRect maskRect = CGRectMake((viewWidth - maskSize.width) * 0.5f,
                                 (viewHeight - maskSize.height) * 0.5f,
                                 maskSize.width,
                                 maskSize.height);
    
    return maskRect;
}

// Returns a custom path for the mask.
- (UIBezierPath *)imageCropViewControllerCustomMaskPath:(RSKImageCropViewController *)controller
{
    CGRect rect = controller.maskRect;
    CGPoint point1 = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGPoint point2 = CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect));
    CGPoint point3 = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    CGPoint point4 = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));
    
    UIBezierPath *triangle = [UIBezierPath bezierPath];
    [triangle moveToPoint:point1];
    [triangle addLineToPoint:point2];
    [triangle addLineToPoint:point3];
    [triangle addLineToPoint:point4];
    [triangle closePath];
    
    CGFloat length = 15.0f;
    CGFloat width = 2.0f;
    UIBezierPath* cornerPath1 = [UIBezierPath bezierPath];
    [cornerPath1 moveToPoint:CGPointMake(point1.x - width, point1.y + length)];
    [cornerPath1 addLineToPoint:CGPointMake(point1.x - width, point1.y - width)];
    [cornerPath1 addLineToPoint:CGPointMake(point1.x + length, point1.y - width)];
    [triangle appendPath:cornerPath1];
    
    UIBezierPath* cornerPath2 = [UIBezierPath bezierPath];
    [cornerPath2 moveToPoint:CGPointMake(point2.x - length, point2.y - width)];
    [cornerPath2 addLineToPoint:CGPointMake(point2.x + width, point2.y - width)];
    [cornerPath2 addLineToPoint:CGPointMake(point2.x + width, point2.y + length)];
    [triangle appendPath:cornerPath2];
    
    UIBezierPath* cornerPath3 = [UIBezierPath bezierPath];
    [cornerPath3 moveToPoint:CGPointMake(point3.x + width, point3.y - length)];
    [cornerPath3 addLineToPoint:CGPointMake(point3.x + width, point3.y + width)];
    [cornerPath3 addLineToPoint:CGPointMake(point3.x - length, point3.y + width)];
    [triangle appendPath:cornerPath3];
    
    UIBezierPath* cornerPath4 = [UIBezierPath bezierPath];
    [cornerPath4 moveToPoint:CGPointMake(point4.x + length, point4.y + width)];
    [cornerPath4 addLineToPoint:CGPointMake(point4.x - width, point4.y + width)];
    [cornerPath4 addLineToPoint:CGPointMake(point4.x - width, point4.y - length)];
    [triangle appendPath:cornerPath4];
    
    return triangle;
}

// Returns a custom rect in which the image can be moved.
- (CGRect)imageCropViewControllerCustomMovementRect:(RSKImageCropViewController *)controller
{
    // If the image is not rotated, then the movement rect coincides with the mask rect,
    // otherwise it is calculated individually for each custom mask.
    return controller.maskRect;
}


#pragma mark - Private methods

- (void)dealWithPortraitImage:(UIImage *)portraitImage
{
    
    RSKImageCropViewController *imageCropVC = [[RSKImageCropViewController alloc] initWithImage:portraitImage cropMode:RSKImageCropModeCustom];
    imageCropVC.moveAndScaleLabel.text = ZBLocalized(@"Set the crop area", nil);
    imageCropVC.delegate = self;
    imageCropVC.dataSource = self;
    imageCropVC.maskLayerStrokeColor = UIColorBlue;
    imageCropVC.maskLayerLineWidth = 3;
    imageCropVC.maskLayerColor = [UIColor clearColor];
    [self.navigationController pushViewController:imageCropVC animated:YES];
}

- (void)uploadImage:(UIImage *)portraitImg
{
    [ShowHUDTool showLoadingWithTitle:ZBLocalized(@"Uploading", nil) inView:[UIApplication sharedApplication].keyWindow];
    WEAKSELF
    //此body是向后台传的参数, 因为是上传图片, 所以只给个图片名就够了, 这个和后台去问
    NSDictionary * body = @{@"pic":@"image"};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //ContentType设置
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/html",@"image/jpeg",@"image/png",@"application/octet-stream",@"text/json", nil];
    manager.requestSerializer= [AFHTTPRequestSerializer serializer];
    manager.responseSerializer= [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:[BHUserModel sharedInstance].token forHTTPHeaderField:@"token"];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",kApiHostPort,kApiAccountUploadPicture];
    
    [manager POST:urlStr parameters:body constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //把image  转为data , POST上传只能传data
        NSData * imgData = UIImageJPEGRepresentation(portraitImg, 1.0);
        //上传的参数(上传图片，以文件流的格式)
        [formData appendPartWithFileData:imgData name:@"pic" fileName:@"image.jpeg" mimeType:@"image/jpeg"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"上传成功");
        [ShowHUDTool hideAlert];
        NSDictionary * object = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        if (NetResponseCheckStaus)
        {
            NSDictionary *dic = object[@"data"];
            NSString *picUrl = dic[@"picurl"];
            if (weakSelf.currentUploadType == UploadImageTypeHead) {
                [weakSelf.headButton sd_setImageWithURL:[NSURL URLWithString:picUrl] forState:UIControlStateNormal placeholderImage:kGetImageFromName(@"waiting_default_image")];
                weakSelf.headUrlStr = picUrl;
            } else {
                [self.picArr addObject:picUrl];
                [weakSelf sortDisplayOtherImage];
            }
        }else{
            [ShowHUDTool hideAlert];
            [ShowHUDTool showBriefAlert:NetResponseMessage];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"上传失败%@",error);
        [ShowHUDTool hideAlert];
        [ShowHUDTool showBriefAlert:NetRequestFailed];
    }];
}

#pragma mark - ******* Getter *******

- (NSMutableArray *)picArr{
    if (!_picArr) {
        _picArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _picArr;
}

- (NSMutableArray *)interestKeyArr{
    if (!_interestKeyArr) {
        _interestKeyArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _interestKeyArr;
}

- (PGDatePickManager *)datePickManager{
    if (!_datePickManager)
    {
        _datePickManager = [[PGDatePickManager alloc] init];
        _datePickManager.style = PGDatePickManagerStyle3;
        _datePickManager.isShadeBackgroud = true;
        
        PGDatePicker *datePicker = _datePickManager.datePicker;
        datePicker.delegate = self;
        datePicker.datePickerType = PGPickerViewType2;
        datePicker.datePickerMode = PGDatePickerModeDate;
        
        NSDate *currentDate = [NSDate date];
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setYear:1950];
        [dateComponents setMonth:01];
        NSDate *miniDate = [calendar dateFromComponents:dateComponents];
        
        datePicker.minimumDate = miniDate;
        datePicker.maximumDate = currentDate;
    }
    return _datePickManager;
}

- (ZLPhotoActionSheet *)albumActionSheet
{
    if (!_albumActionSheet)
    {
        _albumActionSheet = [[ZLPhotoActionSheet alloc] init];
        
#pragma optional
        //以下参数为自定义参数，均可不设置，有默认值
        _albumActionSheet.sortAscending = 0;    // 升序排列
        _albumActionSheet.allowSelectImage = YES;
        _albumActionSheet.allowSelectGif = NO;
        _albumActionSheet.allowSelectVideo = NO;
        _albumActionSheet.allowSelectLivePhoto = NO;
        _albumActionSheet.allowForceTouch = NO;
        _albumActionSheet.allowEditImage = NO;
        _albumActionSheet.allowEditVideo = NO;
        _albumActionSheet.allowSlideSelect = NO;
        _albumActionSheet.allowMixSelect = NO;
        _albumActionSheet.allowDragSelect = NO;
        //设置相册内部显示拍照按钮
        _albumActionSheet.allowTakePhotoInLibrary = NO;
        //设置在内部拍照按钮上实时显示相机俘获画面
        _albumActionSheet.showCaptureImageOnTakePhotoBtn = NO;
        //设置照片最大预览数
        _albumActionSheet.maxPreviewCount = 0;
        //设置照片最大选择数
        _albumActionSheet.maxSelectCount = 1;
        //设置允许选择的视频最大时长
        _albumActionSheet.maxVideoDuration = 1;
        //设置照片cell弧度
        _albumActionSheet.cellCornerRadio = 0;
        //单选模式是否显示选择按钮
        _albumActionSheet.showSelectBtn = NO;  //
        //是否在选择图片后直接进入编辑界面
        _albumActionSheet.editAfterSelectThumbnailImage = NO;
        //设置编辑比例
        //    actionSheet.clipRatios = @[GetClipRatio(1, 1)];
        //是否在已选择照片上显示遮罩层
        _albumActionSheet.showSelectedMask = NO;
        //遮罩层颜色
        //    actionSheet.selectedMaskColor = [UIColor orangeColor];
        //允许框架解析图片
        _albumActionSheet.shouldAnialysisAsset = YES;
        _albumActionSheet.languageType = ZLLanguageSystem;
#pragma required
        //如果调用的方法没有传sender，则该属性必须提前赋值
        _albumActionSheet.sender = self;
        
        _albumActionSheet.arrSelectedAssets = nil;
        
        _albumActionSheet.allowSelectOriginal = YES;
        _albumActionSheet.navBarColor = UIColorFromRGB(0xFFFFFF);
        _albumActionSheet.navTitleColor = UIColorDarkBlack;
        
        
        zl_weakify(self);
        [_albumActionSheet setSelectImageBlock:^(NSArray<UIImage *> * _Nonnull images, NSArray<PHAsset *> * _Nonnull assets, BOOL isOriginal) {
            zl_strongify(weakSelf);
            [strongSelf dealWithPortraitImage:[images firstObject]];
            NSLog(@"image:%@", images);
        }];
    }
    return _albumActionSheet;
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
