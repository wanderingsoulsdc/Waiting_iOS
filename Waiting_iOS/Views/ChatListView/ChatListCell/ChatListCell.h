//
//  ChatListCell.h
//  Waiting_iOS
//
//  Created by wander on 2018/8/14.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "NIMSessionListCell.h"
@class NIMAvatarImageView;
@class NIMRecentSession;
@class NIMBadgeView;

@interface ChatListCell : UITableViewCell

@property (nonatomic,strong) NIMAvatarImageView *avatarImageView;

@property (nonatomic,strong) UILabel *nameLabel;

@property (nonatomic,strong) UILabel *messageLabel;

@property (nonatomic,strong) UILabel *timeLabel;

@property (nonatomic,strong) NIMBadgeView *badgeView;

- (void)refresh:(NIMRecentSession*)recent;
@end
