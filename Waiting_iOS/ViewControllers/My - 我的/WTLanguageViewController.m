//
//  WTLanguageViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/10/22.
//  Copyright © 2018 BEHE. All rights reserved.
//

#import "WTLanguageViewController.h"
#import "ZBLocalized.h"
#import "FSLaunchManager.h"

@interface WTLanguageViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint * statusViewHeightConstraint; //状态栏高度约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * tableViewBottomConstraint; //tableview距下约束
@property (weak, nonatomic) IBOutlet UILabel        * titleLabel;
@property (weak, nonatomic) IBOutlet UITableView    * tableView;
@end

@implementation WTLanguageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - ******* UI *******
- (void)createUI{
    self.statusViewHeightConstraint.constant = kStatusBarHeight;
    self.tableViewBottomConstraint.constant = SafeAreaBottomHeight;
    
    self.titleLabel.text = ZBLocalized(@"Language", nil);
    
}
#pragma mark - ******* Action *******
- (IBAction)backAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ******* TableView Delegate *******

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIde=@"cellIde";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIde];
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIde];
    }
    if (indexPath.row==0) {
        cell.textLabel.text=@"English";
    }
    
    if (indexPath.row==1) {
        cell.textLabel.text=@"العربية";
    }
    if (indexPath.row==2) {
        cell.textLabel.text=@"Türk dili";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row==0) {
        
        [[ZBLocalized sharedInstance] setLanguage:@"en"];
    }
    if (indexPath.row==1) {
        
        [[ZBLocalized sharedInstance] setLanguage:@"ar"];
        
    }
    if (indexPath.row==2) {
        
        [[ZBLocalized sharedInstance] setLanguage:@"tr"];
        
    }
    
    [self initRootVC];
    
    NSString *language = [[ZBLocalized sharedInstance] currentLanguage];
    NSLog(@"切换后的语言:%@",language);
}

- (void)initRootVC{
   
    [self dismissViewControllerAnimated:YES completion:^{
        [[FSLaunchManager sharedInstance] launchWindowWithType:LaunchWindowTypeMain];
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
