//
//  LiteADsMessageSendDetailViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/8/1.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteADsMessageSendDetailViewController.h"
#import "LiteMessageSendDetailCell.h"
#import "FSNetWorkManager.h"
#import "Masonry.h"
#import "MJRefresh.h"
#import "BHSobotService.h"

@interface LiteADsMessageSendDetailViewController ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic , strong) UIView           * segmentView;   //选项卡视图
@property (nonatomic , strong) UIButton         * sendSuccessButton;//发送成功按钮
@property (nonatomic , strong) UIButton         * sendFailedButton; //发送失败按钮
@property (nonatomic , strong) UIButton         * sendingButton;    //发送中按钮
@property (nonatomic , strong) UIView           * indicatorView;    //指示器

@property (nonatomic , strong) UIScrollView     * scrollView;

@property (nonatomic , strong) UITableView     * sendSuccessTableView;  //发送成功列表
@property (nonatomic , strong) UITableView     * sendFailedTableView;   //发送失败列表
@property (nonatomic , strong) UITableView     * sendingTableView;      //发送中列表

@property (nonatomic , strong) NSMutableArray       * sendSuccessListArray;//发送成功列表数据
@property (nonatomic , strong) NSMutableArray       * sendFailedListArray; //发送失败列表数据
@property (nonatomic , strong) NSMutableArray       * sendingListArray;    //发送中列表数据


@property (nonatomic , strong) BHLoadFailedView     * sendSuccessNoDataView; //发送成功无数据
@property (nonatomic , strong) BHLoadFailedView     * sendFailedNoDataView;  //发送失败无数据
@property (nonatomic , strong) BHLoadFailedView     * sendingNoDataView;     //发送中无数据

@property (nonatomic , assign) NSInteger            sendSuccessCurrentPage; //发送成功当前页数
@property (nonatomic , assign) NSInteger            sendFailedCurrentPage;  //发送失败当前页数
@property (nonatomic , assign) NSInteger            sendingCurrentPage;     //发送中当前页数

@property (nonatomic , strong) UIButton             * contactServiceButton; //联系客服

@end

@implementation LiteADsMessageSendDetailViewController

#pragma mark - ******* Life Cycle *******

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"短信发送明细";
    [self createUI];
    
    [self initWithAutoRefresh];
    
    [self sendSuccessLoadNewData];
    [self sendFailedLoadNewData];
    [self sendingLoadNewData];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
#pragma mark - ******* UI Methods *******
- (void)createUI{
    
    [self.view addSubview:self.segmentView];
    [self.segmentView addSubview:self.sendSuccessButton];
    [self.segmentView addSubview:self.sendFailedButton];
    [self.segmentView addSubview:self.sendingButton];
    [self.segmentView addSubview:self.indicatorView];

    [self.view addSubview:self.scrollView];
    
    [self.scrollView addSubview:self.sendSuccessNoDataView];
    [self.scrollView addSubview:self.sendFailedNoDataView];
    [self.scrollView addSubview:self.sendingNoDataView];
    
    [self.scrollView addSubview:self.sendSuccessTableView];
    [self.scrollView addSubview:self.sendFailedTableView];
    [self.scrollView addSubview:self.sendingTableView];
    
    [self.view addSubview:self.contactServiceButton];
    //调整一下视图层级关系
    [self.view bringSubviewToFront:self.contactServiceButton]; //客服按钮移动到最上层
    
    [self layoutSubviews];
}

- (void)layoutSubviews{
    
    [self.segmentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(1);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@54);
    }];

    [self.sendSuccessButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.equalTo(self.segmentView);
        make.width.equalTo(self.segmentView.mas_width).multipliedBy(1.0f/3.0f);
    }];
    
    [self.sendFailedButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.segmentView);
        make.left.equalTo(self.sendSuccessButton.mas_right);
        make.width.equalTo(self.segmentView.mas_width).multipliedBy(1.0f/3.0f);
    }];

    [self.sendingButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.equalTo(self.segmentView);
        make.width.equalTo(self.segmentView.mas_width).multipliedBy(1.0f/3.0f);
    }];

    [self.indicatorView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.segmentView.mas_bottom);
        make.centerX.equalTo(self.sendSuccessButton.mas_centerX);
        make.height.equalTo(@3);
        make.width.equalTo(@12);
    }];
    
    [self.scrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.segmentView.mas_bottom).offset(1);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(0 - SafeAreaBottomHeight);
    }];

    //约束转化成frame,需要一个过程(可能0.1s就完成)
    [self.scrollView.superview layoutIfNeeded];
    [self performSelector:@selector(setScrollSubViewsHeight) withObject:nil afterDelay:0.1];
    
    [self.contactServiceButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@54);
        make.right.equalTo(self.view).offset(-10);
        make.bottom.equalTo(self.view).offset(-(20 + SafeAreaBottomHeight));
    }];
}

