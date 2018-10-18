//
//  LiteBaseViewController.h
//  Waiting_iOS
//
//  Created by wander on 2018/6/13.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LiteBaseViewController : UIViewController

//push控制器(类似Presen从下往上)
- (void)pushViewControllerAsPresent:(UIViewController *)viewController;
//pop控制器(类似dismiss从上往下)
- (void)popViewControllerAsDismiss;

@end
