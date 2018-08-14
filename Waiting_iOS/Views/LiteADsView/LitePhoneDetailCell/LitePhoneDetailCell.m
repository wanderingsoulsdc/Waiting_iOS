//
//  LitePhoneDetailCell.m
//  Waiting_iOS
//
//  Created by wander on 2018/7/24.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LitePhoneDetailCell.h"
@interface LitePhoneDetailCell ()
@property (weak, nonatomic) IBOutlet UIView *leftColorView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *markLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *callTotalTimeLabel;

@end

@implementation LitePhoneDetailCell
{
    LiteADsPhoneListModel * _model;
}

#pragma mark - Config Cell's Data

- (void)configWithData:(LiteADsPhoneListModel *)model
{
    _model = model;
    
    self.lastTimeLabel.text = model.startTime;
    self.callTotalTimeLabel.text = [NSString stringWithFormat:@"通话%@分钟",model.talkTime];
    if (kStringNotNull(model.markInfo)) {
        self.markLabel.text = model.markInfo;
    }else{
        self.markLabel.text = @"无备注";
    }
    
    //1有意向，2黑名单，3未接通， 4空号 ，5无标记, 6无意向
    int markStatus = [model.mark intValue];
    
    switch (markStatus) {
        case 0:
            break;
        case 1: //有意向
            self.leftColorView.backgroundColor = UIColorFromRGB(0x5ED7BC);
            self.statusLabel.text = @"有意向";
            break;
        case 2:
            break;
        case 3: //未接通
            self.leftColorView.backgroundColor = UIColorFromRGB(0x4895F2);
            self.statusLabel.text = @"未接通";
            break;
        case 4: //空号
            self.leftColorView.backgroundColor = UIColorError;
            self.statusLabel.text = @"空号";
            break;
        case 5: //无标记
            self.leftColorView.backgroundColor = UIColorlightGray;
            self.statusLabel.text = @"无标记";
            break;
        case 6: //无意向
            self.leftColorView.backgroundColor = UIColorAlert;
            self.statusLabel.text = @"无意向";
            break;
        default:
            break;
    }
    
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
