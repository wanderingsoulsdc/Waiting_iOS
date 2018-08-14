//
//  KSScanQRCodeView.m
//  KSPay
//
//  Created by ksjr-zg on 15/12/10.
//  Copyright © 2015年 快刷金融. All rights reserved.
//
#import "KSScanQRCodeView.h"
#import <AVFoundation/AVFoundation.h>

@interface KSScanQRCodeView()
@property (nonatomic, strong) UIImageView  *remindImageView;
@property (nonatomic, strong) UILabel      *remindLabel;
@property (nonatomic, strong) UIImageView  *qrLineImageView;
@property (nonatomic, strong) UIImageView  *lightImageView;
@property (nonatomic, strong) UIButton     *lightButton;
@property (nonatomic, strong) UILabel      *lightLabel;

@property (nonatomic,strong) AVCaptureSession * captureSession;
@property (nonatomic,strong) AVCaptureDevice * captureDevice;
@property (nonatomic, assign) BOOL isOpen;

@end

@implementation KSScanQRCodeView{
    CGFloat qrLineY;
}

- (void)show{
    CGRect oriFrame = self.qrLineImageView.frame;
    [UIView animateWithDuration:3.f animations:^{
        self.qrLineImageView.frame = CGRectMake(oriFrame.origin.x, self.topMargin + 5, oriFrame.size.width, oriFrame.size.height);
    } completion:^(BOOL finished) {
        self.qrLineImageView.frame = oriFrame;
        [self show];
    }];
}

- (void)drawRect:(CGRect)rect {
    //整个二维码扫描界面的颜色
    CGSize screenSize =[UIScreen mainScreen].bounds.size;
    CGRect screenDrawRect =CGRectMake(0, 0, screenSize.width,screenSize.height);
    //中间清空的矩形框
    CGRect clearDrawRect = CGRectMake((screenDrawRect.size.width-self.transparentArea.width)/2, self.topMargin, self.transparentArea.width, self.transparentArea.height);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self addScreenFillRect:ctx rect:screenDrawRect];
    [self addCenterClearRect:ctx rect:clearDrawRect];
    [self addWhiteRect:ctx rect:clearDrawRect];
    [self addCornerLineWithContext:ctx rect:clearDrawRect];
    
    [self addSubview:self.qrLineImageView];
    [self addSubview:self.remindImageView];
    [self addSubview:self.remindLabel];
    [self addSubview:self.lightButton];
    [self addSubview:self.lightLabel];
    [self.lightButton addSubview:self.lightImageView];
    [self show];
    
    self.remindImageView.hidden = self.type == LiteScanQRCodeTypeCoupon;
    self.remindLabel.hidden = self.type == LiteScanQRCodeTypeCoupon;
    
    if (self.type == LiteScanQRCodeTypeRaffle)
    {
        self.remindLabel.text = @"请扫描抽奖活动二维码";
    }
}

- (void)addScreenFillRect:(CGContextRef)ctx rect:(CGRect)rect {
    CGContextSetRGBFillColor(ctx, 40 / 255.0,40 / 255.0,40 / 255.0,0.5);
    CGContextFillRect(ctx, rect);   //draw the transparent layer
}

- (void)addCenterClearRect :(CGContextRef)ctx rect:(CGRect)rect {
    CGContextClearRect(ctx, rect);  //clear the center rect  of the layer
}

- (void)addWhiteRect:(CGContextRef)ctx rect:(CGRect)rect {
    CGContextStrokeRect(ctx, rect);
    CGContextSetRGBStrokeColor(ctx, 1, 1, 1, 1);
    CGContextSetLineWidth(ctx, 0.4);
    CGContextAddRect(ctx, rect);
    CGContextStrokePath(ctx);
}

- (void)addCornerLineWithContext:(CGContextRef)ctx rect:(CGRect)rect{
    //画四个边角
    CGContextSetLineWidth(ctx, 2);
    CGContextSetRGBStrokeColor(ctx, 86 /255.0, 150/255.0, 222/255.0, 1);//蓝色
    //左上角
    CGPoint poinsTopLeftA[] = {
        CGPointMake(rect.origin.x+0.7, rect.origin.y),
        CGPointMake(rect.origin.x+0.7 , rect.origin.y + 15)
    };
    CGPoint poinsTopLeftB[] = {CGPointMake(rect.origin.x, rect.origin.y +0.7),CGPointMake(rect.origin.x + 15, rect.origin.y+0.7)};
    [self addLine:poinsTopLeftA pointB:poinsTopLeftB ctx:ctx];
    //左下角
    CGPoint poinsBottomLeftA[] = {CGPointMake(rect.origin.x+ 0.7, rect.origin.y + rect.size.height - 15),CGPointMake(rect.origin.x +0.7,rect.origin.y + rect.size.height)};
    CGPoint poinsBottomLeftB[] = {CGPointMake(rect.origin.x , rect.origin.y + rect.size.height - 0.7) ,CGPointMake(rect.origin.x+0.7 +15, rect.origin.y + rect.size.height - 0.7)};
    [self addLine:poinsBottomLeftA pointB:poinsBottomLeftB ctx:ctx];
    //右上角
    CGPoint poinsTopRightA[] = {CGPointMake(rect.origin.x+ rect.size.width - 15, rect.origin.y+0.7),CGPointMake(rect.origin.x + rect.size.width,rect.origin.y +0.7 )};
    CGPoint poinsTopRightB[] = {CGPointMake(rect.origin.x+ rect.size.width-0.7, rect.origin.y),CGPointMake(rect.origin.x + rect.size.width-0.7,rect.origin.y + 15 +0.7 )};
    [self addLine:poinsTopRightA pointB:poinsTopRightB ctx:ctx];
    
    CGPoint poinsBottomRightA[] = {CGPointMake(rect.origin.x+ rect.size.width -0.7 , rect.origin.y+rect.size.height+ -15),CGPointMake(rect.origin.x-0.7 + rect.size.width,rect.origin.y +rect.size.height )};
    CGPoint poinsBottomRightB[] = {CGPointMake(rect.origin.x+ rect.size.width - 15 , rect.origin.y + rect.size.height-0.7),CGPointMake(rect.origin.x + rect.size.width,rect.origin.y + rect.size.height - 0.7 )};
    [self addLine:poinsBottomRightA pointB:poinsBottomRightB ctx:ctx];
    CGContextStrokePath(ctx);
}

