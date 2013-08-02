// 
// Created by henson on 5/2/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import "FMBaseViewController.h"
#import "FMSearchParameter.h"

@interface FMSortFilterViewController : FMBaseViewController

- (id)initWithSearchParameter:(FMSearchParameter *)searchParameter;

- (void)setDidSelect:(void (^)(FMSearchConditionSortType))block;

@end