- (void)setScrollSubViewsHeight{
    self.sendSuccessTableView.height = self.scrollView.height;
    self.sendFailedTableView.height = self.scrollView.height;
    self.sendingTableView.height = self.scrollView.height;
    
    self.sendSuccessNoDataView.height = self.scrollView.height;
    self.sendFailedNoDataView.height = self.scrollView.height;
    self.sendingNoDataView.height = self.scrollView.height;
}

#pragma mark - ******* Refresh *******

- (void)initWithAutoRefresh
{
    // 上拉加载更多 (发送成功)
    MJRefreshAutoNormalFooter * footer1 = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(sendSuccessLoadMoreData)];
    footer1.stateLabel.textColor = UIColorFooderText;
    // 设置文字
    [footer1 setTitle:@"" forState:MJRefreshStateIdle];
    [footer1 setTitle:@"加载数据中~喵~" forState:MJRefreshStateRefreshing];
    [footer1 setTitle:@"全部加载完啦~喵喵~" forState:MJRefreshStateNoMoreData];
    
    self.sendSuccessTableView.mj_footer = footer1;
    // Enter the refresh status immediately
    
    // 上拉加载更多 (发送失败)
    MJRefreshAutoNormalFooter * footer2 = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(sendFailedLoadMoreData)];
    footer2.stateLabel.textColor = UIColorFooderText;
    // 设置文字
    [footer2 setTitle:@"" forState:MJRefreshStateIdle];
    [footer2 setTitle:@"加载数据中~喵~" forState:MJRefreshStateRefreshing];
    [footer2 setTitle:@"全部加载完啦~喵喵~" forState:MJRefreshStateNoMoreData];
    
    self.sendFailedTableView.mj_footer = footer2;
    
    // 上拉加载更多 (发送中)
    MJRefreshAutoNormalFooter * footer3 = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(sendingLoadMoreData)];
    footer3.stateLabel.textColor = UIColorFooderText;
    // 设置文字
    [footer3 setTitle:@"" forState:MJRefreshStateIdle];
    [footer3 setTitle:@"加载数据中~喵~" forState:MJRefreshStateRefreshing];
    [footer3 setTitle:@"全部加载完啦~喵喵~" forState:MJRefreshStateNoMoreData];
    
    self.sendingTableView.mj_footer = footer3;
}

- (void)sendSuccessLoadNewData
{
    self.sendSuccessCurrentPage = 1;
    [self.sendSuccessListArray removeAllObjects];
    self.sendSuccessTableView.mj_footer.hidden = NO;
    [self.sendSuccessTableView.mj_footer resetNoMoreData];
    [self requestMessageSendSuccessDetail];
}

- (void)sendSuccessLoadMoreData
{
    self.sendSuccessCurrentPage ++;
    [self requestMessageSendSuccessDetail];
}

- (void)sendFailedLoadNewData
{
    self.sendFailedCurrentPage = 1;
    [self.sendFailedListArray removeAllObjects];
    self.sendFailedTableView.mj_footer.hidden = NO;
    [self.sendFailedTableView.mj_footer resetNoMoreData];
    [self requestMessageSendFailedDetail];
}

- (void)sendFailedLoadMoreData
{
    self.sendFailedCurrentPage ++;
    [self requestMessageSendFailedDetail];
}

- (void)sendingLoadNewData
{
    self.sendingCurrentPage = 1;
    [self.sendingListArray removeAllObjects];
    self.sendingTableView.mj_footer.hidden = NO;
    [self.sendingTableView.mj_footer resetNoMoreData];
    [self requestMessageSendingDetail];
}

- (void)sendingLoadMoreData
{
    self.sendingCurrentPage ++;
    [self requestMessageSendingDetail];
}

#pragma mark - ******* Action Methods *******

