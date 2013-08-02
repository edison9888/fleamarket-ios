// 
// Created by henson on 6/19/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import "UIView+Helper.h"
#import "NSObject+AssociatedObjects.h"

@implementation UIView (Helper)

static char kViewTouchCancelBlockKey;

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    if (self.onTouchCancelBlock) {
        self.onTouchCancelBlock(touches, event);
    }
}

- (void)setOnTouchCancelBlock:(BKTouchBlock)block {
    [self associateCopyOfValue:block withKey:&kViewTouchCancelBlockKey];
}

- (BKTouchBlock)onTouchCancelBlock {
    return [self associatedValueForKey:&kViewTouchCancelBlockKey];
}

@end