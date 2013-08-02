// 
// Created by henson on 7/16/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>

@interface FMButton : UIButton

- (void)setTouchEndAction:(void (^)(NSSet *, UIEvent *))block;

@end