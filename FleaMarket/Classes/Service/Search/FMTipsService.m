//
// Created by yuanxiao on 13-6-20.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <TaobaoRemoteObject/RemoteEvent.h>
#import <TaobaoRemoteObject/Mtop3Handler.h>
#import <TaobaoRemoteObject/ClientApiInfo.h>
#import <TaobaoRemoteObject/ClientApiBaseReturn.h>
#import <TaobaoRemoteObject/ClientApiHandler.h>
#import "FMTipsService.h"
#import "MtopInfo.h"
#import "MtopBaseReturn.h"
#import "NSString+Helper.h"
#import "FMPreference.h"

#define CATEGORY_CACHE_TIME     24 * 60 * 60
#define kHotKeywordCacheName    @"kHotKeywordCacheName"

@implementation FMTipsService {

}

+ (void)getSearchTips:(NSString *)keyword result:(void (^)(NSArray *))result {
    if ([keyword isBlank]) {
        if (result) {
            result(nil);
        }
        return;
    }

    MtopInfo *info = [[MtopInfo alloc] initWithApi:@"com.taobao.search.api.getSuggest" version:@"*"];
    RemoteContext *context = [[RemoteContext alloc] init];
    context.info = info;
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:keyword ? : @"", @"key", nil];
    context.parameter = params;
    [context addEventListener:(EventListener) ^(SuccessRemoteEvent *event) {
        MtopBaseReturn *baseReturn = event.responseData;
        if (result) {
            result([baseReturn.data objectForKey:@"result"]);
        }
    }                 forType:TBRO_SUCCESS];
    [context addEventListener:(EventListener) ^(FailedRemoteEvent *event) {
        FMLOG(@"%@", event.context.errorMessage);
        if (result) {
            result(nil);
        }
    }                 forType:TBRO_FAILED];
    [[Mtop3Handler instance] request:context];
}

+ (void)getHotKeyword:(void (^)(NSArray *))result {
    RemoteContext *context = [[RemoteContext alloc] init];
    ClientApiInfo *info = [ClientApiInfo objectWithHost:API_ERSHOU_HOST api:@"get.hot.search.keyword"
                                                version:kApiErShouVersion];
    context.info = info;
    info.cacheTime = CATEGORY_CACHE_TIME;
    context.clientInfo.time = [NSDate dateWithTimeIntervalSince1970:0];
    context.clientInfo.lat = nil;
    context.clientInfo.lng = nil;
    [context addEventListener:(EventListener) ^(SuccessRemoteEvent *event) {
        ClientApiBaseReturn *clientApiBaseReturn = (ClientApiBaseReturn *) event.responseData;
        if (clientApiBaseReturn.ret == TBRO_CLIENT_OK) {
            if (result) {
                NSArray *array = [clientApiBaseReturn.data objectForKey:@"items"];
                result(array);
                [FMPreference setDiskObject:array ForKey:kHotKeywordCacheName];
            }
        } else {
            if (result) {
                result([FMPreference cacheByKey:kHotKeywordCacheName]);
            }
        }

    }                 forType:TBRO_SUCCESS];

    [context addEventListener:(EventListener) ^(FailedRemoteEvent *event) {
        result([FMPreference cacheByKey:kHotKeywordCacheName]);
    }                 forType:TBRO_FAILED];
    [context request];
}

@end