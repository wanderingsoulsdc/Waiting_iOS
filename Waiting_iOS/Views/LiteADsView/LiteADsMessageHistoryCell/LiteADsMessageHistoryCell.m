//
//  LiteADsMessageHistoryCell.m
//  Waiting_iOS
//
//  Created by wander on 2018/7/31.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteADsMessageHistoryCell.h"

@interface LiteADsMessageHistoryCell ()
@property (weak, nonatomic) IBOutlet UILabel *messageNameLabel;
@property (weak, nonatomic) IBOutlet UIView *textViewBackView;
@property (weak, nonatomic) IBOutlet UIImageView *selectImageView;
@property (weak, nonatomic) IBOutlet UILabel *messageContentLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageContentNumLabel;


@end

@implementation LiteADsMessageHistoryCell
{
    LiteADsMessageListModel * _model;
}

#pragma mark - Config Cell's Data

- (void)configWithData:(LiteADsMessageListModel *)model
{
    _model = model;
    NSString *content = [NSString stringWithFormat:@"【%@】%@回T退订",model.sign,model.content];
    self.messageNameLabel.text = model.orderName;
    
    self.messageContentLabel.text = content;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 10.0) {
        [self.messageContentLabel.superview layoutIfNeeded];
    }
    
    self.messageContentNumLabel.text = [NSString stringWithFormat:@"%@条/%ld个字",model.smsNum,content.length];
}

#pragma mark - Privite Method

- (void)cellBecomeSelected{
    self.selectImageView.hidden = NO;
    self.messageContentLabel.textColor = UIColorBlue;
    self.messageContentNumLabel.textColor = UIColorBlue;
    self.textViewBackView.backgroundColor = UIColorFromRGB(0xDDEAF9);
}

- (void)cellBecomeUnselected{
    self.selectImageView.hidden = YES;
    self.messageContentLabel.textColor = UIColorDrakBlackText;
    self.messageContentNumLabel.textColor = UIColorFromRGB(0xFFA680);
    self.textViewBackView.backgroundColor = UIColorFromRGB(0xFFFCE7);
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
