//
// Created by yuanxiao on 13-6-21.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "FMBaseService.h"

@class FMItemDOList;

@interface FMSearchService : FMBaseService

+ (void)searchItems:(id)params
             result:(void (^)(BOOL, FMItemDOList *, NSString *))result;

@end