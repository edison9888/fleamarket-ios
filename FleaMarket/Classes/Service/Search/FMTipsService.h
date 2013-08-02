//
// Created by yuanxiao on 13-6-20.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface FMTipsService : NSObject

+ (void)getSearchTips:(NSString *)keyword result:(void (^)(NSArray *))result;

+ (void)getHotKeyword:(void (^)(NSArray *))result;

@end