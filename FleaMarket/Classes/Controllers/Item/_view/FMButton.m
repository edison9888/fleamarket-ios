// 
// Created by henson on 7/16/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import "FMButton.h"

@implementation FMButton {
    void (^_touchesEndBlock)(NSSet *, UIEvent *);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if (_touchesEndBlock) {
        _touchesEndBlock(touches, event);
    }
}

- (void)setTouchEndAction:(void (^)(NSSet *, UIEvent *))block {
    _touchesEndBlock = block;
}

@end