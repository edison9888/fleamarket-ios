// 
// Created by henson on 6/27/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <TaobaoRemoteObject/RemoteContext.h>
#import <TaobaoRemoteObject/ClientApiInfo.h>
#import <TaobaoRemoteObject/ClientApiBaseReturn.h>
#import <TaobaoRemoteObject/RemoteEvent.h>
#import "FMThemeDO.h"
#import <TaobaoRemoteObject/ClientApiHandler.h>
#import "FMThemeService.h"

#define kErShouGetThemeListAPI @"get.theme.list"
#define kErShouThemePerPage (6)
#define kThemeCacheTime 60 * 60

@implementation FMThemeService {

}

+ (void)getThemes:(NSUInteger)page
           result:(void (^)(BOOL, FMThemeDOList *, NSString *))result {
    if (page < 1) {
        page = 1;
    }

    NSString *pageNumber = [NSString stringWithFormat:@"%d",page];
    NSString *rowsPerPage = [NSString stringWithFormat:@"%d",kErShouThemePerPage];

    RemoteContext *context = [[RemoteContext alloc] init];
    ClientApiInfo *info = [ClientApiInfo objectWithHost:API_ERSHOU_HOST
                                                    api:kErShouGetThemeListAPI
                                                version:kApiErShouVersion];
    info.returnClass = [FMThemeDOList class];

    NSDictionary *params = @{@"pageNumber":pageNumber,@"rowsPerPage":rowsPerPage};
    info.cacheTime = kThemeCacheTime;
    context.clientInfo.time = [NSDate dateWithTimeIntervalSince1970:0];
    context.clientInfo.lat = nil;
    context.clientInfo.lng = nil;
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
            result(NO, nil, @"获取主题失败");
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


@end