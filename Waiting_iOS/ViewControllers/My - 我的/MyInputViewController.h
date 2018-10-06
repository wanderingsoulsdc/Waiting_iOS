//
//  MyInputViewController.h
//  Waiting_iOS
//
//  Created by wander on 2018/9/16.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteBaseViewController.h"

@protocol MyInputViewControllerDelegate <NSObject>

@optional
- (void)inputResultString:(NSString *)string inputType:(MyInputType)type;
//性别选择结果
- (void)inputGenderSelectResult:(NSDictionary *)dic;
//爱好选择结果
- (void)inputHobbySelectResult:(NSDictionary *)dic;

@end


@interface MyInputViewController : LiteBaseViewController


@property (nonatomic , strong) NSString * titleStr;
@property (nonatomic , assign) MyInputType inputType;

@property (nonatomic , assign) id <MyInputViewControllerDelegate> delegate;


@end
