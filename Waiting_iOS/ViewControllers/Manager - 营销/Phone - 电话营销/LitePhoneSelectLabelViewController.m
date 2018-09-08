//
//  LitePhoneSelectLabelViewController.m
//  
//
//  Created by wander on 2018/7/18.
//

#import "LitePhoneSelectLabelViewController.h"
#import "Masonry.h"
#import "FSNetWorkManager.h"
#import "LiteDeviceModel.h"
#import "LiteLabelModel.h"
#import "LiteADsSelectLabelCell.h"
#import "LitePhoneSelectCustomViewController.h"

//********* ↓↓↓↓↓↓ 自定义selectDeviceButton，用于选择设备展示 ↓↓↓↓↓↓ *********

@interface selectDeviceButton : UIButton

//@property (nonatomic , assign) BOOL          selected;
@property (nonatomic , strong) UIImageView   * deviceImageView;
@property (nonatomic , strong) UILabel       * nameLabel;
@property (nonatomic , strong) UILabel       * macLabel;
@property (nonatomic , strong) UILabel       * badgeLabel;   //角标
@property (nonatomic , strong) UIView        * indicatorView;
@property (nonatomic , strong) UIImage       * selectedImage;
@property (nonatomic , strong) UIImage       * unselectedImage;

@end

@implementation selectDeviceButton

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        _deviceImageView = [[UIImageView alloc] init];
        _deviceImageView.image = _unselectedImage;
        [self addSubview:_deviceImageView];
        
        _badgeLabel = [[UILabel alloc] init];
        _badgeLabel.backgroundColor = UIColorError;
        _badgeLabel.textColor = UIColorWhite;
        _badgeLabel.font = [UIFont systemFontOfSize:9];
        _badgeLabel.textAlignment = NSTextAlignmentCenter;
        _badgeLabel.text = @"0";
        _badgeLabel.hidden = YES;
        [self addSubview:_badgeLabel];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.textColor = UIColorDarkBlack;
        _nameLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:_nameLabel];
        
        _macLabel = [[UILabel alloc] init];
        _macLabel.textAlignment = NSTextAlignmentCenter;
        _macLabel.textColor = UIColorlightGray;
        _macLabel.font = [UIFont systemFontOfSize:9];
        [self addSubview:_macLabel];
        
        _indicatorView = [[UIView alloc] init];
        _indicatorView.backgroundColor = UIColorBlue;
        _indicatorView.hidden = YES;
        [self addSubview:_indicatorView];
        
        CGFloat imageViewWH = frame.size.height* (42.0/100.0);
        
        [self.deviceImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(frame.size.height * (12.0/100.0));
            make.centerX.equalTo(self);
            make.width.height.mas_equalTo(imageViewWH);
        }];
        
        [self.badgeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.deviceImageView.mas_right);
            make.centerY.equalTo(self.deviceImageView.mas_top);
            make.height.width.mas_equalTo(frame.size.height * (14.0/100.0));
        }];
        
        self.badgeLabel.layer.cornerRadius = frame.size.height * (14.0/100.0) /2;
        self.badgeLabel.layer.masksToBounds = YES;
        
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.top.equalTo(self.deviceImageView.mas_bottom).offset(frame.size.height * (4.0/100.0));
            make.height.mas_equalTo(frame.size.height * (17.0/100.0));
        }];
        
        [self.macLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.top.equalTo(self.nameLabel.mas_bottom);
            make.height.mas_equalTo(frame.size.height * (13.0/100.0));
        }];
        
        [self.indicatorView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.bottom.equalTo(self);
            make.width.mas_equalTo(frame.size.height * (20.0/100.0));
            make.height.mas_equalTo(frame.size.height * (4.0/100.0));
        }];
    }
    return self;
}

- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    if (selected) {
        _indicatorView.hidden = NO;
        _deviceImageView.image = _selectedImage;
    }else{
        _indicatorView.hidden = YES;
        _deviceImageView.image = _unselectedImage;
    }
}

- (void)setUnselectedImage:(UIImage *)unselectedImage{
    _unselectedImage = unselectedImage;
    _deviceImageView.image = unselectedImage;
}

