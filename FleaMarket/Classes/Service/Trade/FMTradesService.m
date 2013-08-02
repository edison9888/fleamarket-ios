// Created by yuanxiao on 13-6-24.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import <TaobaoRemoteObject/ClientApiHandler.h>
#import "FMTradesService.h"
#import "TopInfo.h"
#import "FMApplication.h"
#import "FMUser.h"
#import "FMTradeDO.h"
#import "NSString+Helper.h"
#import "FMItemDO.h"
#import "FMTaoBaoTrade.h"

#define rowsPerPage 20

#define kApiTopTradesSoldGetFields               @"num_iid,tid,status,payment,post_fee,buyer_email,buyer_nick,modified,num,pic_path,price,receiver_address,receiver_city,receiver_district,receiver_mobile,receiver_name,receiver_phone,receiver_state,orders.title,orders.pic_path,orders.price,orders.num,orders.oid,alipay_no,orders.consign_time,orders.shipping_type,orders.logistics_company,orders.invoice_no,orders.num_iid"
#define kApiTopTradesGetFields                   @"orders.title,orders.pic_path,orders.price,orders.num,orders.oid,alipay_no,orders.consign_time,orders.shipping_type,orders.logistics_company,orders.invoice_no,orders.num_iid, tid, pic_path, price, num, status, post_fee, buyer_nick, buyer_message, buyer_email, receiver_state, receiver_city, receiver_district, receiver_address, receiver_name, receiver_phone,receiver_mobile,modified, alipay_no, num_iid, payment"
#define kTopApiCreateTrade                       @"taobao.trade.idle.create"

@implementation FMTradesService {

}

+ (void)getTradeSold:(NSUInteger)pageNo withResult:(void (^)(FMListResultDO *))result {
    TopInfo *info = [[TopInfo alloc] initWithMethod:@"taobao.trades.sold.get" version:@"2.0"];
    info.topSession = [FMApplication instance].loginUser.topSession;
    [info addFields:kApiTopTradesSoldGetFields];
    RemoteContext *context = [[RemoteContext alloc] init];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSString stringWithFormat:@"%d", pageNo], @"page_no",
            [NSString stringWithFormat:@"%d", rowsPerPage], @"page_size", nil];

    context.info = info;
    context.parameter = params;
    [context.extra setObject:@"ershou" forKey:@"ext_type"];
    [context addEventListener:^(SuccessRemoteEvent *event) {
        if (result) {
            NSDictionary *response = [event.responseData objectForKey:@"trades_sold_get_response"];
            if (response) {
                FMListResultDO *resultDO = [[FMListResultDO alloc] init];
                FMTrade *trade = [[response objectForKey:@"trades"]
                        toObjectWithClass:[FMTrade class]];
                resultDO.data = [NSMutableArray arrayWithArray:trade.trade];
                resultDO.totalCount = [[response objectForKey:@"total_results"] unsignedLongValue];
                resultDO.isSuccess = YES;

                result(resultDO);
            } else {
                result(nil);
            }
        }
    }                 forType:TBRO_SUCCESS];
    [context addEventListener:^(FailedRemoteEvent *event) {
        FMLOG(@"%@", event.context.errorMessage);
        if (result) {
            result(nil);
        }
    }                 forType:TBRO_FAILED];
    [context request];
}

