//
// Created by yuanxiao on 13-6-20.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface FMHotKeywordView : UIView

- (void)setHotKeyword:(NSArray *)hotArray;

- (void)setTouchKeyword:(void (^)(NSString *keyword))block;

@end