//
//  ChatListCell.m
//  Waiting_iOS
//
//  Created by wander on 2018/8/14.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "ChatListCell.h"
#import <Masonry/Masonry.h>
#import "NIMAvatarImageView.h"
#import "UIView+NIM.h"
#import "NIMKitUtil.h"
#import "NIMBadgeView.h"

@interface ChatListCell ()

@end

@implementation ChatListCell
#define AvatarWidth 40
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _avatarImageView = [[NIMAvatarImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        [self addSubview:_avatarImageView];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.backgroundColor = [UIColor whiteColor];
        _nameLabel.font            = [UIFont systemFontOfSize:18.f];
        [self addSubview:_nameLabel];
        
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _messageLabel.backgroundColor = [UIColor whiteColor];
        _messageLabel.font            = [UIFont systemFontOfSize:14.f];
        _messageLabel.textColor       = UIColorFromRGB(0x999999);
        [self addSubview:_messageLabel];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.backgroundColor = [UIColor whiteColor];
        _timeLabel.font            = [UIFont systemFontOfSize:12.f];
        _timeLabel.textColor       = UIColorFromRGB(0xC8C8C8);
        [self addSubview:_timeLabel];
        
        _badgeView = [NIMBadgeView viewWithBadgeTip:@""];
        [self addSubview:_badgeView];
    }
    return self;
}


#define NameLabelMaxWidth    160.f
#define MessageLabelMaxWidth 200.f
- (void)refresh:(NIMRecentSession*)recent{
    self.nameLabel.nim_width = self.nameLabel.nim_width > NameLabelMaxWidth ? NameLabelMaxWidth : self.nameLabel.nim_width;
    self.messageLabel.nim_width = self.messageLabel.nim_width > MessageLabelMaxWidth ? MessageLabelMaxWidth : self.messageLabel.nim_width;
    if (recent.unreadCount) {
        self.badgeView.hidden = NO;
        self.badgeView.badgeValue = @(recent.unreadCount).stringValue;
    }else{
        self.badgeView.hidden = YES;
    }
}


- (void)layoutSubviews{
    [super layoutSubviews];
    //Session List
    
    NSInteger sessionListAvatarLeft             = 15;
    NSInteger sessionListNameTop                = 15;
    NSInteger sessionListNameLeftToAvatar       = 15;
    NSInteger sessionListMessageLeftToAvatar    = 15;
    NSInteger sessionListMessageBottom          = 15;
    NSInteger sessionListTimeRight              = 15;
    NSInteger sessionListTimeTop                = 15;
//    NSInteger sessionBadgeTimeBottom            = 15;
//    NSInteger sessionBadgeTimeRight             = 15;
    
    _avatarImageView.nim_left    = sessionListAvatarLeft;
    _avatarImageView.nim_centerY = self.nim_height * .5f;
    _badgeView.nim_right         = _avatarImageView.nim_right;
    _badgeView.nim_top           = _avatarImageView.nim_top;
    _nameLabel.nim_top           = sessionListNameTop;
    _nameLabel.nim_left          = _avatarImageView.nim_right + sessionListNameLeftToAvatar;
    _messageLabel.nim_left       = _avatarImageView.nim_right + sessionListMessageLeftToAvatar;
    _messageLabel.nim_bottom     = self.nim_height - sessionListMessageBottom;
    _timeLabel.nim_right         = self.nim_width - sessionListTimeRight;
    _timeLabel.nim_top           = sessionListTimeTop;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
