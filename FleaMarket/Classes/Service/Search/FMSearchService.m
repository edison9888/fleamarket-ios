//
// Created by yuanxiao on 13-6-21.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <TaobaoRemoteObject/RemoteContext.h>
#import <TaobaoRemoteObject/ClientApiInfo.h>
#import <TaobaoRemoteObject/ClientApiBaseReturn.h>
#import <TaobaoRemoteObject/RemoteEvent.h>
#import "FMItemDO.h"
#import "FMSearchService.h"


@implementation FMSearchService {

}

+ (void)searchItems:(id)params
             result:(void (^)(BOOL, FMItemDOList *, NSString *))result {
    RemoteContext *context = [[RemoteContext alloc] init];
    ClientApiInfo *info = [ClientApiInfo objectWithHost:API_ERSHOU_HOST
                                                    api:@"idle.item.search"
                                                version:@"2"];
    info.returnClass = [FMItemDOList class];
    context.info = info;
    context.parameter = params;
    FMLOG(@"item search params:%@", params);
    [context addEventListener:(EventListener) ^(SuccessRemoteEvent *event) {
        ClientApiBaseReturn *clientApiBaseReturn = (ClientApiBaseReturn *) event.responseData;
        if (clientApiBaseReturn.ret == TBRO_CLIENT_OK) {
            if (result) {
                result(YES, clientApiBaseReturn.data, nil);
            }
        } else {
            if (result) {
                result(NO, nil, @"系统忙，请稍后再试");
            }
        }

    }
                      forType:TBRO_SUCCESS];

    [context addEventListener:(EventListener) ^(FailedRemoteEvent *event) {
        FMLOG(@"%@", event.context.errorMessage);
        if (result) {
            result(NO, nil, @"服务暂不可用");
        }
    }
                      forType:TBRO_FAILED];
    [context request];
}

@end