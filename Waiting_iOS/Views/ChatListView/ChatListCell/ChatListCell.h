//
//  ChatListCell.h
//  Waiting_iOS
//
//  Created by wander on 2018/8/14.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatListModel.h"

@interface ChatListCell : UITableViewCell

- (void)configWithData:(ChatListModel *)model;

@end