- (void)segmentButtonAction:(UIButton *)button{
    button.highlighted = NO;
    if (button == self.sendSuccessButton) {      //发送成功
        self.sendSuccessButton.selected = YES;
        self.sendFailedButton.selected = NO;
        self.sendingButton.selected = NO;
        [UIView animateWithDuration:0.1f animations:^{
            [self.indicatorView setLeft:(self.sendSuccessButton.width - self.indicatorView.width)/2];
            self.scrollView.contentOffset =CGPointMake(0, 0);
        }];
    } else if (button == self.sendFailedButton){ //发送失败
        self.sendSuccessButton.selected = NO;
        self.sendFailedButton.selected = YES;
        self.sendingButton.selected = NO;
        [UIView animateWithDuration:0.1f animations:^{
            [self.indicatorView setLeft:(self.sendFailedButton.width - self.indicatorView.width)/2 + self.sendFailedButton.left];
            self.scrollView.contentOffset = CGPointMake(kScreenWidth, 0);
        }];
    } else if (button == self.sendingButton){ //发送中
        self.sendSuccessButton.selected = NO;
        self.sendFailedButton.selected = NO;
        self.sendingButton.selected = YES;
        [UIView animateWithDuration:0.1f animations:^{
            [self.indicatorView setLeft:(self.sendingButton.width - self.indicatorView.width)/2 + self.sendingButton.left];
            self.scrollView.contentOffset = CGPointMake(kScreenWidth * 2, 0);
        }];
    }
}

//联系客服
- (void)contactServiceAction:(UIButton *)sender {
    [[BHSobotService sharedInstance] startSoBotCustomerServiceWithViewController:self];
}

#pragma mark - ******* Scroll Delegate *******

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (![scrollView isEqual:self.scrollView]) {
        return;
    }
    CGFloat OffsetX = scrollView.contentOffset.x;
    if (OffsetX == kScreenWidth * 2) {
        //滑到第三个按钮
        self.sendSuccessButton.selected = NO;
        self.sendFailedButton.selected = NO;
        self.sendingButton.selected = YES;
        
        [UIView animateWithDuration:0.1f animations:^{
            [self.indicatorView setLeft:(self.sendingButton.width - self.indicatorView.width)/2 + self.sendingButton.left];
        }];
        
    }else if (OffsetX == kScreenWidth) {
        //滑到第二个按钮
        self.sendSuccessButton.selected = NO;
        self.sendFailedButton.selected = YES;
        self.sendingButton.selected = NO;
        [UIView animateWithDuration:0.1f animations:^{
            [self.indicatorView setLeft:(self.sendFailedButton.width - self.indicatorView.width)/2 + self.sendFailedButton.left];
        }];
    }else{
        //滑到第一个按钮
        self.sendSuccessButton.selected = YES;
        self.sendFailedButton.selected = NO;
        self.sendingButton.selected = NO;
        [UIView animateWithDuration:0.1f animations:^{
            [self.indicatorView setLeft:(self.sendSuccessButton.width - self.indicatorView.width)/2];
        }];
    }
}

#pragma mark - ******* UITableView Delegate *******

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.sendSuccessTableView) {
        return self.sendSuccessListArray.count;
    } else if (tableView == self.sendFailedTableView){
        return self.sendFailedListArray.count;
    } else if (tableView == self.sendingTableView){
        return self.sendingListArray.count;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LiteMessageSendDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(self.class) forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    LiteADsPhoneListModel *model = nil;
    
    if (tableView == self.sendSuccessTableView) {
        model = self.sendSuccessListArray[indexPath.row];
    } else if (tableView == self.sendFailedTableView){
        model = self.sendFailedListArray[indexPath.row];
    } else if (tableView == self.sendingTableView){
        model = self.sendingListArray[indexPath.row];
    }
    [cell configWithData:model];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 73.0f;
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
    return 0.1f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"点击了cell");
}

#pragma mark - ******* Request Methods *******

