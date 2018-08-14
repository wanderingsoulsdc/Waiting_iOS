//
//  BHMarketingPhoneUserInfoViewController.h
//  Treasure
//
//  Created by ChenQiuLiang on 2018/1/8.
//Copyright © 2018年 BEHE. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BHMarketingPhoneUserInfoViewControllerDelegate <NSObject>

- (void)finishedEditUserInfo;

@end

@interface BHPhoneUserInfoViewController : UIViewController

@property (nonatomic, weak) id<BHMarketingPhoneUserInfoViewControllerDelegate> delegate;

@end
