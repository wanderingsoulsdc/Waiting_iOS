//
//  UIControl+repeat.m
//  iGanDong
//
//  Created by ChenQiuLiang on 16/5/26.
//  Copyright © 2016年 iGanDong. All rights reserved.
//

#import "UIControl+repeat.h"
#import <objc/runtime.h>

@implementation UIControl (repeat)

+ (void)load
{
    @autoreleasepool {
         Method sys_sendAction = class_getInstanceMethod(self, @selector(sendAction:to:forEvent:));
         Method my_sendAction = class_getInstanceMethod(self, @selector(__uxy_sendAction:to:forEvent:));
         method_exchangeImplementations(sys_sendAction, my_sendAction);
    }
}

static const char *UIControl_acceptEventInterval = "UIControl_acceptEventInterval";
static const char *UIControl_acceptedEventTime   = "UIControl_acceptedEventTime";

- (NSTimeInterval)uxy_acceptEventInterval
{
    return [objc_getAssociatedObject(self, UIControl_acceptEventInterval) doubleValue];
}
- (void)setUxy_acceptEventInterval:(NSTimeInterval)uxy_acceptEventInterval
{
    objc_setAssociatedObject(self, UIControl_acceptEventInterval, @(uxy_acceptEventInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSTimeInterval)uxy_acceptedEventTime
{
    return [objc_getAssociatedObject(self, UIControl_acceptedEventTime) doubleValue];
}

- (void)setUxy_acceptedEventTime:(NSTimeInterval)uxy_acceptedEventTime
{
    objc_setAssociatedObject(self, UIControl_acceptedEventTime, @(uxy_acceptedEventTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// 因为两个方法的IMP发生了交换，所以系统调用sendAction的时候，实际上是调用了__uxy_sendAction
// 在判断完事件后，self调用__uxy_sendAction，实际上会调用系统的sendAction，把方法传递出去。
// 所有的control的子类的方法，都会通过这个方法执行。
// 如果不想执行多余的代码，方法一：参考UIViewController-Swizzled，加isSwizzed属性判断是否关闭
// 方法二：遵从协议，只有符合协议的才执行..不符合协议的直接运行交换后的方法以达到执行系统方法的作用。
- (void)__uxy_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
    if (NSDate.date.timeIntervalSince1970 - self.uxy_acceptedEventTime < self.uxy_acceptEventInterval) return;
    
    if (self.uxy_acceptEventInterval > 0)
    {
        self.uxy_acceptedEventTime = NSDate.date.timeIntervalSince1970;
    }
    
    [self __uxy_sendAction:action to:target forEvent:event];
}

@end
