//
// Created by yuanxiao on 13-6-24.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "FMBaseService.h"
#import <TaobaoRemoteObject/RemoteContext.h>
#import <iOS_Util/NSDictionary+TBIU_ToObject.h>
#import <TaobaoRemoteObject/RemoteEvent.h>
#import <TaobaoRemoteObject/ClientApiInfo.h>
#import <TaobaoRemoteObject/ClientApiBaseReturn.h>
#import <TaobaoRemoteObject/HandlerDefine.h>
#import <TaobaoRemoteObject/TopHandler.h>

@class FMListResultDO;
@class FMItemDOList;
@class FMTaoBaoTradeList;

@interface FMTradesService : FMBaseService

+ (void)getTradeSold:(NSUInteger)pageNo withResult:(void (^)(FMListResultDO *))result;

+ (void)getTradeBought:(NSUInteger)pageNo withResult:(void (^)(FMListResultDO *))result;

+ (void)getTradeInfoBy:(NSString *)orderId result:(void (^)(BOOL, id, NSString *))result;

+ (void)modifyItemPrice:(NSString *)orderId
              modifyFee:(NSString *)modifyFee
        newTransportFee:(NSString *)newTransportFee
                 result:(void (^)(BOOL, NSNumber *, NSString *))result;

+ (void)closeTrade:(NSString *)tid
       closeReason:(NSString *)closeReason
            result:(void (^)(BOOL, NSNumber *, NSString *))result;

+ (void)createTrade:(NSString *)itemId
          deliverId:(NSString *)deliverId
          buyerName:(NSString *)buyerName
         buyerPhone:(NSString *)buyerPhone
             result:(void (^)(BOOL, NSString *, NSString *))result;

+ (void)getSellingItems:(NSUInteger)pageNo
                 result:(void (^)(BOOL, FMItemDOList *itemDOList, NSString *))result;

+ (NSString *)getTradeDetail:(NSString *)orderId;

+ (void)getAllTradeBought:(NSUInteger)pageNo
              onlineTotal:(long)onlineTotal
                  keyword:(NSString *)keyword
                   result:(void (^)(BOOL, FMTaoBaoTradeList *))result;

@end