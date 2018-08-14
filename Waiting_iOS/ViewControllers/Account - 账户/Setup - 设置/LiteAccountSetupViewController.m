//
//  LiteAccountSetupViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/6/15.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteAccountSetupViewController.h"
#import "LiteAccountSetupCell.h"
#import "LiteAccountAboutViewController.h"
#import "LiteAccountChangePasswordViewController.h"
#import "BHUserModel.h"
#import "FSNetWorkManager.h"

@interface LiteAccountSetupViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView       * tableView;
@property (nonatomic, strong) NSMutableArray    * listDataArray;    //列表数据

@end

@implementation LiteAccountSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设置";
    
    NSArray *listArr = @[@[@{@"title":@"手机号码",@"location":@"0"},
                           @{@"title":@"修改密码",@"location":@"0"}],
                         @[@{@"title":@"关于",@"location":@"0"}],
                         @[@{@"title":@"退出登录",@"location":@"1"}]];
    self.listDataArray = [listArr copy];
    
    [self.view addSubview:self.tableView];
    // Do any additional setup after loading the view.
}

- (void)layoutSubviews {
    //You should set subviews constrainsts or frame here
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
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
    return self.listDataArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sectionArr = [self.listDataArray objectAtIndex:section];
    return sectionArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LiteAccountSetupCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(self.class) forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary * dict = self.listDataArray[indexPath.section][indexPath.row];
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
    switch (section) {
        case 0:
            return 10.0f;
            break;
        case 1:
            return 8.0f;
            break;
        default:
            return 25.0f;
            break;
    }
    return 15.0f;
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
    if (indexPath.section == 0) {
        if (indexPath.row == 1) {   //修改密码
            LiteAccountChangePasswordViewController *pwd = [[LiteAccountChangePasswordViewController alloc] init];
            [self.navigationController pushViewController:pwd animated:YES];
        }
    } else if (indexPath.section == 1) {  //关于
        LiteAccountAboutViewController *aboutVC = [[LiteAccountAboutViewController alloc] init];
        [self.navigationController pushViewController:aboutVC animated:YES];
    } else{
        // 退出登录
//        [JPUSHService deleteAlias:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
//            //
//        } seq:0];
        [self logout];
    }
}

- (void)logout{
    [ShowHUDTool showLoading];
    [FSNetWorkManager requestWithType:HttpRequestTypeGet
                        withUrlString:kApiLogout
                        withParaments:nil withSuccessBlock:^(NSDictionary *object) {
                            NSLog(@"请求成功");
                            
                            [ShowHUDTool hideAlert];
                            
                            if (NetResponseCheckStaus)
                            {
                                [FSNetWorkManager clearCookies];
                                [BHUserModel cleanupCache];
                                
                                [[FSLaunchManager sharedInstance] launchWindowWithType:LaunchWindowTypeLogin];
                            }
                            else
                            {
                                [ShowHUDTool showBriefAlert:NetResponseMessage];
                            }
                        } withFailureBlock:^(NSError *error) {

                            [ShowHUDTool hideAlert];
                            [FSNetWorkManager clearCookies];
                            [BHUserModel cleanupCache];
                            [[FSLaunchManager sharedInstance] launchWindowWithType:LaunchWindowTypeLogin];
                        }];
}

#pragma mark - Private methods

- (void)setNavigationBackgroundColor:(UIColor *)backgroundColor titleColor:(UIColor *)titleColor backItemColor:(UIColor *)backItemColor statusBarIsLight:(BOOL)isLight{
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    navigationBar.barTintColor = backgroundColor;
    navigationBar.tintColor = backItemColor;
    [navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                            titleColor, NSForegroundColorAttributeName, [UIFont systemFontOfSize:17], NSFontAttributeName, nil]];
    
    // 隐藏黑线
    UIColor * baseColor = backgroundColor; // navigation的背景色
    CGRect rect = CGRectMake(0.0f, 0.0f, 10.0f, 49.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [baseColor CGColor]);
    CGContextFillRect(context, rect);
    UIImage *bgImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.navigationController.navigationBar setBackgroundImage:bgImage forBarMetrics:UIBarMetricsDefault];
    
    if (isLight) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }else{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
    
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
