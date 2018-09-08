//
//  LiteAccountQualificationICPViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/6/19.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteAccountQualificationICPViewController.h"
#import "UIImage+category.h"
#import <Masonry/Masonry.h>
#import "FSNetWorkManager.h"
#import "ZLPhotoActionSheet.h"
#import "NSString+Helper.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "LiteAccountQualificationICPCell.h"
#import "BHUserModel.h"
#import <AVFoundation/AVFoundation.h>
#import "ZLNoAuthorityViewController.h"
#import <Photos/Photos.h>

@interface LiteAccountQualificationICPViewController ()<UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDelegate, UITableViewDataSource, LiteAccountQualificationICPCellDelegate>

@property (nonatomic, strong) UITableView        * tableView;
@property (nonatomic, strong) NSMutableArray     * dataArray;
@property (nonatomic, strong) NSMutableArray     * deleteArray;

@property (nonatomic, strong) UIButton           * submitButton;
@property (nonatomic, strong) UIView             * bottomView;

@property (nonatomic, strong) ZLPhotoActionSheet * photoActionSheet;

@end

@implementation LiteAccountQualificationICPViewController

#pragma mark - Life circle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.type == ICPCellTypeBusinessLicense ? @"营业执照" : @"银行纳税人证明";
    self.title = self.type == ICPCellTypeBankLicense ? @"银行开户许可证" : self.title;

    // You should add subviews here, just add subviews
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.bottomView];
    [self.view addSubview:self.submitButton];
    
    // You should add notification here
    
    // layout subviews
    [self layoutSubviews];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)layoutSubviews {
    //You should set subviews constrainsts or frame here
    
    [self.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(0 - SafeAreaBottomHeight);
        make.height.mas_equalTo(56);
    }];
    [self.submitButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomView).offset(8);
        make.left.equalTo(self.view).offset(48);
        make.right.equalTo(self.view).offset(-48);
        make.height.equalTo(@40);
    }];
}

#pragma mark - Public Method


#pragma mark - SystemDelegate


#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
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
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"请在iphone的\"设置-隐私-相机\"选项中,允许招财宝Lite访问您的相机" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
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
            [ShowHUDTool showBriefAlert:@"摄像头不可用,请检查手机摄像头设备"];
        }
    }
    else if (buttonIndex == 1)
    {
        NSLog(@"从相册选择");
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusRestricted ||
            status == PHAuthorizationStatusDenied) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"请在iphone的\"设置-隐私-照片\"选项中,允许招财宝Lite访问您的照片" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        } else {
            [self.photoActionSheet showPhotoLibrary];
        }
    }
    else if (buttonIndex == 2)
    {
        NSLog(@"取消");
    }
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LiteAccountQualificationICPCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(self.class) forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    NSDictionary *ICPDic = [NSDictionary new];
    if (kStringNotNull(self.qualificationICPUrl)) {
        ICPDic = [NSDictionary dictionaryWithObject:self.qualificationICPUrl forKey:@"imageUrl"];
    }
    cell.type = self.type;
    [cell configWithData:ICPDic];
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.0f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"点击了cell");
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *portraitImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self dealWithPortraitImage:portraitImage];
}

#pragma mark - CustomDelegate

