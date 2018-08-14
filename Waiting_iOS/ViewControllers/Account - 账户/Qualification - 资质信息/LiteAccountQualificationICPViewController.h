//
//  LiteAccountQualificationICPViewController.h
//  Waiting_iOS
//
//  Created by wander on 2018/6/19.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteBaseViewController.h"

@protocol LiteAccountQualificationICPViewControllerDelegate <NSObject>

- (void)changeQualificationFinish:(NSString *)url Type:(ICPCellType)type;

@end

@interface LiteAccountQualificationICPViewController : LiteBaseViewController

@property (nonatomic, weak) id<LiteAccountQualificationICPViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString           * qualificationICPUrl;

@property (nonatomic, assign) ICPCellType   type;

@end