+ (void)getTradeBought:(NSUInteger)pageNo withResult:(void (^)(FMListResultDO *))result {
    TopInfo *info = [[TopInfo alloc] initWithMethod:@"taobao.trades.bought.get" version:@"2.0"];
    info.topSession = [FMApplication instance].loginUser.topSession;
    [info addFields:kApiTopTradesSoldGetFields];
    RemoteContext *context = [[RemoteContext alloc] init];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSString stringWithFormat:@"%d", pageNo], @"page_no",
            [NSString stringWithFormat:@"%d", rowsPerPage], @"page_size", nil];

    context.info = info;
    context.parameter = params;
    [context.extra setObject:@"ershou" forKey:@"ext_type"];
    [context addEventListener:^(SuccessRemoteEvent *event) {
        if (result) {
            NSDictionary *response = [event.responseData objectForKey:@"trades_bought_get_response"];
            if (response) {
                FMListResultDO *resultDO = [[FMListResultDO alloc] init];
                FMTrade *trade = [[response objectForKey:@"trades"]
                        toObjectWithClass:[FMTrade class]];
                resultDO.data = [NSMutableArray arrayWithArray:trade.trade];
                resultDO.totalCount = [[response objectForKey:@"total_results"] unsignedLongValue];
                resultDO.isSuccess = YES;

                result(resultDO);
            } else {
                result(nil);
            }
        }
    }                 forType:TBRO_SUCCESS];
    [context addEventListener:^(FailedRemoteEvent *event) {
        FMLOG(@"%@", event.context.errorMessage);
        if (result) {
            result(nil);
        }
    }                 forType:TBRO_FAILED];
    [context request];
}

+ (void)getTradeInfoBy:(NSString *)orderId result:(void (^)(BOOL, id, NSString *))result {
    TopInfo *info = [[TopInfo alloc] initWithMethod:@"taobao.trade.fullinfo.get" version:@"2.0"];
    [info addFields:kApiTopTradesGetFields];
    RemoteContext *context = [[RemoteContext alloc] init];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:orderId ? : @"", @"tid", nil];
    context.info = info;
    context.parameter = params;
    [context addEventListener:(EventListener) ^(SuccessRemoteEvent *event) {
        if (result) {
            NSDictionary *response = [[event.responseData objectForKey:@"trade_fullinfo_get_response"]
                    objectForKey:@"trade"];
            if (response) {
                result(YES, response, nil);
            } else {
                result(NO, nil, nil);
            }
        }
    }                 forType:TBRO_SUCCESS];
    [context addEventListener:(EventListener) ^(FailedRemoteEvent *event) {
        FMLOG(@"%@", event.context.errorMessage);
        if (result) {
            result(NO, nil, nil);
        }
    }                 forType:TBRO_FAILED];
    [context request];
}

+ (void)modifyItemPrice:(NSString *)orderId
              modifyFee:(NSString *)modifyFee
        newTransportFee:(NSString *)newTransportFee
                 result:(void (^)(BOOL, NSNumber *, NSString *))result {
    RemoteContext *context = [[RemoteContext alloc] init];
    ClientApiInfo *info = [ClientApiInfo objectWithHost:API_ERSHOU_HOST api:@"idle.adjust.price"
                                                version:kApiErShouVersion];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:orderId ? : @"", @"orderId",
                                                                      modifyFee, @"modifyFee",
                                                                      newTransportFee, @"newTransportFee", nil];
    context.info = info;
    context.parameter = params;
    [context addEventListener:(EventListener) ^(SuccessRemoteEvent *event) {
        ClientApiBaseReturn *clientApiBaseReturn = (ClientApiBaseReturn *) event.responseData;
        if (clientApiBaseReturn.ret == TBRO_CLIENT_OK) {
            if (result) {
                result(YES, clientApiBaseReturn.data, nil);
            }
        } else {
            if (result) {
                result(NO, nil, clientApiBaseReturn.msg ?: @"");
            }
        }
    }                 forType:TBRO_SUCCESS];
    [context addEventListener:(EventListener) ^(FailedRemoteEvent *event) {
        FMLOG(@"%@", event.context.errorMessage);
        if (result) {
            result(NO, nil, @"服务不可用");
        }
    }                 forType:TBRO_FAILED];
    [context request];
}

