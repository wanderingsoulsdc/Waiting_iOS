//
//  MyInterestCell.m
//  Waiting_iOS
//
//  Created by wander on 2018/10/6.
//  Copyright © 2018 BEHE. All rights reserved.
//

#import "MyInterestCell.h"

@interface MyInterestCell ()
@property (weak, nonatomic) IBOutlet UILabel    * nameLabel;
@property (weak, nonatomic) IBOutlet UIButton   * selectButton;

@end

@implementation MyInterestCell
{
    NSDictionary * _dic;
}

#pragma mark - Config Cell's Data

- (void)configWithData:(NSDictionary *)dic
{
    _dic = dic;
    
    // config subViews with dict
    self.nameLabel.text = [dic objectForKey:@"value"];
    
}

#pragma mark - Privite Method

- (void)cellBecomeSelected{
    self.selectButton.selected = YES;
}

- (void)cellBecomeUnselected{
    self.selectButton.selected = NO;
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