//短信发送详情(成功)
- (void)requestMessageSendSuccessDetail
{
    WEAKSELF
    NSDictionary * params = @{@"page":@(self.sendSuccessCurrentPage),
                              @"pageNum":@"20",
                              @"orderId":self.messageModel.orderId,
                              @"status":@"2"  //发送状态 1 发送中 2 成功 3 失败
                              };
    [FSNetWorkManager requestWithType:HttpRequestTypeGet
                        withUrlString:kApiMessageGetSendDetail
                        withParaments:params
                     withSuccessBlock:^(NSDictionary *object) {
                         
                         if ([self.sendSuccessTableView.mj_footer isRefreshing]) {
                             [self.sendSuccessTableView.mj_footer endRefreshing];
                         }
                         
                         if (NetResponseCheckStaus)
                         {
                             NSLog(@"请求成功");
                             NSDictionary *dic = object[@"data"];
                             
                             NSDictionary *totalNumDic = dic[@"totalNum"];
                             [weakSelf.sendSuccessButton setTitle:[NSString stringWithFormat:@"发送成功\n%@",[totalNumDic stringValueForKey:@"sendSuccessNum" default:@"0"]] forState:UIControlStateNormal];
                             [weakSelf.sendSuccessButton setTitle:[NSString stringWithFormat:@"发送成功\n%@",[totalNumDic stringValueForKey:@"sendSuccessNum" default:@"0"]] forState:UIControlStateSelected];
                              
                             [weakSelf.sendFailedButton setTitle:[NSString stringWithFormat:@"发送失败\n%@",[totalNumDic stringValueForKey:@"sendFailNum" default:@"0"]] forState:UIControlStateNormal];
                             [weakSelf.sendFailedButton setTitle:[NSString stringWithFormat:@"发送失败\n%@",[totalNumDic stringValueForKey:@"sendFailNum" default:@"0"]] forState:UIControlStateSelected];
                             
                             [weakSelf.sendingButton setTitle:[NSString stringWithFormat:@"发送中\n%@",[totalNumDic stringValueForKey:@"sendInNum" default:@"0"]] forState:UIControlStateNormal];
                             [weakSelf.sendingButton setTitle:[NSString stringWithFormat:@"发送中\n%@",[totalNumDic stringValueForKey:@"sendInNum" default:@"0"]] forState:UIControlStateSelected];
                             
                             NSArray * array = [dic objectForKey:@"list"];
                             if (array.count > 0)
                             {
                                 for (NSDictionary * dict in array)
                                 {
                                     LiteADsPhoneListModel * model = [[LiteADsPhoneListModel alloc] init];
                                     model.phone = [dict stringValueForKey:@"phone" default:@""];
                                     model.cipherPhone = [dict stringValueForKey:@"cipherPhone" default:@""];
                                     
                                     [self.sendSuccessListArray addObject:model];
                                 }
                                 
                                 [self.sendSuccessTableView reloadData];
                                 
                                 NSUInteger totalPage = [[dic stringValueForKey:@"totalPage" default:@""] integerValue];
                                 if (self.sendSuccessCurrentPage >= totalPage) {
                                     [self.sendSuccessTableView.mj_footer endRefreshingWithNoMoreData];
                                     
                                 }
                                 self.sendSuccessNoDataView.hidden = YES;
                             }
                             else
                             {
                                 if (self.sendSuccessCurrentPage == 1)
                                 {
                                     // 第一页无数据
                                     [self.sendSuccessListArray removeAllObjects];
                                     [self.sendSuccessTableView reloadData];
                                     self.sendSuccessTableView.mj_footer.hidden = YES;
                                     self.sendSuccessNoDataView.hidden = NO;
                                 }
                                 else
                                 {
                                     self.sendSuccessCurrentPage -- ;
                                     [self.sendSuccessTableView.mj_footer endRefreshingWithNoMoreData];
                                 }
                             }
                         }
                         else
                         {
                             [ShowHUDTool showBriefAlert:NetResponseMessage];
                         }
                     } withFailureBlock:^(NSError *error) {
                         NSLog(@"error is:%@", error);
                         [ShowHUDTool showBriefAlert:NetRequestFailed];
                         
                         if ([self.sendSuccessTableView.mj_footer isRefreshing]) {
                             [self.sendSuccessTableView.mj_footer endRefreshing];
                             self.sendSuccessCurrentPage -- ;
                         }
                     }];
}