@end
//********* ↑↑↑↑↑↑ 自定义selectDeviceButton，用于选择设备展示 ↑↑↑↑↑↑ *********

#define selectDeviceButtonW  120

@interface LitePhoneSelectLabelViewController ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic , strong) NSMutableArray       * listDataArray;
@property (nonatomic , strong) NSMutableArray       * labelSelectArray; //选中标签数组

@property (nonatomic , strong) UIScrollView         * topScrollView;

@property (nonatomic , strong) UIScrollView         * middleScrollView;

@property (nonatomic , strong) UIView               * personNumView;
@property (nonatomic , strong) UILabel              * personTitleLabel;
@property (nonatomic , strong) UILabel              * labelSelectLabel;
@property (nonatomic , strong) UILabel              * personNumLabel;

@property (nonatomic , strong) UIButton             * resetButton;
@property (nonatomic , strong) UIButton             * confirmButton;

@property (nonatomic , strong) NSString             * maxId;//登陆用户在收集用户表中最大id
@property (nonatomic , strong) NSString             * labelIds; //用户选择的标签ID 格式: 12 或者 12,13,14

@end

@implementation LitePhoneSelectLabelViewController

#pragma mark - ******* Life Cycle *******

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择标签";
    
    [self requestMacLabel];
    
    // You should add subviews here
    
    // You should add notification here
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - ******* UI Methods *******

- (void)createUI{
    [self createTopScrollView];
    
    [self.view addSubview:self.personNumView];
    [self.personNumView addSubview:self.personTitleLabel];
    [self.personNumView addSubview:self.labelSelectLabel];
    [self.personNumView addSubview:self.personNumLabel];
    
    [self.view addSubview:self.resetButton];
    [self.view addSubview:self.confirmButton];

    [self layoutSubviews];
    
    [self createMiddleScrollView];
    
    [self.view bringSubviewToFront:self.personNumView];
    
    [self selectLabelsWithModel:self.messageModel];
}

- (void)layoutSubviews{
    
    [self.resetButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(0 - SafeAreaBottomHeight);
        make.height.equalTo(@50);
        make.width.mas_equalTo(kScreenWidth/2);
    }];
    
    [self.confirmButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(0 - SafeAreaBottomHeight);
        make.height.equalTo(@50);
        make.width.mas_equalTo(kScreenWidth/2);
    }];
    
    [self.personNumView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.confirmButton.mas_top).offset(-1);
        make.height.equalTo(@60);
    }];
    
    [self.personTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.personNumView).offset(12);
        make.height.equalTo(@17);
        make.top.equalTo(self.personNumView).offset(13);
        make.width.greaterThanOrEqualTo(@100);
    }];
    
    [self.labelSelectLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.personNumView).offset(12);
        make.height.equalTo(@17);
        make.top.equalTo(self.personTitleLabel.mas_bottom).offset(1);
        make.width.greaterThanOrEqualTo(@100);
    }];
    
    [self.personNumLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.personNumView).offset(-12);
        make.top.bottom.equalTo(self.personNumView);
        make.width.greaterThanOrEqualTo(@100);
    }];
}

