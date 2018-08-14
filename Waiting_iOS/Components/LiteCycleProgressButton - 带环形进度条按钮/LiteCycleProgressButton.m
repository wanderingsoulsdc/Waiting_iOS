//
//  LiteCycleProgressButton.m
//  Waiting_iOS
//
//  Created by wander on 2018/7/10.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteCycleProgressButton.h"

@interface LiteCycleProgressButton ()

@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, strong) CAShapeLayer *progressLayer;

@end

@implementation LiteCycleProgressButton

- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        
        CALayer *imageLayer = [CALayer layer];
        
        imageLayer.frame= self.bounds;
        
        imageLayer.cornerRadius = self.bounds.size.width/2;
        
        imageLayer.backgroundColor = UIColorError.CGColor;
        
        imageLayer.masksToBounds = YES;
        
        [self.layer addSublayer:imageLayer];
    }
    return self;
}

- (void)drawProgress:(CGFloat )progress
{
    _progress = progress;
    [_progressLayer removeFromSuperlayer];
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [self drawCycleProgress];
    
}

- (void)drawCycleProgress
{
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    CGFloat radius = self.bounds.size.width/2 + 4;
    CGFloat startA = - M_PI_2;  //设置进度条起点位置
    CGFloat endA = -M_PI_2 + M_PI * 2 * _progress;  //设置进度条终点位置
    
    
    //获取环形路径（画一个圆形，填充色透明，设置线框宽度为10，这样就获得了一个环形）
    _progressLayer = [CAShapeLayer layer];//创建一个track shape layer
    _progressLayer.frame = self.bounds;
    _progressLayer.fillColor = [[UIColor clearColor] CGColor];  //填充色为无色
    _progressLayer.strokeColor = [[UIColor colorWithRed:121.0/255.0 green:126.0/255.0 blue:129.0/255.0 alpha:0.8] CGColor]; //指定path的渲染颜色,这里可以设置任意不透明颜色
    _progressLayer.opacity = 1; //背景颜色的透明度
    _progressLayer.lineCap = kCALineCapRound;//指定线的边缘是圆的
    _progressLayer.lineWidth = 4;//线的宽度
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startA endAngle:endA clockwise:YES];//上面说明过了用来构建圆形
    _progressLayer.path =[path CGPath]; //把path传递給layer，然后layer会处理相应的渲染，整个逻辑和CoreGraph是一致的。
    [self.layer addSublayer:_progressLayer];
}

@end