//短信发送详情(失败)
- (void)requestMessageSendFailedDetail
{
    WEAKSELF
    NSDictionary * params = @{@"page":@(self.sendFailedCurrentPage),
                              @"pageNum":@"20",
                              @"orderId":self.messageModel.orderId,
                              @"status":@"3"  //发送状态 1 发送中 2 成功 3 失败
                              };
    [FSNetWorkManager requestWithType:HttpRequestTypeGet
                        withUrlString:kApiMessageGetSendDetail
                        withParaments:params
                     withSuccessBlock:^(NSDictionary *object) {
                         
                         if ([self.sendFailedTableView.mj_footer isRefreshing]) {
                             [self.sendFailedTableView.mj_footer endRefreshing];
                         }
                         
                         if (NetResponseCheckStaus)
                         {
                             NSLog(@"请求成功");
                             NSDictionary *dic = object[@"data"];
                             
                             NSDictionary *totalNumDic = dic[@"totalNum"];
                             [weakSelf.sendSuccessButton setTitle:[NSString stringWithFormat:@"发送成功\n%@",[totalNumDic stringValueForKey:@"sendSuccessNum" default:@"0"]] forState:UIControlStateNormal];
                             [weakSelf.sendSuccessButton setTitle:[NSString stringWithFormat:@"发送成功\n%@",[totalNumDic stringValueForKey:@"sendSuccessNum" default:@"0"]] forState:UIControlStateSelected];
                             
                             [weakSelf.sendFailedButton setTitle:[NSString stringWithFormat:@"发送失败\n%@",[totalNumDic stringValueForKey:@"sendFailNum" default:@"0"]] forState:UIControlStateNormal];
                             [weakSelf.sendFailedButton setTitle:[NSString stringWithFormat:@"发送失败\n%@",[totalNumDic stringValueForKey:@"sendFailNum" default:@"0"]] forState:UIControlStateSelected];
                             
                             [weakSelf.sendingButton setTitle:[NSString stringWithFormat:@"发送中\n%@",[totalNumDic stringValueForKey:@"sendInNum" default:@"0"]] forState:UIControlStateNormal];
                             [weakSelf.sendingButton setTitle:[NSString stringWithFormat:@"发送中\n%@",[totalNumDic stringValueForKey:@"sendInNum" default:@"0"]] forState:UIControlStateSelected];
                             
                             NSArray * array = [dic objectForKey:@"list"];
                             if (array.count > 0)
                             {
                                 for (NSDictionary * dict in array)
                                 {
                                     LiteADsPhoneListModel * model = [[LiteADsPhoneListModel alloc] init];
                                     model.phone = [dict stringValueForKey:@"phone" default:@""];
                                     model.cipherPhone = [dict stringValueForKey:@"cipherPhone" default:@""];
                                     
                                     [self.sendFailedListArray addObject:model];
                                 }
                                 
                                 [self.sendFailedTableView reloadData];
                                 
                                 NSUInteger totalPage = [[dic stringValueForKey:@"totalPage" default:@""] integerValue];
                                 if (self.sendFailedCurrentPage >= totalPage) {
                                     [self.sendFailedTableView.mj_footer endRefreshingWithNoMoreData];
                                     
                                 }
                                 self.sendFailedNoDataView.hidden = YES;
                             }
                             else
                             {
                                 if (self.sendFailedCurrentPage == 1)
                                 {
                                     // 第一页无数据
                                     [self.sendFailedListArray removeAllObjects];
                                     [self.sendFailedTableView reloadData];
                                     self.sendFailedTableView.mj_footer.hidden = YES;
                                     self.sendFailedNoDataView.hidden = NO;
                                 }
                                 else
                                 {
                                     self.sendFailedCurrentPage -- ;
                                     [self.sendFailedTableView.mj_footer endRefreshingWithNoMoreData];
                                 }
                             }
                         }
                         else
                         {
                             [ShowHUDTool showBriefAlert:NetResponseMessage];
                         }
                     } withFailureBlock:^(NSError *error) {
                         NSLog(@"error is:%@", error);
                         [ShowHUDTool showBriefAlert:NetRequestFailed];
                         
                         if ([self.sendFailedTableView.mj_footer isRefreshing]) {
                             [self.sendFailedTableView.mj_footer endRefreshing];
                             self.sendFailedCurrentPage -- ;
                         }
                     }];
}