- (void)createTopScrollView{
    
    if (self.listDataArray.count > 0) {
        
        [self.view addSubview:self.topScrollView];
        
        for (int i = 0; i < self.listDataArray.count ; i++) {
            LiteDeviceModel *model = self.listDataArray[i];
            selectDeviceButton *button = [[selectDeviceButton alloc] initWithFrame:CGRectMake(i * selectDeviceButtonW, 0, selectDeviceButtonW, 100)];
            button.nameLabel.text = model.deviceName;
            button.macLabel.text = model.mac;
            if ([model.status isEqualToString:@"1"]) { //正常
                button.selectedImage = [UIImage imageNamed:@"ads_device_selected"];
                button.unselectedImage = [UIImage imageNamed:@"ads_device_unselected"];
            }else{ //已解绑
                button.selectedImage = [UIImage imageNamed:@"ads_device_unbind_selected"];
                button.unselectedImage = [UIImage imageNamed:@"ads_device_unbind_unselected"];
            }
            button.tag = 100 + i;
            if (i == 0) {
                button.selected = YES;
            }
            
            /* ads_device_expire_selected */

            [button addTarget:self action:@selector(selectDeviceButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.topScrollView addSubview:button];
        }
        
        [self.topScrollView setContentSize:CGSizeMake(selectDeviceButtonW * self.listDataArray.count, self.topScrollView.frame.size.height)];
    }
}

- (void)createMiddleScrollView{
    
    if (self.listDataArray.count > 0) {
        
        [self.view addSubview:self.middleScrollView];
        
        [self.middleScrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(self.topScrollView.mas_bottom).offset(1);
            make.bottom.equalTo(self.personNumView.mas_top).offset(-0);
        }];
        
        [self.middleScrollView.superview layoutIfNeeded];
        
        CGFloat tableViewH = self.middleScrollView.frame.size.height;
        
        for (int i = 0; i < self.listDataArray.count ; i++) {

            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(i * kScreenWidth, 0, kScreenWidth, tableViewH)];
            tableView.tag = 1000 + i;
            tableView.backgroundColor = UIColorClearColor;
            tableView.delegate = self;
            tableView.dataSource = self;
            //        _tableView.bounces = NO;
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            
            if (@available(iOS 11.0, *)) {
                tableView.estimatedRowHeight = 0;
                tableView.estimatedSectionHeaderHeight = 0;
                tableView.estimatedSectionFooterHeight = 0;
                tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            }
            
            [tableView registerClass:[LiteADsSelectLabelCell class] forCellReuseIdentifier:NSStringFromClass(self.class)];
            
            [self.middleScrollView addSubview:tableView];
            
            BHLoadFailedView  * noDataView = [[BHLoadFailedView alloc] initWithFrame:CGRectMake(i * kScreenWidth, 0, kScreenWidth, tableViewH)];
            noDataView.backgroundColor = UIColorClearColor;
            noDataView.hidden = YES;
            noDataView.tag = 2000 + i;
            noDataView.loadFailedImageView.image = [UIImage imageNamed:@"no_data"];
            noDataView.loadFailedLabel.text = @"没有数据啊！喵~";
            
            [self.middleScrollView addSubview:noDataView];
        }
        
        [self.middleScrollView setContentSize:CGSizeMake(kScreenWidth * self.listDataArray.count, self.middleScrollView.frame.size.height)];
    }
    
}
#pragma mark - ******* Action Methods *******

- (void)selectDeviceButtonAction:(selectDeviceButton *)button{
    
    if (button.selected) {
        return;
    }else{
        for (selectDeviceButton * bu in self.topScrollView.subviews) {
            bu.selected = NO;
        }
        button.selected = YES;
    }
    
    /** Center active tab in topScrollview 活动的tab放到中间*/
    CGRect frame = button.frame;
    if (1) {
        frame.origin.x += (CGRectGetWidth(frame) / 2);
        frame.origin.x -= CGRectGetWidth(/*self.tabContentView.frame*/ self.view.frame) / 2;
        frame.size.width = CGRectGetWidth(/*self.tabContentView.frame*/ self.view.frame);
        
        if (frame.origin.x < 0) {
            frame.origin.x = 0;
        }
        if ((frame.origin.x + CGRectGetWidth(frame)) > self.topScrollView.contentSize.width) {
            frame.origin.x = (self.topScrollView.contentSize.width - CGRectGetWidth(/*self.tabContentView.frame*/ self.view.frame));
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.topScrollView scrollRectToVisible:frame animated:YES];
        /*scrollRectToVisible 无效的两个原因:
         1. contentSize的width或者height是0
         2. contentInset是负值，比如：
         self.tableView.contentInset = UIEdgeInsetsMake(-5, 0, 0, 0);
         删除这个contentInset或者inset是正值，滚动到顶部都可以生效
         */
    });
    
    NSInteger buttonIndex = button.tag - 100;
    [UIView animateWithDuration:0.2f animations:^{
        self.middleScrollView.contentOffset = CGPointMake(buttonIndex * kScreenWidth, 0);
    }];
}

