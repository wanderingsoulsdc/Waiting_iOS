//
//  ChatListViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/9/24.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "ChatListViewController.h"
#import "ChatViewController.h"
#import "ChatListCell.h"
#import "NIMAvatarImageView.h"

@interface ChatListViewController ()

@property (weak, nonatomic) IBOutlet UILabel * noSessionLabel;//没有会话

@end

@implementation ChatListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.noSessionLabel.text = ZBLocalized(@"No session", nil);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    // Do any additional setup after loading the view from its nib.
}
#pragma mark - ******* Private *******
- (void)refresh{
    [super refresh];
    self.noSessionLabel.hidden = self.recentSessions.count;
}

- (void)onTouchAvatar:(id)sender{
    UIView *view = [sender superview];
    while (![view isKindOfClass:[UITableViewCell class]]) {
        view = view.superview;
    }
    UITableViewCell *cell  = (UITableViewCell *)view;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NIMRecentSession *recent = self.recentSessions[indexPath.row];
    [self onSelectedAvatar:recent atIndexPath:indexPath];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * cellId = @"ChatListCell";
    ChatListCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[ChatListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        [cell.avatarImageView addTarget:self action:@selector(onTouchAvatar:) forControlEvents:UIControlEventTouchUpInside];
    }
    NIMRecentSession *recent = self.recentSessions[indexPath.row];
    cell.nameLabel.text = [self nameForRecentSession:recent];
    [cell.avatarImageView setAvatarBySession:recent.session];
    [cell.nameLabel sizeToFit];
    cell.messageLabel.attributedText  = [self contentForRecentSession:recent];
    [cell.messageLabel sizeToFit];
    cell.timeLabel.text = [self timestampDescriptionForRecentSession:recent];
    [cell.timeLabel sizeToFit];
    
    [cell refresh:recent];
    return cell;
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