//短信发送详情(发送中)
- (void)requestMessageSendingDetail
{
    WEAKSELF
    NSDictionary * params = @{@"page":@(self.sendingCurrentPage),
                              @"pageNum":@"20",
                              @"orderId":self.messageModel.orderId,
                              @"status":@"1"  //发送状态 1 发送中 2 成功 3 失败
                              };
    [FSNetWorkManager requestWithType:HttpRequestTypeGet
                        withUrlString:kApiMessageGetSendDetail
                        withParaments:params
                     withSuccessBlock:^(NSDictionary *object) {
                         
                         if ([self.sendingTableView.mj_footer isRefreshing]) {
                             [self.sendingTableView.mj_footer endRefreshing];
                         }
                         
                         if (NetResponseCheckStaus)
                         {
                             NSLog(@"请求成功");
                             NSDictionary *dic = object[@"data"];
                             
                             NSDictionary *totalNumDic = dic[@"totalNum"];
                             [weakSelf.sendSuccessButton setTitle:[NSString stringWithFormat:@"发送成功\n%@",[totalNumDic stringValueForKey:@"sendSuccessNum" default:@"0"]] forState:UIControlStateNormal];
                             [weakSelf.sendSuccessButton setTitle:[NSString stringWithFormat:@"发送成功\n%@",[totalNumDic stringValueForKey:@"sendSuccessNum" default:@"0"]] forState:UIControlStateSelected];
                             
                             [weakSelf.sendFailedButton setTitle:[NSString stringWithFormat:@"发送失败\n%@",[totalNumDic stringValueForKey:@"sendFailNum" default:@"0"]] forState:UIControlStateNormal];
                             [weakSelf.sendFailedButton setTitle:[NSString stringWithFormat:@"发送失败\n%@",[totalNumDic stringValueForKey:@"sendFailNum" default:@"0"]] forState:UIControlStateSelected];
                             
                             [weakSelf.sendingButton setTitle:[NSString stringWithFormat:@"发送中\n%@",[totalNumDic stringValueForKey:@"sendInNum" default:@"0"]] forState:UIControlStateNormal];
                             [weakSelf.sendingButton setTitle:[NSString stringWithFormat:@"发送中\n%@",[totalNumDic stringValueForKey:@"sendInNum" default:@"0"]] forState:UIControlStateSelected];
                             
                             NSArray * array = [dic objectForKey:@"list"];
                             if (array.count > 0)
                             {
                                 for (NSDictionary * dict in array)
                                 {
                                     LiteADsPhoneListModel * model = [[LiteADsPhoneListModel alloc] init];
                                     model.phone = [dict stringValueForKey:@"phone" default:@""];
                                     model.cipherPhone = [dict stringValueForKey:@"cipherPhone" default:@""];
                                     
                                     [self.sendingListArray addObject:model];
                                 }
                                 
                                 [self.sendingTableView reloadData];
                                 
                                 NSUInteger totalPage = [[dic stringValueForKey:@"totalPage" default:@""] integerValue];
                                 if (self.sendingCurrentPage >= totalPage) {
                                     [self.sendingTableView.mj_footer endRefreshingWithNoMoreData];
                                     
                                 }
                                 self.sendingNoDataView.hidden = YES;
                             }
                             else
                             {
                                 if (self.sendingCurrentPage == 1)
                                 {
                                     // 第一页无数据
                                     [self.sendingListArray removeAllObjects];
                                     [self.sendingTableView reloadData];
                                     self.sendingTableView.mj_footer.hidden = YES;
                                     self.sendingNoDataView.hidden = NO;
                                 }
                                 else
                                 {
                                     self.sendingCurrentPage -- ;
                                     [self.sendingTableView.mj_footer endRefreshingWithNoMoreData];
                                 }
                             }
                         }
                         else
                         {
                             [ShowHUDTool showBriefAlert:NetResponseMessage];
                         }
                     } withFailureBlock:^(NSError *error) {
                         NSLog(@"error is:%@", error);
                         [ShowHUDTool showBriefAlert:NetRequestFailed];
                         
                         if ([self.sendingTableView.mj_footer isRefreshing]) {
                             [self.sendingTableView.mj_footer endRefreshing];
                             self.sendingCurrentPage -- ;
                         }
                     }];
}



#pragma mark - ******* Getter *******

- (UIView *)segmentView{
    if (!_segmentView) {
        _segmentView = [[UIView alloc] init];
        _segmentView.backgroundColor = UIColorWhite;
    }
    return _segmentView;
}

