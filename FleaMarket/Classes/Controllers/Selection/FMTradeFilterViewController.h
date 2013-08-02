// 
// Created by henson on 12/15/12.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>
#import "FMBaseViewController.h"

@class FMSearchParameter;
@class FMFilterFieldOptionDO;

@interface FMTradeFilterViewController : FMBaseViewController

- (id)initWithSearchParameter:(FMSearchParameter *)searchParameter;

- (void)setDidSelectAction:(void (^)(FMFilterFieldOptionDO *))block;

@end