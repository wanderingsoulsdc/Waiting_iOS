//
//  BHRegisterVerifyCodeViewController.h
//  Waiting_iOS
//
//  Created by ChenQiuLiang on 2017/6/9.
//  Copyright © 2017年 BEHE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BHRegisterVerifyCodeViewController : UIViewController

@property (nonatomic, strong, nonnull) NSString * mobileString;
@property (nonatomic, assign) BHResetPassWordType type;
@property (nonatomic, strong) NSString * token;
@end