- (void)resetButtonAction:(UIButton *)button{
    if (button.selected == NO) { //全选
        for (LiteDeviceModel *deviceModel in self.listDataArray) {
            for (LiteLabelModel * model in deviceModel.labelArray) {
                [self.labelSelectArray addObject:model];
            }
        }
        for (int i = 0; i < self.listDataArray.count ; i++) {
            //上部按钮角标
            selectDeviceButton *button = [self.topScrollView viewWithTag:i + 100];
            
            LiteDeviceModel *deviceModel = self.listDataArray[i];
            
            if (deviceModel.labelArray.count > 0) {
                if (deviceModel.labelArray.count >= 99) {
                    button.badgeLabel.text = @"99";
                }else{
                    button.badgeLabel.text = [NSString stringWithFormat:@"%ld",(long)deviceModel.labelArray.count];
                }
                button.badgeLabel.hidden = NO;
            }else{
                button.badgeLabel.hidden = YES;
            }
            
            UITableView *tableView = [self.middleScrollView viewWithTag:1000 + i];
            [tableView reloadData];
        }
    }else{ //重置
        [self.labelSelectArray removeAllObjects];
        [self checkAllViewStatus];
        for (int i = 0; i < self.listDataArray.count ; i++) {
            UITableView *tableView = [self.middleScrollView viewWithTag:1000 + i];
            [tableView reloadData];
        }
    }
    [self checkAllViewStatus];
}

