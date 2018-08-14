//
//  LiteAccountInvoiceView.h
//  Waiting_iOS
//
//  Created by wander on 2018/6/25.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>
#import "XZPickView.h"
#import "LiteAccountInvoiceModel.h"
#import "UITextView+Placeholder.h"

typedef NS_ENUM(NSUInteger, invoiceViewType) {
    typeTextField,
    typeTextView,
    typeLabel,
    typeButton,
    typeStatus,
    typeOther,
};

@protocol LiteAccountInvoiceViewDelegate <NSObject>

- (void)invoiceTypeSelectResult:(NSString *)type;

@end

@interface LiteAccountInvoiceView : UIView<UITextFieldDelegate,XZPickViewDelegate, XZPickViewDataSource>

@property (nonatomic, strong) UIButton      * invoiceTypeButton; //发票类型按钮

@property (nonatomic, strong) XZPickView    * pickView;         //发票类型选择器

@property (nonatomic, strong) UIImageView   * rightImageView;

@property (nonatomic, strong) UILabel       * leftTitleLabel;

@property (nonatomic, strong) UILabel       * leftDetailTitleLabel;   //不可开票金额label
@property (nonatomic, strong) UIButton      * rightDetailReasonButton;//不可开票查看原因按钮
@property (nonatomic, strong) NSString      * replaceMoney;           //不可开票金额

@property (nonatomic, strong) UILabel       * rightTitleLabel;
@property (nonatomic, strong) UILabel       * markLabel;
@property (nonatomic, strong) UITextField   * textField;
@property (nonatomic, strong) UIView        * lineView;
@property (nonatomic, strong) UITextView    * textView;

@property (nonatomic , assign ) id <LiteAccountInvoiceViewDelegate> delegate;


- (instancetype)initWithFrame:(CGRect)frame withType:(invoiceViewType)type;

@end