- (UIButton *)sendSuccessButton{
    if (!_sendSuccessButton) {
        _sendSuccessButton = [[UIButton alloc] init];
        [_sendSuccessButton setTitle:@"发送成功\n0" forState:UIControlStateNormal];
        [_sendSuccessButton setTitle:@"发送成功\n0" forState:UIControlStateSelected];
        [_sendSuccessButton setTitleColor:UIColorlightGray forState:UIControlStateNormal];
        [_sendSuccessButton setTitleColor:UIColorBlue forState:UIControlStateSelected];
        
        [_sendSuccessButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_sendSuccessButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_sendSuccessButton.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
        //这句话很重要，不加这句话加上换行符也没用
        _sendSuccessButton.selected = YES;
        [_sendSuccessButton addTarget:self action:@selector(segmentButtonAction:) forControlEvents:UIControlEventTouchUpInside | UIControlEventAllTouchEvents];
    }
    return _sendSuccessButton;
}

- (UIButton *)sendFailedButton{
    if (!_sendFailedButton) {
        _sendFailedButton = [[UIButton alloc] init];
        [_sendFailedButton setTitle:@"发送失败\n0" forState:UIControlStateNormal];
        [_sendFailedButton setTitle:@"发送失败\n0" forState:UIControlStateSelected];
        [_sendFailedButton setTitleColor:UIColorlightGray forState:UIControlStateNormal];
        [_sendFailedButton setTitleColor:UIColorBlue forState:UIControlStateSelected];
        
        [_sendFailedButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_sendFailedButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_sendFailedButton.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
        //这句话很重要，不加这句话加上换行符也没用
        [_sendFailedButton addTarget:self action:@selector(segmentButtonAction:) forControlEvents:UIControlEventTouchUpInside | UIControlEventAllTouchEvents];
    }
    return _sendFailedButton;
}

- (UIButton *)sendingButton{
    if (!_sendingButton) {
        _sendingButton = [[UIButton alloc] init];
        [_sendingButton setTitle:@"发送中\n0" forState:UIControlStateNormal];
        [_sendingButton setTitle:@"发送中\n0" forState:UIControlStateSelected];
        [_sendingButton setTitleColor:UIColorlightGray forState:UIControlStateNormal];
        [_sendingButton setTitleColor:UIColorBlue forState:UIControlStateSelected];
        
        [_sendingButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_sendingButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_sendingButton.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
        //这句话很重要，不加这句话加上换行符也没用
        [_sendingButton addTarget:self action:@selector(segmentButtonAction:) forControlEvents:UIControlEventTouchUpInside | UIControlEventAllTouchEvents];
        
    }
    return _sendingButton;
}

- (UIView *)indicatorView{
    if (!_indicatorView) {
        _indicatorView = [[UIView alloc] init];
        _indicatorView.backgroundColor = UIColorBlue;
    }
    return _indicatorView;
}

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        // 创建UIScrollView
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = UIColorClearColor;
        _scrollView.bounces = NO;
        // 设置scrollView的属性
        _scrollView.pagingEnabled = YES;
        // 设置UIScrollView的滚动范围（内容大小）
        _scrollView.contentSize = CGSizeMake(kScreenWidth*3, 300);
        _scrollView.delegate = self;
        // 隐藏水平滚动条
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        
    }
    return _scrollView;
}

- (UITableView *)sendSuccessTableView
{
    if (!_sendSuccessTableView)
    {
        _sendSuccessTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 200) style:UITableViewStyleGrouped];
        _sendSuccessTableView.backgroundColor = UIColorClearColor;
        _sendSuccessTableView.delegate = self;
        _sendSuccessTableView.dataSource = self;
        //        _tableView.bounces = NO;
        
        // 分割线位置
        _sendSuccessTableView.separatorInset = UIEdgeInsetsMake(0,10, 0, 10);
        _sendSuccessTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _sendSuccessTableView.separatorColor = UIColorLine;  // 分割线颜色
        
        if (@available(iOS 11.0, *)) {
            _sendSuccessTableView.estimatedRowHeight = 0;
            _sendSuccessTableView.estimatedSectionHeaderHeight = 0;
            _sendSuccessTableView.estimatedSectionFooterHeight = 0;
            _sendSuccessTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        [_sendSuccessTableView registerClass:[LiteMessageSendDetailCell class] forCellReuseIdentifier:NSStringFromClass(self.class)];
    }
    return _sendSuccessTableView;
}

