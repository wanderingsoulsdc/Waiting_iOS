//
//  MyInterestCell.h
//  Waiting_iOS
//
//  Created by wander on 2018/10/6.
//  Copyright © 2018 BEHE. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyInterestCell : UITableViewCell

- (void)configWithData:(NSDictionary *)dic;

- (void)cellBecomeSelected;

- (void)cellBecomeUnselected;

@end

NS_ASSUME_NONNULL_END