- (void)addLine:(CGPoint[])pointA pointB:(CGPoint[])pointB ctx:(CGContextRef)ctx {
    CGContextAddLines(ctx, pointA, 2);
    CGContextAddLines(ctx, pointB, 2);
}

#pragma mark - Action

- (void)lightButtonAction:(UIButton *)sender
{
    if (!self.isOpen) {
        if([self.captureDevice hasTorch] && [self.captureDevice hasFlash])
        {
            if(self.captureDevice.torchMode == AVCaptureTorchModeOff)
            {
                [self.captureSession beginConfiguration];
                [self.captureDevice lockForConfiguration:nil];
                [self.captureDevice setTorchMode:AVCaptureTorchModeOn];
                [self.captureDevice setFlashMode:AVCaptureFlashModeOn];
                [self.captureDevice unlockForConfiguration];
                [self.captureSession commitConfiguration];
            }
        }
        [self.captureSession startRunning];
        self.isOpen = YES;
    } else {
        
        [self.captureSession beginConfiguration];
        [self.captureDevice lockForConfiguration:nil];
        if(self.captureDevice.torchMode == AVCaptureTorchModeOn)
        {
            [self.captureDevice setTorchMode:AVCaptureTorchModeOff];
            [self.captureDevice setFlashMode:AVCaptureFlashModeOff];
        }
        [self.captureDevice unlockForConfiguration];
        [self.captureSession commitConfiguration];
        [self.captureSession stopRunning];
        self.isOpen = NO;
    }
}

#pragma mark -

- (UIImageView *)qrLineImageView {
    if (!_qrLineImageView) {
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        UIImage *image = [UIImage imageNamed:@"scan_line"];
        _qrLineImageView =  [[UIImageView alloc] init];
        _qrLineImageView.frame = CGRectMake(screenBounds.size.width/2 - self.transparentArea.width/2,
                                            self.topMargin + self.transparentArea.height - image.size.height, self.transparentArea.width, image.size.height);
        _qrLineImageView.image = image;
        _qrLineImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _qrLineImageView;
}
- (UIImageView *)remindImageView
{
    if (!_remindImageView)
    {
        _remindImageView = [[UIImageView alloc] init];
        _remindImageView.image = [UIImage imageNamed:@"qr_remind"];
        _remindImageView.contentMode = UIViewContentModeScaleAspectFit;
        _remindImageView.frame = CGRectMake(kScreenWidth/2-50, 40, 100, 100);
    }
    return _remindImageView;
}
- (UILabel *)remindLabel
{
    if (!_remindLabel)
    {
        _remindLabel = [[UILabel alloc] init];
        _remindLabel.text = @"扫描设备背面二维码";
        _remindLabel.textColor = [UIColor colorWithWhite:1 alpha:0.6];
        _remindLabel.textAlignment = NSTextAlignmentCenter;
        _remindLabel.font = [UIFont systemFontOfSize:12];
        _remindLabel.frame = CGRectMake(0, 140, kScreenWidth, 20);
    }
    return _remindLabel;
}
- (UIImageView *)lightImageView
{
    if (!_lightImageView)
    {
        _lightImageView = [[UIImageView alloc] init];
        _lightImageView.image = [UIImage imageNamed:@"qr_light"];
        _lightImageView.contentMode = UIViewContentModeScaleAspectFit;
        _lightImageView.frame = CGRectMake(10, 10, 20, 20);
    }
    return _lightImageView;
}
- (UIButton *)lightButton
{
    if (!_lightButton)
    {
        _lightButton = [[UIButton alloc] init];
        _lightButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        [_lightButton addTarget:self action:@selector(lightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _lightButton.clipsToBounds = YES;
        _lightButton.frame = CGRectMake(kScreenWidth/2-20, self.topMargin+self.transparentArea.height+10, 40, 40);
        _lightButton.layer.cornerRadius = 20;
    }
    return _lightButton;
}
- (UILabel *)lightLabel
{
    if (!_lightLabel)
    {
        _lightLabel = [[UILabel alloc] init];
        _lightLabel.text = @"灯光";
        _lightLabel.textAlignment = NSTextAlignmentCenter;
        _lightLabel.textColor = [UIColor colorWithWhite:1 alpha:0.6];
        _lightLabel.font = [UIFont systemFontOfSize:14];
        _lightLabel.frame = CGRectMake(0, self.topMargin+self.transparentArea.height+50, kScreenWidth, 20);
    }
    return _lightLabel;
}
- (AVCaptureSession *)captureSesion
{
    if(_captureSession == nil)
    {
        _captureSession = [[AVCaptureSession alloc] init];
    }
    return _captureSession;
}

- (AVCaptureDevice *)captureDevice
{
    if(_captureDevice == nil)
    {
        _captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    return _captureDevice;
}

@end
