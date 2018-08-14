//
//  BHRegisterSetPWViewController.h
//  Waiting_iOS
//
//  Created by ChenQiuLiang on 2017/6/10.
//  Copyright © 2017年 BEHE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BHRegisterSetPWViewController : UIViewController

@property (nonatomic, assign) BHResetPassWordType type;
@property (nonatomic, strong, nonnull) NSString * mobileString;
@property (nonatomic, strong, nonnull) NSString * verifyCodeString;

@property (nonatomic, strong) NSString *token;

@end
