//
//  LiteAccountAboutViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/6/15.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteAccountAboutViewController.h"
#import "LiteAccountSetupCell.h"
#import <Masonry/Masonry.h>
#import "FSDeviceManager.h"
#import "LiteAccountVersionInfoViewController.h"

@interface LiteAccountAboutViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView       * tableView;
@property (nonatomic, strong) NSMutableArray    * listDataArray;    //列表数据
@property (nonatomic, strong) UIView            * headerView;       //tableview头视图
@property (nonatomic, strong) UIImageView       * headImageView;    //图标
@property (nonatomic, strong) UILabel           * headTitleLabel;
@end

@implementation LiteAccountAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"关于";
    
    NSArray *listArr = @[@{@"title":@"版本信息",@"location":@"0"},
                         @{@"title":@"去评分",@"location":@"0"}];
    self.listDataArray = [listArr copy];
    
    [self initWithTableHeaderView];
    
    [self.view addSubview:self.tableView];
    // Do any additional setup after loading the view.
}

- (void)layoutSubviews {
    //You should set subviews constrainsts or frame here
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - Action

#pragma mark - SystemDelegate

#pragma mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LiteAccountSetupCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(self.class) forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary * dict = self.listDataArray[indexPath.row];
    [cell configWithData:dict];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
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
    if (indexPath.row == 0) {   //版本信息
        LiteAccountVersionInfoViewController * vc = [[LiteAccountVersionInfoViewController alloc] init];
        vc.url = kApiWebVersionInfo;
        [self.navigationController pushViewController:vc animated:YES];
    } else {    //去评分
        [ShowHUDTool showBriefAlert:@"去评分"];
    }
}


#pragma mark - Private methods

//头视图（头像&充值）
- (void)initWithTableHeaderView
{
    self.headerView = [[UIView alloc] init];
    self.headerView.backgroundColor = [UIColor clearColor];
    self.headerView.frame = CGRectMake(0, 0, kScreenWidth,220);
    
    self.headImageView = [[UIImageView alloc] init];
    [self.headImageView setImage:[UIImage imageNamed:@"account_icon"]];
    [self.headerView addSubview:self.headImageView];
    
    self.headTitleLabel = [[UILabel alloc] init];
    self.headTitleLabel.text = [NSString stringWithFormat:@"%@ %@",[FSDeviceManager sharedInstance].getAppName,[FSDeviceManager sharedInstance].getAppVersion];
    self.headTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.headTitleLabel.textColor = UIColorDarkBlack;
    self.headTitleLabel.font = [UIFont systemFontOfSize:14];
    [self.headerView addSubview:self.headTitleLabel];
    
    [self layoutHeaderViews];
    self.tableView.tableHeaderView = self.headerView;
}

//头视图布局
- (void)layoutHeaderViews{
    
    [self.headImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.headerView);
        make.centerY.equalTo(self.headerView).offset(-10);
        make.width.height.equalTo(@80);
    }];
    
    [self.headTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.headImageView.mas_centerX);
        make.top.equalTo(self.headImageView.mas_bottom);
        make.height.equalTo(@35);
        make.width.greaterThanOrEqualTo(@100);
    }];
}


#pragma mark - Getters and Setters
// initialize views here, etc

- (UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.height = IS_IPhoneX ? kScreenHeight-88-34 : kScreenHeight-64;
        _tableView.backgroundColor = UIColorFromRGB(0xF4F4F4);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.bounces = NO;
        
        // 分割线位置
        _tableView.separatorInset = UIEdgeInsetsMake(0,10, 0, 10);
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorColor = UIColorLine;  // 分割线颜色
        
        if (@available(iOS 11.0, *)) {
            _tableView.estimatedRowHeight = 0;
            _tableView.estimatedSectionHeaderHeight = 0;
            _tableView.estimatedSectionFooterHeight = 0;
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        [_tableView registerClass:[LiteAccountSetupCell class] forCellReuseIdentifier:NSStringFromClass(self.class)];
    }
    return _tableView;
}

- (NSMutableArray *)listDataArray
{
    if (!_listDataArray)
    {
        _listDataArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _listDataArray;
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
