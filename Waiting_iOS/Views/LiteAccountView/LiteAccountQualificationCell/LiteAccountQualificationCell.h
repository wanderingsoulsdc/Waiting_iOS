//
//  LiteAccountQualificationCell.h
//  Waiting_iOS
//
//  Created by wander on 2018/6/19.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LiteAccountQualificationCellDelegate <NSObject>

- (void)LevelTradesSelectResult:(NSDictionary *)dic;

- (void)businessNameResult:(NSString *)string;

@end

@interface LiteAccountQualificationCell : UITableViewCell

- (void)configWithData:(NSDictionary *)dic levelTradesData:(NSArray *)levelTradesArr;

@property (nonatomic , assign ) id <LiteAccountQualificationCellDelegate> delegate;
@property (nonatomic , strong) NSString         * businessLicenceImg; //营业执照图片链接

@end