+ (void)closeTrade:(NSString *)tid
       closeReason:(NSString *)closeReason
            result:(void (^)(BOOL, NSNumber *, NSString *))result {
    TopInfo *info = [[TopInfo alloc] initWithMethod:@"taobao.trade.close" version:@"2.0"];
    RemoteContext *context = [[RemoteContext alloc] init];
    context.info = info;
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:tid ? : @"", @"tid",
                                                                      closeReason ? : @"", @"close_reason", nil];
    context.parameter = params;
    [context.extra setObject:@"ershou" forKey:@"ext_type"];
    [context addEventListener:(EventListener) ^(SuccessRemoteEvent *event) {
        FMLOG(@"taobao.trade.close.responseData:%@", event.responseData);
        if (result) {
            NSDictionary *response = [[event.responseData objectForKey:@"trade_close_response"] objectForKey:@"trade"];
            if ([response objectForKey:@"tid"]) {
                result(YES, [NSNumber numberWithBool:YES], nil);
                return;
            }
            result(YES, [NSNumber numberWithBool:NO], nil);
        }
    }                 forType:TBRO_SUCCESS];
    [context addEventListener:(EventListener) ^(FailedRemoteEvent *event) {
        FMLOG(@"%@", event.context.errorMessage);
        if (result) {
            result(NO, nil, @"服务不可用");
        }
    }                 forType:TBRO_FAILED];
    [context request];
}

+ (void)createTrade:(NSString *)itemId
          deliverId:(NSString *)deliverId
          buyerName:(NSString *)buyerName
         buyerPhone:(NSString *)buyerPhone
             result:(void (^)(BOOL, NSString *, NSString *))result {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"1", @"num", nil];
    NSString *ttid = [NSString stringWithFormat:@"ttid_%@", kCurrentTTID];
    if (deliverId != nil) {
        [params setObject:@"0" forKey:@"excway"];
        [params setObject:deliverId forKey:@"address_id"];
    } else {
        [params setObject:@"1" forKey:@"excway"];
        [params setObject:buyerName forKey:@"new_name"];
        [params setObject:buyerPhone forKey:@"new_mobile"];
    }
    [params setObject:ttid forKey:@"attr_list"];
    [params setObject:itemId forKey:@"num_id"];
    [params setObject:[FMTradesService getOrderOutId] forKey:@"out_id"];
    TopInfo *info = [[TopInfo alloc] initWithMethod:kTopApiCreateTrade version:@"2.0"];
    RemoteContext *context = [[RemoteContext alloc] init];
    context.info = info;
    context.parameter = params;
    [context addEventListener:(EventListener) ^(SuccessRemoteEvent *event) {
        NSString *alipayNO = [[[event.responseData objectForKey:@"trade_idle_create_response"]
                objectForKey:@"order_result"]
                objectForKey:@"alipay_no"];
        if ([alipayNO isNotBlank] && result) {
            result(YES, alipayNO, nil);
            return;
        }

        NSDictionary *error = [event.responseData objectForKey:@"error_response"];
        NSString *errMsg = [error objectForKey:@"sub_msg"];
        NSString *errCode = [error objectForKey:@"sub_code"];
        if ([@"buyer_too_many_unpaid_orders" isEqualToString:errCode]) {
            errMsg = @"亲，您有太多未付款订单了";
        } else if ([@"isv.invalid-parameter:buyer_too_many_unpaid_orders" isEqualToString:errCode]) {
            errMsg = @"亲，您有太多未付款订单了";
        } else if ([@"isv.invalid-parameter:max_buy_quantity_exceeded" isEqualToString:errCode]) {
            errMsg = @"亲，您之前已经拍过此宝贝了哦";
        }

        result(NO, nil, errMsg);
        return;
    } forType:TBRO_SUCCESS];
    [context addEventListener:(EventListener) ^(FailedRemoteEvent *event) {
        FMLog(@"%@", event.context.errorMessage);
        if (result) {
            result(NO, nil, nil);
        }
    } forType:TBRO_FAILED];
    [[TopHandler instance] request:context];
}

