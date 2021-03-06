//
//  MatchDetailViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/10/10.
//  Copyright © 2018 BEHE. All rights reserved.
//

#import "MatchDetailViewController.h"
#import "FSNetWorkManager.h"
#import "BHUserModel.h"
#import "MatchVoiceViewController.h"
#import "MatchVideoViewController.h"
#import "ChatViewController.h"
#import <TTGTagCollectionView/TTGTextTagCollectionView.h>
#import "MyRechargeViewController.h"

typedef enum : NSUInteger {
    requestTypeVoice,
    requestTypeVideo,
} requestType;

@interface MatchDetailViewController ()<CAAnimationDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView   * mainScrollView; 

@property (weak, nonatomic) IBOutlet UIScrollView   * imageScrollView; //图片轮播图
@property (weak, nonatomic) IBOutlet UIPageControl  * pageControl;
@property (weak, nonatomic) IBOutlet UILabel    * nameLabel; //用户名
@property (weak, nonatomic) IBOutlet UILabel    * genderAndAgeLabel; //性别年龄
@property (weak, nonatomic) IBOutlet UIView     * tagsBackView; //兴趣标签
@property (weak, nonatomic) IBOutlet UILabel    * tagsNoDataLabel; //无兴趣爱好提示
@property (weak, nonatomic) IBOutlet UILabel    * remarkLabel; //个人简介
@property (nonatomic , strong) TTGTextTagCollectionView * tagView; //兴趣爱好标签视图


@property (weak, nonatomic) IBOutlet NSLayoutConstraint * bottomViewBottomContraint;//底部按键视图距下约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * topViewHeightConstraint; //顶部视图高度约束

@end

@implementation MatchDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}
#pragma mark - ******* UI Methods *******

- (void)createUI{
    if (@available(iOS 11.0, *)) {
        self.mainScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.topViewHeightConstraint.constant = kStatusBarAndNavigationBarHeight;
    self.bottomViewBottomContraint.constant = SafeAreaBottomHeight;
    
    self.nameLabel.text = self.userModel.userName; //用户名
    self.genderAndAgeLabel.text = [NSString stringWithFormat:@"%@ · %@",self.userModel.gender_txt,self.userModel.age];;
    self.remarkLabel.text = kStringNotNull(self.userModel.remark)? self.userModel.remark : @""; //个人
    [self createImageScrollView];
    [self createTagView];
}

-(void)createImageScrollView{
    NSMutableArray *imageArr = [[NSMutableArray alloc] init];
    [imageArr addObject:self.userModel.userHeadImageUrl];
    for (int i = 0 ; i < self.userModel.photoArray.count ; i++) {
        [imageArr addObject:self.userModel.photoArray[i]];
    }
    
    if (imageArr.count >1) {
        self.pageControl.hidden = NO;
        self.pageControl.numberOfPages = imageArr.count;
        self.pageControl.currentPage = 0;
    }
    
    for (int i = 0 ; i < imageArr.count ; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * kScreenWidth, 0, kScreenWidth, self.imageScrollView.height)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [imageView sd_setImageWithURL:[NSURL URLWithString:imageArr[i]] placeholderImage:kGetImageFromName(@"waiting_default_image")];
        [self.imageScrollView addSubview:imageView];
    }
    self.imageScrollView.contentSize = CGSizeMake(kScreenWidth * imageArr.count, 0);
}

- (void)createTagView{
    
    if (!kArrayNotNull(self.userModel.hobbyArray)) {
        _tagsNoDataLabel.hidden = NO;
        _tagsNoDataLabel.text = @"";
        return;
    }
    
    _tagView = [TTGTextTagCollectionView new];
    _tagView.enableTagSelection = NO;
    _tagView.alignment = TTGTagCollectionAlignmentLeft;
    _tagView.manualCalculateHeight = YES;
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
    
    [self.tagsBackView addSubview:_tagView];
    
    [_tagView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.tagsBackView);
    }];
    
    NSArray * interestArr = [self dealInterestArr:self.userModel.hobbyArray];
    [_tagView addTags:interestArr];
    [_tagView reload];
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