- (UITableView *)sendFailedTableView
{
    if (!_sendFailedTableView)
    {
        _sendFailedTableView = [[UITableView alloc] initWithFrame:CGRectMake(kScreenWidth, 0, kScreenWidth, 200) style:UITableViewStyleGrouped];
        _sendFailedTableView.backgroundColor = UIColorClearColor;
        _sendFailedTableView.delegate = self;
        _sendFailedTableView.dataSource = self;
        //        _tableView.bounces = NO;
        
        // 分割线位置
        _sendFailedTableView.separatorInset = UIEdgeInsetsMake(0,10, 0, 10);
        _sendFailedTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _sendFailedTableView.separatorColor = UIColorLine;  // 分割线颜色
        
        if (@available(iOS 11.0, *)) {
            _sendFailedTableView.estimatedRowHeight = 0;
            _sendFailedTableView.estimatedSectionHeaderHeight = 0;
            _sendFailedTableView.estimatedSectionFooterHeight = 0;
            _sendFailedTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        [_sendFailedTableView registerClass:[LiteMessageSendDetailCell class] forCellReuseIdentifier:NSStringFromClass(self.class)];
    }
    return _sendFailedTableView;
}

- (UITableView *)sendingTableView
{
    if (!_sendingTableView)
    {
        _sendingTableView = [[UITableView alloc] initWithFrame:CGRectMake(kScreenWidth * 2, 0, kScreenWidth, 200) style:UITableViewStyleGrouped];
        _sendingTableView.backgroundColor = UIColorClearColor;
        _sendingTableView.delegate = self;
        _sendingTableView.dataSource = self;
        //        _sendingTableView.bounces = NO;
        
        // 分割线位置
        _sendingTableView.separatorInset = UIEdgeInsetsMake(0,10, 0, 10);
        _sendingTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _sendingTableView.separatorColor = UIColorLine;  // 分割线颜色
        
        if (@available(iOS 11.0, *)) {
            _sendingTableView.estimatedRowHeight = 0;
            _sendingTableView.estimatedSectionHeaderHeight = 0;
            _sendingTableView.estimatedSectionFooterHeight = 0;
            _sendingTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        [_sendingTableView registerClass:[LiteMessageSendDetailCell class] forCellReuseIdentifier:NSStringFromClass(self.class)];
    }
    return _sendingTableView;
}

- (NSMutableArray *)sendSuccessListArray
{
    if (!_sendSuccessListArray)
    {
        _sendSuccessListArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _sendSuccessListArray;
}

- (NSMutableArray *)sendFailedListArray
{
    if (!_sendFailedListArray)
    {
        _sendFailedListArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _sendFailedListArray;
}

- (NSMutableArray *)sendingListArray
{
    if (!_sendingListArray)
    {
        _sendingListArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _sendingListArray;
}

- (BHLoadFailedView *)sendSuccessNoDataView
{
    if (!_sendSuccessNoDataView)
    {
        _sendSuccessNoDataView = [[BHLoadFailedView alloc] init];
        _sendSuccessNoDataView.backgroundColor = [UIColor clearColor];
        _sendSuccessNoDataView.hidden = YES;
        
        _sendSuccessNoDataView.frame = CGRectMake(0,0, kScreenWidth, 200);
        _sendSuccessNoDataView.loadFailedImageView.image = [UIImage imageNamed:@"no_data"];
        _sendSuccessNoDataView.loadFailedLabel.text = @"没有数据啊！喵~";
    }
    return _sendSuccessNoDataView;
}

- (BHLoadFailedView *)sendFailedNoDataView
{
    if (!_sendFailedNoDataView)
    {
        _sendFailedNoDataView = [[BHLoadFailedView alloc] init];
        _sendFailedNoDataView.backgroundColor = [UIColor clearColor];
        _sendFailedNoDataView.hidden = YES;
        
        _sendFailedNoDataView.frame = CGRectMake(kScreenWidth, 0, kScreenWidth, 200);
        _sendFailedNoDataView.loadFailedImageView.image = [UIImage imageNamed:@"no_data"];
        _sendFailedNoDataView.loadFailedLabel.text = @"没有数据啊！喵~";
    }
    return _sendFailedNoDataView;
}

- (BHLoadFailedView *)sendingNoDataView
{
    if (!_sendingNoDataView)
    {
        _sendingNoDataView = [[BHLoadFailedView alloc] init];
        _sendingNoDataView.backgroundColor = [UIColor clearColor];
        _sendingNoDataView.hidden = YES;
        
        _sendingNoDataView.frame = CGRectMake(kScreenWidth * 2 , 0, kScreenWidth, 200);
        _sendingNoDataView.loadFailedImageView.image = [UIImage imageNamed:@"no_data"];
        _sendingNoDataView.loadFailedLabel.text = @"没有数据啊！喵~";
    }
    return _sendingNoDataView;
}

- (UIButton *)contactServiceButton{
    
    if (!_contactServiceButton) {
        _contactServiceButton = [[UIButton alloc] init];
        [_contactServiceButton setImage:[UIImage imageNamed:@"ads_contact_service"] forState:UIControlStateNormal];
        _contactServiceButton.adjustsImageWhenHighlighted = NO;// 取消图片的高亮状态
        [_contactServiceButton addTarget:self action:@selector(contactServiceAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _contactServiceButton;
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
