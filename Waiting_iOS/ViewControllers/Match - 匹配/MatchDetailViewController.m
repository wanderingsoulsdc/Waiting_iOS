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
    self.remarkLabel.text = kStringNotNull(self.userModel.remark)? self.userModel.remark : @"Ta还没有个性的自我介绍~"; //个人
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
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * self.imageScrollView.width, 0, self.imageScrollView.width, self.imageScrollView.height)];
        [imageView sd_setImageWithURL:[NSURL URLWithString:imageArr[i]] placeholderImage:kGetImageFromName(@"phone_default_head")];
        [self.imageScrollView addSubview:imageView];
    }
    self.imageScrollView.contentSize = CGSizeMake(self.imageScrollView.width * imageArr.count, 0);
}

- (void)createTagView{
    
    if (!kArrayNotNull(self.userModel.hobbyArray)) {
        _tagsNoDataLabel.hidden = NO;
        _tagsNoDataLabel.text = @"Ta没什么爱好";
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
    CGFloat page = scrollView.contentOffset.x / scrollView.frame.size.width;
    NSUInteger currentPage = page; //向下取整
    NSLog(@"%f === %ld",page,currentPage);
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
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromBottom;
    transition.delegate = self;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [self.navigationController popViewControllerAnimated:NO];
    //pop实现模态效果,注意：animated一定要设置为：NO
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
                             
                             NSString *isFee = [dataDic stringValueForKey:@"isFee" default:@""];
                             
                             if ([isFee isEqualToString:@"1"]) { //余额足够开启对话
                                 if (type == requestTypeVoice) { //音频
                                     MatchVoiceViewController * vc = [[MatchVoiceViewController alloc] initWithCallee:self.userModel.userID];
                                     vc.userModel = self.userModel;
                                     [weakSelf presentViewController:vc animated:YES completion:nil];
                                 } else if (type == requestTypeVideo){ //视频
                                     MatchVideoViewController * vc = [[MatchVideoViewController alloc] initWithCallee:self.userModel.userID];
                                     vc.userModel = self.userModel;
                                     [weakSelf presentViewController:vc animated:YES completion:nil];
                                 }
                             } else if ([isFee isEqualToString:@"0"]){ //余额不足以开启对话
                                 UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"余额不足" message:@"当前余额不足,请充值后进行操作" preferredStyle:UIAlertControllerStyleAlert];
                                 [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                 }]];
                                 [alertController addAction:[UIAlertAction actionWithTitle:@"充值" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                     MyRechargeViewController *chargeVC = [[MyRechargeViewController alloc] init];
                                     [self.navigationController pushViewController:chargeVC animated:YES];
                                 }]];
                                 [self presentViewController:alertController animated:YES completion:nil];
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
