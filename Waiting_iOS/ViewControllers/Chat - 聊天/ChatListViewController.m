//
//  ChatListViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/9/24.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "ChatListViewController.h"
#import "ChatViewController.h"

@interface ChatListViewController ()

@property (weak, nonatomic) IBOutlet UILabel * noSessionLabel;//没有会话

@end

@implementation ChatListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.noSessionLabel.text = ZBLocalized(@"No session", nil);
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - Override
- (void)onSelectedAvatar:(NSString *)userId
             atIndexPath:(NSIndexPath *)indexPath{};

- (void)onSelectedRecent:(NIMRecentSession *)recentSession atIndexPath:(NSIndexPath *)indexPath{
    ChatViewController *vc = [[ChatViewController alloc] initWithSession:recentSession.session];
    [self.navigationController pushViewController:vc animated:YES];
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
