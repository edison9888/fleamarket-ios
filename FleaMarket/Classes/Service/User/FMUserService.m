//
// Created by yuanxiao on 13-6-30.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "FMUserService.h"
#import "EventDefine.h"
#import "ClientApiBaseReturn.h"
#import "FMUserDO.h"
#import "ClientApiInfo.h"
#import "TopInfo.h"
#import <TaobaoRemoteObject/RemoteEvent.h>

@implementation FMUserService {

}

+ (void)getIdleUserInfo:(void (^)(BOOL, FMUserDO *))result {
    RemoteContext *context = [[RemoteContext alloc] init];
    ClientApiInfo *info = [ClientApiInfo objectWithHost:API_ERSHOU_HOST
                                                    api:@"get.idle.user.info"
                                                version:kApiErShouVersion];
    info.returnClass = [FMUserDO class];
    context.info = info;
    [context addEventListener:(EventListener) ^(SuccessRemoteEvent *event) {
        ClientApiBaseReturn *clientApiBaseReturn = (ClientApiBaseReturn *) event.responseData;
        if (clientApiBaseReturn.ret == TBRO_CLIENT_OK) {
            if (result) {
                result(YES, clientApiBaseReturn.data);
            }
            return;
        }

        if (result) {
            result(NO, nil);
        }
    }
                      forType:TBRO_SUCCESS];
    [context addEventListener:(EventListener) ^(FailedRemoteEvent *event) {
        FMLog(@"%@", event.context.errorMessage);
        if (result) {
            result(NO, nil);

        }
    }
                      forType:TBRO_FAILED];
    [context request];
}

+ (void)getUserFlagWithNick:(NSString *)userNick result:(void (^)(NSArray *))result {
    RemoteContext *context = [[RemoteContext alloc] init];
    ClientApiInfo *info = [ClientApiInfo objectWithHost:API_ERSHOU_HOST
                                                    api:@"get.user.tag"
                                                version:kApiErShouVersion];
    context.info = info;
    context.parameter = [NSDictionary dictionaryWithObjectsAndKeys:userNick, @"userNick", nil];
    [context addEventListener:(EventListener) ^(SuccessRemoteEvent *event) {
        ClientApiBaseReturn *clientApiBaseReturn = (ClientApiBaseReturn *) event.responseData;
        if (clientApiBaseReturn.ret == TBRO_CLIENT_OK) {
            id data = clientApiBaseReturn.data;
            if (result) {
                result([data objectForKey:@"tagPicUrls"]);
            }
            return;
        }

        if (result) {
            result(nil);
        }
    }
                      forType:TBRO_SUCCESS];
    [context addEventListener:(EventListener) ^(FailedRemoteEvent *event) {
        FMLog(@"%@", event.context.errorMessage);
        if (result) {
            result(nil);

        }
    }
                      forType:TBRO_FAILED];
    [context request];
}

+ (void)getUserInfo:(NSString *)nick
            success:(void (^)(id data))success
             failed:(void (^)(NSString *error))failed {
    TopInfo *info = [[TopInfo alloc]
            initWithMethod:@"taobao.user.get"
                   version:@"2.0"];
    [info addFields:@"user_id,nick,buyer_credit,vip_info"];
    RemoteContext *context = [[RemoteContext alloc] init];
    if (nick) {
        context.parameter = [NSDictionary dictionaryWithObject:nick
                                                        forKey:@"nick"];
    }
    context.info = info;
    [context addEventListener:(EventListener) ^(SuccessRemoteEvent *event) {
        if (success) {
            success(event.responseData);
        }
    }
                      forType:TBRO_SUCCESS];
    [context addEventListener:(EventListener) ^(FailedRemoteEvent *event) {
        FMLOG(@"%@", event.context.errorMessage);
        if (failed) {
            failed(nil);

        }
    }
                      forType:TBRO_FAILED];
    [context request];
}

+ (NSString *)getUserRate:(NSInteger)rate isBuyer:(BOOL)isBuyer {
    NSString *rateUrl = @"http://pics.taobaocdn.com/newrank/%@_%@_%d.gif";
    if (isBuyer) {
        rateUrl = @"http://a.tbcdn.cn/sys/common/icon/rank/%@_%@_%d.gif";
    }
    NSArray *rateArray = [NSArray arrayWithObjects:@"red",
                                                   @"blue",
                                                   @"cap",
                                                   @"crown",
                                                   nil];
    long SELLER_RATE_LEVEL[] =
            {10, 40, 90, 150, 250, /**/500, 1000, 2000, 5000, 10000,/**/ 20000, 50000, 100000,
                    200000, 500000, /**/1000000, 2000000, 5000000, 10000000};
    int rate_length = 19;

    int level;
    for (level = 0; level < rate_length; level++) {
        if (rate <= SELLER_RATE_LEVEL[level]) {
            break;
        }
    }
    level = level > rate_length ? rate_length : level;   //最大到数组长度

    return [NSString stringWithFormat:rateUrl,
                                      isBuyer ? @"b" : @"s",
                                      [rateArray objectAtIndex:(NSUInteger )level / 5],
                                      level % 5 + 1];
}

@end