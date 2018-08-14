//
//  LiteAccountLabelWasteCell.h
//  Waiting_iOS
//
//  Created by wander on 2018/6/24.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiteLabelModel.h"

@interface LiteAccountLabelWasteCell : UITableViewCell

- (void)configWithData:(LiteLabelModel *)model;

- (void)cellBecomeSelected;

- (void)cellBecomeUnselected;

@end
