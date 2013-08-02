//
// Created by yuanxiao on 13-6-27.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class FMAccountInfo;

@interface FMAccountScrollItemView : UIButton

- (void)setTitle:(NSString *)title;

- (void)setCount:(NSInteger)count;

@end

@interface FMAccountScrollView : UIView <UIScrollViewDelegate>

@property (nonatomic, strong) FMAccountInfo *accountInfo;

@end