- (void)confirmButtonAction:(UIButton *)button{
    
    if (self.selectLabelType == SelectLabelTypePhone) {
        LitePhoneSelectCustomViewController *vc = [[LitePhoneSelectCustomViewController alloc] init];
        vc.labelIds = self.labelIds;
        vc.maxId = self.maxId;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        if ([self.delegate respondsToSelector:@selector(messageSelectLabelResult:maxId:)]) {
            LiteADsMessageListModel *model = [[LiteADsMessageListModel alloc] init];
            model.labelId = self.labelIds;
            model.peopleNum = self.personNumLabel.text;
            model.labelNum = [NSString stringWithFormat:@"%ld",self.labelSelectArray.count];
            [self.delegate messageSelectLabelResult:model maxId:self.maxId];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - ******* Scroll Delegate *******

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView == self.middleScrollView) {
        CGFloat OffsetX = scrollView.contentOffset.x;
        NSInteger index = roundf(OffsetX / kScreenWidth);
        selectDeviceButton *button = [self.topScrollView viewWithTag:100 + index];
        [self selectDeviceButtonAction:button];
    }
}

#pragma mark - ******* UITableView Delegate *******

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    LiteDeviceModel *deviceModel = self.listDataArray[tableView.tag - 1000];
    
    BHLoadFailedView  * noDataView = (BHLoadFailedView *)[self.middleScrollView viewWithTag:tableView.tag + 1000];
    
    if (deviceModel.labelArray.count > 0) {
        noDataView.hidden = YES;
        return deviceModel.labelArray.count;
    }else{
        noDataView.hidden = NO;
        return 0;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LiteADsSelectLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(self.class) forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    LiteDeviceModel *deviceModel = self.listDataArray[tableView.tag - 1000];
    LiteLabelModel * model = deviceModel.labelArray[indexPath.row];
    
    [cell configWithData:model];
    
    if ([self.labelSelectArray containsObject:model]) {
        [cell cellBecomeSelected];
    }else{ //选择该标签
        [cell cellBecomeUnselected];
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 63.0f;
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
    LiteADsSelectLabelCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    LiteDeviceModel *deviceModel = self.listDataArray[tableView.tag - 1000];
    LiteLabelModel * model = deviceModel.labelArray[indexPath.row];
    
    //上部按钮角标
    selectDeviceButton *button = [self.topScrollView viewWithTag:tableView.tag - 1000 + 100];
    NSInteger buttonBadgeNum = [button.badgeLabel.text integerValue];
    
    if ([self.labelSelectArray containsObject:model]) { //删除选择
        [cell cellBecomeUnselected];
        [self.labelSelectArray removeObject:model];
        //记录选择数组删除该标签

        buttonBadgeNum -=1;
    }else{ //选择该标签
        [cell cellBecomeSelected];
        [self.labelSelectArray addObject:model];
        //记录选择数组添加该标签
        
        buttonBadgeNum +=1;
    }
    
    if (buttonBadgeNum <= 0) {
        button.badgeLabel.hidden = YES;
        button.badgeLabel.text = @"0";
    }else{
        if (buttonBadgeNum >= 99) {
            buttonBadgeNum = 99;
        }
        button.badgeLabel.hidden = NO;
        button.badgeLabel.text = [NSString stringWithFormat:@"%ld",buttonBadgeNum];
    }
    
    NSLog(@"点击了cell");
    [self checkAllViewStatus];
}

#pragma mark - ******* Private Methods *******

- (void)checkAllViewStatus{
    if (self.labelSelectArray.count > 0) {
        [self.confirmButton setBackgroundColor:UIColorBlue];
        self.confirmButton.userInteractionEnabled = YES;
        self.resetButton.selected = YES;
        self.labelSelectLabel.text = [NSString stringWithFormat:@"已选择%ld个标签",(long)self.labelSelectArray.count];
        [self requestLabelPerson];
    }else{
        [self.confirmButton setBackgroundColor:UIColorlightGray];
        self.confirmButton.userInteractionEnabled = NO;
        self.resetButton.selected = NO;
        self.labelSelectLabel.text = @"已选择0个标签";
        self.personNumLabel.text = @"0";
        for (int i = 0; i < self.listDataArray.count ; i++) {
            selectDeviceButton *button = [self.topScrollView viewWithTag:100 + i];
            button.badgeLabel.hidden = YES;
            button.badgeLabel.text = @"0";
        }
    }
}

//根据上个页面带来的model去自动选中相应的label
- (void)selectLabelsWithModel:(LiteADsMessageListModel *)model{
    
    if (!kStringNotNull(model.labelId)) {
        return;
    }
    NSArray *labelIdArr = [model.labelId componentsSeparatedByString:@","];
    
    for (int i = 0; i < self.listDataArray.count ; i++) {
        //上部按钮角标
        
        int badgeNum = 0;
        
        selectDeviceButton *button = [self.topScrollView viewWithTag:i + 100];
        
        LiteDeviceModel *deviceModel = self.listDataArray[i];
        
        for (LiteLabelModel * model in deviceModel.labelArray) {
            if ([labelIdArr containsObject:model.labelID]) {
                [self.labelSelectArray addObject:model];
                badgeNum +=1;
            }
        }
        
        if (badgeNum > 0) {
            if (badgeNum >= 99) {
                button.badgeLabel.text = @"99";
            }else{
                button.badgeLabel.text = [NSString stringWithFormat:@"%d",badgeNum];
            }
            button.badgeLabel.hidden = NO;
        }else{
            button.badgeLabel.hidden = YES;
        }
        
        UITableView *tableView = [self.middleScrollView viewWithTag:1000 + i];
        [tableView reloadData];
    }
    [self checkAllViewStatus];
}

#pragma mark - ******* Request *******

- (void)requestMacLabel{
    WEAKSELF
    [ShowHUDTool showLoading];
    
    [FSNetWorkManager requestWithType:HttpRequestTypeGet
                        withUrlString:kApiReportGetMacLabel
                        withParaments:nil
                     withSuccessBlock:^(NSDictionary *object) {

                         [ShowHUDTool hideAlert];
                         
                         if (NetResponseCheckStaus)
                         {  NSLog(@"请求所有标签列表成功");
                             NSDictionary *dic = object[@"data"];
                             NSArray *listArr = dic[@"list"];
                             self.maxId = [dic stringValueForKey:@"maxId" default:@""];
                             
                             if (listArr.count > 0) {
                                 for (int i = 0; i < listArr.count ; i ++) {
                                     NSDictionary *dic = listArr[i];
                                     LiteDeviceModel *deviceModel = [[LiteDeviceModel alloc] init];
                                     deviceModel.deviceId = [dic stringValueForKey:@"id" default:@""];
                                     deviceModel.deviceName = [dic stringValueForKey:@"deviceName" default:@""];
                                     deviceModel.mac = [dic stringValueForKey:@"mac" default:@""];
                                     deviceModel.netStatus = [dic stringValueForKey:@"netStatus" default:@""];
                                     deviceModel.status = [dic stringValueForKey:@"status" default:@""];

                                     NSArray *arr = dic[@"label"];
                                     if (arr.count > 0) { //设备下面有标签
                                         NSMutableArray *labelArr = [[NSMutableArray alloc] init];
                                         
                                         for (int j = 0; j < arr.count ; j ++) {
                                             NSDictionary *labelDic = arr[j];
                                             
                                             LiteLabelModel *labelModel = [[LiteLabelModel alloc] init];
                                             labelModel.labelID = [labelDic stringValueForKey:@"id" default:@""];
                                             labelModel.mac = [labelDic stringValueForKey:@"mac" default:@""];
                                             labelModel.name = [labelDic stringValueForKey:@"name" default:@""];
                                             
                                             labelModel.status = [labelDic stringValueForKey:@"status" default:@""];
                                             labelModel.personNum = [labelDic stringValueForKey:@"personNum" default:@""];
                                             
                                             [labelArr addObject:labelModel];
                                         }
                                         deviceModel.labelArray = [labelArr copy];
                                     }
                                     [weakSelf.listDataArray addObject:deviceModel];
                                 }
                                 [weakSelf createUI];
                             }
                         }else{
                             [ShowHUDTool showBriefAlert:NetResponseMessage];
                         }
                     } withFailureBlock:^(NSError *error) {
                         NSLog(@"error is:%@", error);
                         [ShowHUDTool hideAlert];
                         [ShowHUDTool showBriefAlert:NetRequestFailed];
                     }];

}
//根据选择标签请求人数
- (void)requestLabelPerson{
    WEAKSELF
    self.labelIds = @"";
    for (LiteLabelModel *model in self.labelSelectArray) {
        self.labelIds = [self.labelIds stringByAppendingFormat:@",%@",model.labelID];
    }
    self.labelIds = [self.labelIds substringWithRange:NSMakeRange(1,self.labelIds.length - 1)];
    
    NSDictionary * params = @{@"labelId":self.labelIds,
                              @"type":self.customType == AdsCustomTypeAll ? @"1":@"2",
                              @"maxId":self.maxId
                              };
    
    NSString *apiStr = @"";
    
    if (self.selectLabelType == SelectLabelTypePhone) {
        apiStr = kApiPhoneGetLabelPerson;
    }else{
        apiStr = kApiMessageGetLabelPerson;
    }
    
    [FSNetWorkManager requestWithType:HttpRequestTypeGet
                        withUrlString:apiStr
                        withParaments:params
                     withSuccessBlock:^(NSDictionary *object) {
                         
                         if (NetResponseCheckStaus)
                         {  NSLog(@"请求标签统计人数成功");
                             NSDictionary *dic = object[@"data"];
                             NSString *total = [dic stringValueForKey:@"total" default:@""];
                             
                             weakSelf.personNumLabel.text = total;
                         }else{
                             [ShowHUDTool showBriefAlert:NetResponseMessage];
                         }
                     } withFailureBlock:^(NSError *error) {
                         NSLog(@"error is:%@", error);
                         [ShowHUDTool showBriefAlert:NetRequestFailed];
                     }];
    
}

#pragma mark - ******* Getter *******

- (NSMutableArray *)listDataArray{
    if (!_listDataArray) {
        _listDataArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _listDataArray;
}

- (NSMutableArray *)labelSelectArray
{
    if (!_labelSelectArray)
    {
        _labelSelectArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _labelSelectArray;
}

- (UIScrollView *)topScrollView
{
    if (!_topScrollView)
    {
        // 创建UIScrollView
        _topScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 1, kScreenWidth, 100)];
        _topScrollView.backgroundColor = UIColorWhite;
        _topScrollView.bounces = NO;
        // 设置scrollView的属性
        _topScrollView.pagingEnabled = NO;
        // 设置UIScrollView的滚动范围（内容大小）
        _topScrollView.delegate = self;
        // 隐藏水平滚动条
        _topScrollView.showsHorizontalScrollIndicator = NO;
        _topScrollView.showsVerticalScrollIndicator = NO;
    }
    return _topScrollView;
}

- (UIScrollView *)middleScrollView
{
    if (!_middleScrollView)
    {
        // 创建UIScrollView
        _middleScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 100)];
        _middleScrollView.backgroundColor = UIColorClearColor;
        _middleScrollView.bounces = NO;
        // 设置scrollView的属性
        _middleScrollView.pagingEnabled = YES;
        // 设置UIScrollView的滚动范围（内容大小）
        _middleScrollView.delegate = self;
        // 隐藏水平滚动条
        _middleScrollView.showsHorizontalScrollIndicator = NO;
        _middleScrollView.showsVerticalScrollIndicator = NO;
    }
    return _middleScrollView;
}

