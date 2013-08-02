// 
// Created by henson on 12/3/12.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>


@interface FMSearchHistoryService : NSObject

+ (FMSearchHistoryService *)instance;

- (void)addSearchHistory:(NSString *)keyword;

- (void)deleteSearchHistory:(NSUInteger)index __unused;

- (void)removeAllSearchHistories;

- (NSArray *)getAllSearchHistories;

@end