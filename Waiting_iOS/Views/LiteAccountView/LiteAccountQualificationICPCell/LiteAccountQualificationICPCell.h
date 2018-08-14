//
//  LiteAccountQualificationICPCell.h
//  Waiting_iOS
//
//  Created by wander on 2018/6/19.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LiteAccountQualificationICPCellDelegate <NSObject>

- (void)clickImageView;

@end

@interface LiteAccountQualificationICPCell : UITableViewCell

@property (nonatomic, weak) id <LiteAccountQualificationICPCellDelegate> delegate;
@property (nonatomic, assign) ICPCellType   type;

- (void)configWithData:(NSDictionary *)dic;

@end