+ (NSString *)getOrderOutId {
    NSNumber *outNum = [NSNumber numberWithDouble:arc4random()];
    NSString *outId = [outNum stringValue];
    NSString *retID = [NSString stringWithFormat:@"b_%@", outId];
    return retID;
}

+ (void)getSellingItems:(NSUInteger)pageNo
                 result:(void (^)(BOOL, FMItemDOList *itemDOList, NSString *))result {
    RemoteContext *context = [[RemoteContext alloc] init];
    ClientApiInfo *info = [ClientApiInfo objectWithHost:API_ERSHOU_HOST api:@"get.idle.item.by.user"
                                                version:kApiErShouVersion];
    info.returnClass = [FMItemDOList class];
    context.info = info;
    context.parameter = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", pageNo],
                                                                   @"pageNumber",
                                                                   [NSString stringWithFormat:@"%d", 20],
                                                                   @"rowsPerPage",
                                                                   nil];
    [context addEventListener:^(SuccessRemoteEvent *event) {
        ClientApiBaseReturn *clientApiBaseReturn = (ClientApiBaseReturn *) event.responseData;
        if (clientApiBaseReturn.ret == TBRO_CLIENT_OK) {
            if (result) {
                result(YES, clientApiBaseReturn.data, nil);
            }
        } else {
            if (result) {
                result(NO, nil, clientApiBaseReturn.desc);
            }
        }
    }                 forType:TBRO_SUCCESS];
    [context addEventListener:^(FailedRemoteEvent *event) {
        FMLOG(@"%@", event.context.errorMessage);
        if (result) {
            result(NO, nil, nil);

        }
    }                 forType:TBRO_FAILED];
    [context request];
}

+ (NSString *)getTradeDetail:(NSString *)orderId {
    NSString *sid = [FMApplication instance].loginUser.sid;
    NSString *origUrl = [NSString stringWithFormat:@"http://%@/trade/order/order_detail.htm?status_id=1&"
                                                           "pay_order_id=%@&result=1&sid=%@&iwRet=true&ttid=%@",
                                                   URL_TAOBAO_DOMAIN, orderId, sid, kCurrentTTID];
    return origUrl;
}

+ (void)getAllTradeBought:(NSUInteger)pageNo
              onlineTotal:(long)onlineTotal
                  keyword:(NSString *)keyword
                   result:(void (^)(BOOL, FMTaoBaoTradeList *))result {
    RemoteContext *context = [[RemoteContext alloc] init];
    ClientApiInfo *info = [ClientApiInfo objectWithHost:API_ERSHOU_HOST api:@"get.my.order"
                                                version:kApiErShouVersion];
    info.returnClass = [FMTaoBaoTradeList class];
    context.info = info;
    context.parameter = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", pageNo],
                                                                   @"pageNumber",
                                                                   [NSString stringWithFormat:@"%d", 10],
                                                                   @"rowsPerPage",
                                                                   [NSString stringWithFormat:@"%ld", onlineTotal],
                                                                   @"onlineTotal",
                                                                   keyword ? : @"",
                                                                   @"keyword",
                                                                   nil];
    [context addEventListener:(EventListener) ^(SuccessRemoteEvent *event) {
        ClientApiBaseReturn *clientApiBaseReturn = (ClientApiBaseReturn *) event.responseData;
        if (clientApiBaseReturn.ret == TBRO_CLIENT_OK) {
            if (result) {
                result(YES, clientApiBaseReturn.data);
            }
        } else {
            if (result) {
                result(NO, nil);
            }
        }
    }                 forType:TBRO_SUCCESS];
    [context addEventListener:(EventListener) ^(FailedRemoteEvent *event) {
        FMLog(@"%@", event.context.errorMessage);
        if (result) {
            result(NO, nil);

        }
    }                 forType:TBRO_FAILED];
    [[ClientApiHandler instance] request:context];
}

@end