//
//  MyAnnotationView.m
//  Waiting_iOS
//
//  Created by wander on 2018/7/26.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "MyAnnotationView.h"

@implementation MyAnnotationView

@synthesize titleLabel = _titleLabel;
@synthesize subTitleLabel   = _subTitleLabel;
@synthesize tipView   = _tipView;

- (id)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        CGFloat selfWidth = [UIScreen mainScreen].bounds.size.width * (2.0/5.0);
        [self setBounds:CGRectMake(0.f, 0.f, selfWidth, 50.f)];
        
        _tipView = [[UIView alloc] initWithFrame:CGRectMake(-(selfWidth/2) + 12, -50.f,selfWidth, 50.f)];
        _tipView.backgroundColor = [UIColor clearColor];
        _tipView.hidden = YES;
        [self addSubview:_tipView];
        
        UIImageView *tipImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _tipView.frame.size.width, _tipView.frame.size.height)];
        tipImageView.backgroundColor = [UIColor clearColor];
        tipImageView.contentMode = UIViewContentModeScaleToFill;
        tipImageView.image = [UIImage imageNamed:@"main_map_annotation_paopao"];
        [_tipView addSubview:tipImageView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10 , 2 , _tipView.frame.size.width - 20, _tipView.frame.size.height - 16)];
        _titleLabel.text = annotation.title;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:13];
        _titleLabel.backgroundColor = [UIColor clearColor];
        [_tipView addSubview:_titleLabel];
        
        //        _subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 25.f, 100.f, 20.f)];
        //        _subTitleLabel.text = annotation.subtitle;
        //        _subTitleLabel.textAlignment = NSTextAlignmentCenter;
        //        _subTitleLabel.font = [UIFont systemFontOfSize:13];
        //        _subTitleLabel.backgroundColor = [UIColor clearColor];
        //        [tipView addSubview:_subTitleLabel];
        
        self.canShowCallout = NO;//禁止原生气泡显示
    }
    return self;
}

@end