- (void)clickImageView
{
    NSLog(@"点击了图片");
    UIActionSheet * shareActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相册选择", nil];
    [shareActionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

#pragma mark - Event response
// button、gesture, etc

- (void)submitButtonAction:(UIButton *)sender
{
    NSLog(@"确定");
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Private methods

- (void)dealWithPortraitImage:(UIImage *)portraitImage
{
    CGSize necessarySize = [self getNecessarySizeWithImage:portraitImage minimumSize:CGSizeMake(1080, 1080)];
    UIImage * necessaryImage = [portraitImage imageCompressWithScaledToSize:necessarySize];
//    self.currentModel.image = necessaryImage;
    
    [self uploadImage:necessaryImage];
}

/**
 *  压缩到1080*1080的范围之上的最小值
 */
- (CGSize)getNecessarySizeWithImage:(UIImage *)image minimumSize:(CGSize)minimumSize
{
    
    CGSize originalSize = image.size;
    if (originalSize.width > minimumSize.width && originalSize.height > minimumSize.height)
    {
        // 先试着按照宽压缩试试
        CGSize necessarySize = CGSizeMake(minimumSize.width, minimumSize.width * originalSize.height / originalSize.width);
        if (necessarySize.height > minimumSize.height)
        {
            return necessarySize;
        }
        else
        {
            necessarySize = CGSizeMake(minimumSize.height*originalSize.width/originalSize.height, minimumSize.height);
            return necessarySize;
        }
        return CGSizeZero;
    }
    else
    {
        return originalSize;
    }
}

- (void)uploadImage:(UIImage *)portraitImg
{
    [ShowHUDTool showLoadingWithTitle:@"上传中" inView:[UIApplication sharedApplication].keyWindow];
    
    //此body是向后台传的参数, 因为是上传图片, 所以只给个图片名就够了, 这个和后台去问
    NSDictionary * body = @{@"file":@"image"};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //ContentType设置
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/html",@"image/jpeg",@"image/png",@"application/octet-stream",@"text/json", nil];
    manager.requestSerializer= [AFHTTPRequestSerializer serializer];
    manager.responseSerializer= [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:[BHUserModel sharedInstance].token forHTTPHeaderField:@"token"];
    
    NSString *urlStr;
    if (self.type == ICPCellTypeBusinessLicense) {
        urlStr = [NSString stringWithFormat:@"%@",kApiHostPort];
    } else {
        urlStr = [NSString stringWithFormat:@"%@%@",kApiHostPort,kApiInvoiceUpload];
    }
    
    
    [manager POST:urlStr parameters:body constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //把image  转为data , POST上传只能传data
        NSData * imgData = UIImageJPEGRepresentation(portraitImg, 1.0);
        //上传的参数(上传图片，以文件流的格式)
        [formData appendPartWithFileData:imgData name:@"file" fileName:@"image.jpeg" mimeType:@"image/jpeg"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"上传成功");
        [ShowHUDTool hideAlert];
        NSDictionary * object = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        if (NetResponseCheckStaus)
        {
            NSString *imageUrl = object[@"data"][@"url"];
            if (kStringNotNull(imageUrl)) {
                self.qualificationICPUrl = imageUrl;
                [self.tableView reloadData];
                self.submitButton.backgroundColor = UIColorBlue;
                self.submitButton.userInteractionEnabled = YES;
                if ([self.delegate respondsToSelector:@selector(changeQualificationFinish:Type:)])
                {
                    [self.delegate changeQualificationFinish:self.qualificationICPUrl Type:self.type];
                }
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

#pragma mark - Getters and Setters
// initialize views here, etc

- (UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.height = IS_IPhoneX ? kScreenHeight-60-88-34 : kScreenHeight-60-64;
        _tableView.backgroundColor = UIColorFromRGB(0xF4F4F4);
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[LiteAccountQualificationICPCell class] forCellReuseIdentifier:NSStringFromClass(self.class)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.bounces = NO;
    }
    return _tableView;
}

- (NSMutableArray *)dataArray
{
    if (!_dataArray)
    {
        _dataArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataArray;
}

- (UIView *)bottomView
{
    if (!_bottomView)
    {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor whiteColor];
    }
    return _bottomView;
}

- (UIButton *)submitButton
{
    if (!_submitButton)
    {
        _submitButton = [[UIButton alloc] init];
        [_submitButton setTitle:@"保存" forState:UIControlStateNormal];
        [_submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _submitButton.backgroundColor = UIColorlightGray;
        _submitButton.userInteractionEnabled = NO;
        _submitButton.layer.cornerRadius = 2;
        _submitButton.clipsToBounds = YES;
        [_submitButton addTarget:self action:@selector(submitButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _submitButton;
}

- (ZLPhotoActionSheet *)photoActionSheet
{
    if (!_photoActionSheet)
    {
        _photoActionSheet = [[ZLPhotoActionSheet alloc] init];
        
#pragma optional
        //以下参数为自定义参数，均可不设置，有默认值
        _photoActionSheet.sortAscending = 0;    // 升序排列
        _photoActionSheet.allowSelectImage = YES;
        _photoActionSheet.allowSelectGif = NO;
        _photoActionSheet.allowSelectVideo = NO;
        _photoActionSheet.allowSelectLivePhoto = NO;
        _photoActionSheet.allowForceTouch = NO;
        _photoActionSheet.allowEditImage = NO;
        _photoActionSheet.allowEditVideo = NO;
        _photoActionSheet.allowSlideSelect = NO;
        _photoActionSheet.allowMixSelect = NO;
        _photoActionSheet.allowDragSelect = NO;
        //设置相册内部显示拍照按钮
        _photoActionSheet.allowTakePhotoInLibrary = NO;
        //设置在内部拍照按钮上实时显示相机俘获画面
        _photoActionSheet.showCaptureImageOnTakePhotoBtn = NO;
        //设置照片最大预览数
        _photoActionSheet.maxPreviewCount = 0;
        //设置照片最大选择数
        _photoActionSheet.maxSelectCount = 1;
        //设置允许选择的视频最大时长
        _photoActionSheet.maxVideoDuration = 1;
        //设置照片cell弧度
        _photoActionSheet.cellCornerRadio = 0;
        //单选模式是否显示选择按钮
        _photoActionSheet.showSelectBtn = NO;  //
        //是否在选择图片后直接进入编辑界面
        _photoActionSheet.editAfterSelectThumbnailImage = NO;
        //设置编辑比例
        //    actionSheet.clipRatios = @[GetClipRatio(1, 1)];
        //是否在已选择照片上显示遮罩层
        _photoActionSheet.showSelectedMask = NO;
        //遮罩层颜色
        //    actionSheet.selectedMaskColor = [UIColor orangeColor];
        //允许框架解析图片
        _photoActionSheet.shouldAnialysisAsset = YES;
        _photoActionSheet.languageType = ZLLanguageSystem;
#pragma required
        //如果调用的方法没有传sender，则该属性必须提前赋值
        _photoActionSheet.sender = self;
        
        _photoActionSheet.arrSelectedAssets = nil;
        
        _photoActionSheet.allowSelectOriginal = YES;
        _photoActionSheet.navBarColor = UIColorFromRGB(0xFFFFFF);
        _photoActionSheet.navTitleColor = UIColorDrakBlackNav;
        
        
        zl_weakify(self);
        [_photoActionSheet setSelectImageBlock:^(NSArray<UIImage *> * _Nonnull images, NSArray<PHAsset *> * _Nonnull assets, BOOL isOriginal) {
            zl_strongify(weakSelf);
            [strongSelf dealWithPortraitImage:[images firstObject]];
            NSLog(@"image:%@", images);
        }];
    }
    return _photoActionSheet;
}

#pragma mark - MemoryWarning

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
