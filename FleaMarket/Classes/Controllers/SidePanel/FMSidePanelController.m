//
// Created by yuanxiao on 13-6-6.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <QuartzCore/QuartzCore.h>
#import "FMSidePanelController.h"


@implementation UIViewController (FMSidePanel)

- (FMSidePanelController *)fmSidePanelController {
    return (FMSidePanelController *)[UIApplication sharedApplication].keyWindow.rootViewController;
}

@end

@implementation FMSidePanelController {

}

//去掉阴影
- (void)styleContainer:(UIView *)container animate:(BOOL)animate duration:(NSTimeInterval)duration {
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRoundedRect:container.bounds cornerRadius:0.0f];
    if (animate) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
        animation.fromValue = (id)container.layer.shadowPath;
        animation.toValue = (id)shadowPath.CGPath;
        animation.duration = duration;
        [container.layer addAnimation:animation forKey:@"shadowPath"];
    }
    container.layer.shadowPath = shadowPath.CGPath;
    container.layer.shadowColor = [UIColor blackColor].CGColor;
    container.layer.shadowRadius = 5.0f;
    container.layer.shadowOpacity = 0.5f;
    container.clipsToBounds = NO;
}

- (void)stylePanel:(UIView *)panel {
    panel.layer.cornerRadius = 3.0f;
    panel.clipsToBounds = YES;
}

@end