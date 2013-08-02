// 
// Created by henson on 6/24/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>
#import "FMBaseService.h"

@class FMItemDetailResponseDO;
@class FMDeliveryDOList;

@interface FMItemService : FMBaseService

+ (void)barCodeSearch:(NSString *)code result:(void (^)(BOOL, id, NSString *))result;

+ (void)getItemDetail:(NSString *)itemId result:(void (^)(BOOL, FMItemDetailResponseDO *, NSString *))result;

+ (void)getDeliveryInfoList:(void (^)(BOOL, FMDeliveryDOList *, NSString *))result;

+ (void)deleteItemById:(id)itemId result:(void (^)(BOOL))result;

@end