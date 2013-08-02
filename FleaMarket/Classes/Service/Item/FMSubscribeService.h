// 
// Created by henson on 2/22/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>
#import "FMBaseService.h"

@class FMItemDOList;

typedef enum {
    FMSubscribeTypeSuccess,
    FMSubscribeTypeFailed,
    FMSubscribeTypeSubscribed
} FMSubscribeType;

@interface FMSubscribeService : FMBaseService

+ (void)unsubscribeItem:(NSString *)itemId result:(void (^)(BOOL))result;

+ (void)subscribeItem:(NSString *)itemId result:(void (^)(FMSubscribeType, NSString *))result;

+ (void)isItemSubscribed:(NSString *)itemId result:(void (^)(BOOL))result;

+ (void)getSubscribeList:(NSUInteger)page result:(void (^)(BOOL, FMItemDOList *))result;

@end