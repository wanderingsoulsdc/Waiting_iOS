//
//  LiteADsMessageHistoryCell.h
//  Waiting_iOS
//
//  Created by wander on 2018/7/31.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiteADsMessageListModel.h"

@interface LiteADsMessageHistoryCell : UITableViewCell

- (void)configWithData:(LiteADsMessageListModel *)model;

- (void)cellBecomeSelected;

- (void)cellBecomeUnselected;


@end