- (UIView *)personNumView{
    if (!_personNumView) {
        _personNumView = [[UIView alloc] init];
        _personNumView.backgroundColor = UIColorWhite;
        _personNumView.layer.shadowColor = [UIColor lightGrayColor].CGColor;//shadowColor阴影颜色
        _personNumView.layer.shadowOffset = CGSizeMake(0,-2);//shadowOffset阴影偏移,x向右偏移，y向下偏移，默认(0, -3),这个跟shadowRadius配合使用
        _personNumView.layer.shadowOpacity = 0.3;//阴影透明度，默认0
        _personNumView.layer.shadowRadius = 2;//阴影半径，默认3
    }
    return _personNumView;
}

- (UILabel *)personTitleLabel{
    if (!_personTitleLabel) {
        _personTitleLabel = [[UILabel alloc] init];
        _personTitleLabel.text = @"预计覆盖人数";
        _personTitleLabel.textColor = UIColorDarkBlack;
        _personTitleLabel.font = [UIFont systemFontOfSize:12];
        _personTitleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _personTitleLabel;
}

- (UILabel *)labelSelectLabel{
    if (!_labelSelectLabel) {
        _labelSelectLabel = [[UILabel alloc] init];
        _labelSelectLabel.text = @"已选0个标签";
        _labelSelectLabel.textColor = UIColorlightGray;
        _labelSelectLabel.font = [UIFont systemFontOfSize:12];
        _labelSelectLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _labelSelectLabel;
}

- (UILabel *)personNumLabel{
    if (!_personNumLabel) {
        _personNumLabel = [[UILabel alloc] init];
        _personNumLabel.text = @"0";
        _personNumLabel.textColor = UIColorBlue;
        _personNumLabel.font = [UIFont systemFontOfSize:36];
        _personNumLabel.textAlignment = NSTextAlignmentRight;
    }
    return _personNumLabel;
}
- (UIButton *)resetButton{
    if (!_resetButton) {
        _resetButton = [[UIButton alloc] init];
        [_resetButton setTitle:@"选择全部" forState:UIControlStateNormal];
        [_resetButton setTitle:@"重置" forState:UIControlStateSelected];
        [_resetButton setTitleColor:UIColorDarkBlack forState:UIControlStateNormal];
        [_resetButton setTitleColor:UIColorDarkBlack forState:UIControlStateSelected];
        [_resetButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [_resetButton setBackgroundColor:UIColorWhite];
        [_resetButton addTarget:self action:@selector(resetButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _resetButton;
}

- (UIButton *)confirmButton{
    if (!_confirmButton) {
        _confirmButton = [[UIButton alloc] init];
        [_confirmButton setTitle:@"确认" forState:UIControlStateNormal];
        [_confirmButton setTitleColor:UIColorWhite forState:UIControlStateNormal];
        [_confirmButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [_confirmButton setBackgroundColor:UIColorlightGray];
        _confirmButton.userInteractionEnabled = NO;
        [_confirmButton addTarget:self action:@selector(confirmButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
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
