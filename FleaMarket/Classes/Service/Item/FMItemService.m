// 
// Created by henson on 6/24/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <TaobaoRemoteObject/HandlerDefine.h>
#import <TaobaoRemoteObject/Mtop3Handler.h>
#import <TaobaoRemoteObject/ClientApiHandler.h>
#import "FMItemService.h"
#import "ClientApiInfo.h"
#import "RemoteEvent.h"
#import "ClientApiBaseReturn.h"
#import "FMItemDO.h"
#import "NSString+Helper.h"
#import "MtopInfo.h"
#import "MtopBaseReturn.h"
#import "FMDeliveryDO.h"
#import "FMUser.h"
#import "FMApplication.h"

#define kMTOPBarCodeSearchAPI  @"mtop.etao.kaka.barcode.search"
#define kErShouItemDetailAPI @"idle.item.detail"
#define kMTOPGetAddressListAPI @"com.taobao.mtop.deliver.getAddressList"
#define kErShouItemDeleteAPI @"idle.item.delete"

@implementation FMItemService {

}

+ (void)barCodeSearch:(NSString *)code result:(void (^)(BOOL, id, NSString *))result {
    if (!code || [code isBlank]) {
        if (result) {
            result(NO,nil,nil);
        }
        return;
    }

    MtopInfo *info = [[MtopInfo alloc] initWithApi:kMTOPBarCodeSearchAPI version:@"1.0"];
    RemoteContext *context = [[RemoteContext alloc] init];
    context.info = info;
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:code, @"content",
                                                                      @"EAN13", @"type",
                                                                      @"", @"gps",nil];
    context.parameter = params;
    [context addEventListener:(EventListener) ^(SuccessRemoteEvent *event) {
        FMLog(@"barcode search responseData:%@", event.responseData);
        MtopBaseReturn *baseReturn = event.responseData;
        if (result) {
            result(YES, baseReturn.data, nil);
            return;
        }
    } forType:TBRO_SUCCESS];

    [context addEventListener:(EventListener) ^(FailedRemoteEvent *event) {
        FMLog(@"%@", event.context.errorMessage);
        NSError *error = [event.context.errorMessage objectAtIndex:0];
        NSString *errorMessage = error.localizedDescription;
        if (result) {
            result(NO, nil, errorMessage);
        }
    } forType:TBRO_FAILED];
    [[Mtop3Handler instance] request:context];
}

+ (void)getItemDetail:(NSString *)itemId result:(void (^)(BOOL, FMItemDetailResponseDO *, NSString *))result {
    if (!itemId) {
        if (result) {
            result(NO, nil, @"ItemId is empty.");
        }
        return;
    }

    RemoteContext *context = [[RemoteContext alloc] init];
    ClientApiInfo *info = [ClientApiInfo objectWithHost:API_ERSHOU_HOST
                                                    api:kErShouItemDetailAPI
                                                version:kApiErShouVersion];
    info.returnClass = [FMItemDetailResponseDO class];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:itemId ? : @"", @"itemId", nil];
    context.info = info;
    context.parameter = params;

    [context addEventListener:(EventListener) ^(SuccessRemoteEvent *event) {
        ClientApiBaseReturn *clientApiBaseReturn = (ClientApiBaseReturn *) event.responseData;
        if (clientApiBaseReturn.ret == TBRO_CLIENT_OK) {
            if (result) {
                result(YES, clientApiBaseReturn.data, nil);
            }
            return;
        }

        if (result) {
            result(NO, nil, @"获取详情失败");
        }
        return;
    }                 forType:TBRO_SUCCESS];

    [context addEventListener:(EventListener) ^(FailedRemoteEvent *event) {
        FMLog(@"%@", event.context.errorMessage);
        if (result) {
            result(NO, nil, @"服务不可用");
        }
    }                 forType:TBRO_FAILED];
    [[ClientApiHandler instance] request:context];
}

+ (void)getDeliveryInfoList:(void (^)(BOOL, FMDeliveryDOList *, NSString *))result {
    FMUser *user = [FMApplication instance].loginUser;
    MtopInfo *info = [[MtopInfo alloc] initWithApi:kMTOPGetAddressListAPI version:@"v2"];
    info.needEcode = YES;
    info.ecode = user.ecode;
    info.returnClass = [FMDeliveryDOList class];
    RemoteContext *context = [[RemoteContext alloc] init];
    context.info = info;
    context.parameter = @{@"sid":user.sid};
    [context addEventListener:(EventListener) ^(SuccessRemoteEvent *event) {
        MtopBaseReturn *mtopBaseReturn = (MtopBaseReturn *) event.responseData;
        if (result) {
            result(YES, mtopBaseReturn.data, nil);
        }
        return;
    } forType:TBRO_SUCCESS];

    [context addEventListener:(EventListener) ^(FailedRemoteEvent *event) {
        FMLog(@"%@", event.context.errorMessage);
        if (result) {
            result(NO, nil, @"服务不可用");
        }
    } forType:TBRO_FAILED];
    [[Mtop3Handler instance] request:context];
}

+ (void)deleteItemById:(id)itemId result:(void (^)(BOOL))result {
    RemoteContext *context = [[RemoteContext alloc] init];
    ClientApiInfo *info = [ClientApiInfo objectWithHost:API_ERSHOU_HOST api:kErShouItemDeleteAPI
                                                version:kApiErShouVersion];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:itemId ? : @"", @"itemId", nil];
    context.info = info;
    context.parameter = params;
    [context addEventListener:(EventListener) ^(SuccessRemoteEvent *event) {
        ClientApiBaseReturn *clientApiBaseReturn = (ClientApiBaseReturn *) event.responseData;
        if (result) {
            result(clientApiBaseReturn.ret == TBRO_CLIENT_OK);
        }
    }                 forType:TBRO_SUCCESS];
    [context addEventListener:(EventListener) ^(FailedRemoteEvent *event) {
        FMLog(@"%@ error: %@", kErShouItemDeleteAPI, event.context.errorMessage);
        if (result) {
            result(NO);
        }
    }                 forType:TBRO_FAILED];
    [[ClientApiHandler instance] request:context];
}

@end