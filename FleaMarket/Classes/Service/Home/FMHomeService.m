//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-24 下午6:48.
//


#import <TaobaoRemoteObject/RemoteContext.h>
#import <TaobaoRemoteObject/ClientApiInfo.h>
#import <TaobaoRemoteObject/RemoteEvent.h>
#import <TaobaoRemoteObject/ClientApiBaseReturn.h>
#import "FMHomeService.h"
#import "FMHomeItemDO.h"


@implementation FMHomeService

+ (void)getHomeData:(NSUInteger)page result:(void (^)(BOOL isSuccess, FMHomeRowList *data, NSString *error))result {
    RemoteContext *context = [[RemoteContext alloc] init];
    ClientApiInfo *info = [ClientApiInfo objectWithHost:API_ERSHOU_HOST
                                                    api:@"get.home.data"
                                                version:kApiErShouVersion];
    info.returnClass = [FMHomeRowList class];
    context.info = info;
    context.parameter = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInteger:page]
                                                    forKey:@"pageNumber"];
    [context addSuccessEventListener:^(SuccessRemoteEvent *event) {
        ClientApiBaseReturn *apiBaseReturn = event.responseData;
        if (apiBaseReturn.ret == TBRO_CLIENT_OK) {
            if (result) {
                FMHomeRowList *list = apiBaseReturn.data;
                result(YES, list, nil);
            }
        } else {
            if (result) {
                result(NO, nil, apiBaseReturn.msg);
            }
        }
    }];
    [context addFailedEventListener:^(FailedRemoteEvent *event) {
        if (result) {
            result(NO, nil, @"系统错误");
        }
    }];
    [context request];
}

@end