#pragma mark - ******* Scroll Delegate *******

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (![scrollView isEqual:self.imageScrollView]) {
        return;
    }
    //当下一页滑到>=0.5宽度时，此时就要改变pageControl
    CGFloat page = scrollView.contentOffset.x / kScreenWidth;
    NSUInteger currentPage = page; //向下取整
    NSLog(@"%f === %lu",page,(unsigned long)currentPage);
    self.pageControl.currentPage = (page - currentPage) < 0.5 ? currentPage : currentPage +1;
}

//拖拽开始时关闭定时器，定时器一旦关闭，就只能等拖拽结束再重新开启
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    [self.timer invalidate];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (![scrollView isEqual:self.imageScrollView]) {
        return;
    }
//    CGFloat OffsetX = scrollView.contentOffset.x;
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(changeImage) userInfo:nil repeats:YES];
}

#pragma mark - ******* Common Delegate *******

#pragma mark - ******* Action *******
//返回
- (IBAction)backButtonAction:(UIButton *)sender {
    [self popViewControllerAsDismiss];
}
//更多
- (IBAction)moreAction:(UIButton *)sender {

    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:ZBLocalized(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    [actionSheet addAction:cancelButton];
    
    UIAlertAction *reportButton = [UIAlertAction actionWithTitle:ZBLocalized(@"Report", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [ShowHUDTool showBriefAlert:ZBLocalized(@"Report success", nil)];
    }];
    [actionSheet addAction:reportButton];
   
    WEAKSELF
    BOOL isBlackList = [[NSUserDefaults standardUserDefaults] boolForKey:self.userModel.userID];
    if (!isBlackList) {
        UIAlertAction *blacklistButton = [UIAlertAction actionWithTitle:ZBLocalized(@"Add to blacklist", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [weakSelf addBlickList];
        }];
        [actionSheet addAction:blacklistButton];
    }else{
        UIAlertAction *blacklistButton = [UIAlertAction actionWithTitle:ZBLocalized(@"Remove blacklist", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [ShowHUDTool showBriefAlert:ZBLocalized(@"Moved the other party out of the blacklist", nil)];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:self.userModel.userID];
        }];
        [actionSheet addAction:blacklistButton];
    }
    
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

//拉黑文字提示
- (void)addBlickList{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:ZBLocalized(@"Add to blacklist，you will not be able to receive his messages and video voice invitations", nil) preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:ZBLocalized(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    [alert addAction:cancelButton];
    
    UIAlertAction *confirmButton = [UIAlertAction actionWithTitle:ZBLocalized(@"Confirm", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:self.userModel.userID];
    }];
    [alert addAction:confirmButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}


//聊天
- (IBAction)chatAction:(UIButton *)sender {
    NIMSession *session = [NIMSession session:self.userModel.userID type:NIMSessionTypeP2P];
    ChatViewController *vc = [[ChatViewController alloc] initWithSession:session];
    [self.navigationController pushViewController:vc animated:YES];
}
//语音
- (IBAction)voiceChatAction:(UIButton *)sender {
    
    [self requestVideoInit:requestTypeVoice];
}

//视频
- (IBAction)videoChatAction:(UIButton *)sender {
    
    [self requestVideoInit:requestTypeVideo];
}

#pragma mark - ******* Request *******

//请求数据
- (void)requestMatchDetail
{
    
}

//音视频建立会话
- (void)requestVideoInit:(requestType)type
{
    WEAKSELF
    //会话类型，1音频，2视频
    NSString *typeStr = @"";
    if (type == requestTypeVoice) {
        typeStr = @"1";
    } else if (type == requestTypeVideo) {
        typeStr = @"2";
    }
    NSDictionary *params = @{@"type":typeStr,
                             @"user1":[BHUserModel sharedInstance].userID,   //主叫
                             @"user2":self.userModel.userID      //被叫
                             };
    [FSNetWorkManager requestWithType:HttpRequestTypePost
                        withUrlString:kApiGetVideoInit
                        withParaments:params
                     withSuccessBlock:^(NSDictionary *object) {
                         
                         if (NetResponseCheckStaus)
                         {
                             NSLog(@"请求成功");
                             NSDictionary *dataDic = object[@"data"];
                             
                             NSString *status = [dataDic stringValueForKey:@"status" default:@""];
                             NSString *tvId = [dataDic stringValueForKey:@"tvId" default:@""];
                             
                             if ([status isEqualToString:@"1"]) { //余额足够开启对话
                                 
                                 NSDictionary *nextDic = dataDic[@"next"];
                                 NSString *nextStatus = [nextDic stringValueForKey:@"status" default:@""];
                                 
                                 if ([nextStatus isEqualToString:@"1"]) {//余额足够开启下一分钟对话
                                     if (type == requestTypeVoice) { //音频
                                         MatchVoiceViewController * vc = [[MatchVoiceViewController alloc] initWithCallee:self.userModel.userID];
                                         vc.userModel = self.userModel;
                                         vc.tvId = tvId;
                                         [weakSelf pushViewControllerAsPresent:vc];
                                         
                                     } else if (type == requestTypeVideo){ //视频
                                         MatchVideoViewController * vc = [[MatchVideoViewController alloc] initWithCallee:self.userModel.userID];
                                         vc.userModel = self.userModel;
                                         vc.tvId = tvId;
                                         [weakSelf pushViewControllerAsPresent:vc];
                                     }
                                 }else if ([nextStatus isEqualToString:@"0"]){//余额不足以开启下一分钟对话
                                     UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:ZBLocalized(@"The current balance can only be called for 1 minute. Is it OK to initiate a call?", nil) preferredStyle:UIAlertControllerStyleAlert];
                                     [alertController addAction:[UIAlertAction actionWithTitle:ZBLocalized(@"Cancel", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                     }]];
                                     [alertController addAction:[UIAlertAction actionWithTitle:ZBLocalized(@"Confirm", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                         if (type == requestTypeVoice) { //音频
                                             MatchVoiceViewController * vc = [[MatchVoiceViewController alloc] initWithCallee:self.userModel.userID];
                                             vc.userModel = self.userModel;
                                             vc.tvId = tvId;
                                             [weakSelf pushViewControllerAsPresent:vc];
                                             
                                         } else if (type == requestTypeVideo){ //视频
                                             MatchVideoViewController * vc = [[MatchVideoViewController alloc] initWithCallee:self.userModel.userID];
                                             vc.userModel = self.userModel;
                                             vc.tvId = tvId;
                                             [weakSelf pushViewControllerAsPresent:vc];
                                         }
                                     }]];
                                     [weakSelf presentViewController:alertController animated:YES completion:nil];
                                 }
                             } else if ([status isEqualToString:@"0"]){ //余额不足以开启对话
                                 UIAlertController *alertController = [UIAlertController alertControllerWithTitle:ZBLocalized(@"Insufficient balance", nil) message:ZBLocalized(@"The current balance is not enough to continue, please recharge", nil) preferredStyle:UIAlertControllerStyleAlert];
                                 [alertController addAction:[UIAlertAction actionWithTitle:ZBLocalized(@"Cancel", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                 }]];
                                 [alertController addAction:[UIAlertAction actionWithTitle:ZBLocalized(@"Recharge", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                     MyRechargeViewController *chargeVC = [[MyRechargeViewController alloc] init];
                                     [weakSelf.navigationController pushViewController:chargeVC animated:YES];
                                 }]];
                                 [weakSelf presentViewController:alertController animated:YES completion:nil];
                             }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
