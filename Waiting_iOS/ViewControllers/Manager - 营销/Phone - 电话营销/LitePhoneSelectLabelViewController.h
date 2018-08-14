//
//  LitePhoneSelectLabelViewController.h
//  
//
//  Created by wander on 2018/7/18.
//

#import "LiteBaseViewController.h"
#import "LiteADsMessageListModel.h"

@protocol SelectLabelDelegate <NSObject>

@optional
- (void)messageSelectLabelResult:(LiteADsMessageListModel *)model maxId:(NSString *)maxId;

@end


@interface LitePhoneSelectLabelViewController : LiteBaseViewController

@property (nonatomic , assign) SelectLabelType selectLabelType;

@property (nonatomic , assign) AdsCustomType customType;

@property (nonatomic , strong) LiteADsMessageListModel * messageModel;

@property (nonatomic , assign) id <SelectLabelDelegate> delegate;

@end
