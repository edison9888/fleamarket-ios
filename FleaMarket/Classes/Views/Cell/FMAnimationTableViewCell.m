//
// Created by yuanxiao on 13-7-10.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <QuartzCore/QuartzCore.h>
#import "FMAnimationTableViewCell.h"


@implementation FMAnimationTableViewCell {
@private
    BOOL _isAnimation;
    NSInteger _row;
}

@synthesize row = _row;

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if (_row > 0) {
        if (_isAnimation) {
            return;
        }
        _isAnimation = YES;
        [self animation];
    }
}

- (void)setRow:(NSInteger)row {
    _row = row + 1;
}

- (void)animation {
    CGRect frame = self.frame;
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.duration = 0.6f + _row * 0.1;
    CGMutablePathRef path = CGPathCreateMutable();
    //移动到开始坐标
    CGPathMoveToPoint(path, NULL, -(frame.size.width + _row * 50), frame.size.height/2 + frame.origin.y);
    //添加路劲坐标点   先移动到 靠近位置
    CGPathAddLineToPoint(path, NULL, frame.size.width/2 - 50, frame.size.height/2 + frame.origin.y);
    //移动到  超出位置  看起来有反弹效果
    CGPathAddLineToPoint(path, NULL, frame.size.width/2 + 50, frame.size.height/2 + frame.origin.y);
//    CGPathAddLineToPoint(path, NULL, frame.size.width/2 + 20, frame.size.height/2 + frame.origin.y);
    //最终的坐标
    CGPathAddLineToPoint(path, NULL, frame.size.width/2, frame.size.height/2 + frame.origin.y);
    positionAnimation.path = path;
    positionAnimation.delegate = self;
    positionAnimation.removedOnCompletion = YES;
    CGPathRelease(path);
    positionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [self.layer addAnimation:positionAnimation forKey:@"move"];
}

@end