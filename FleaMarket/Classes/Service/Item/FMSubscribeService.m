// 
// Created by henson on 2/22/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import "FMSubscribeService.h"
#import "RemoteContext.h"
#import "ClientApiInfo.h"
#import "ClientApiBaseReturn.h"
#import "RemoteEvent.h"
#import "FMItemDO.h"

@implementation FMSubscribeService {

}

+ (void)unsubscribeItem:(id)itemId result:(void (^)(BOOL))result {
    RemoteContext *context = [[RemoteContext alloc] init];
    ClientApiInfo *info = [ClientApiInfo objectWithHost:API_ERSHOU_HOST api:@"unsubscribe.idle.item"
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
        FMLOG(@"%@", event.context.errorMessage);
        if (result) {
            result(NO);
        }
    }                 forType:TBRO_FAILED];
    [context request];
}

+ (void)subscribeItem:(NSString *)itemId result:(void (^)(FMSubscribeType, NSString *))result {
    RemoteContext *context = [[RemoteContext alloc] init];
    ClientApiInfo *info = [ClientApiInfo objectWithHost:API_ERSHOU_HOST api:@"subscribe.idle.item"
                                                version:kApiErShouVersion];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:itemId ? : @"", @"itemId", nil];
    context.info = info;
    context.parameter = params;
    [context addEventListener:(EventListener) ^(SuccessRemoteEvent *event) {
        ClientApiBaseReturn *clientApiBaseReturn = (ClientApiBaseReturn *) event.responseData;
        if (result) {
            NSArray *descArray = [clientApiBaseReturn.desc componentsSeparatedByString:@":"];
            FMSubscribeType subscribeType;
            if (clientApiBaseReturn.ret == TBRO_CLIENT_OK) {
                if ([clientApiBaseReturn.data boolValue]) {
                    subscribeType = FMSubscribeTypeSuccess;
                } else {
                    subscribeType = FMSubscribeTypeSubscribed;
                }
            } else {
                subscribeType = FMSubscribeTypeFailed;
            }
            result(subscribeType, [descArray lastObject]);
        }
    }                 forType:TBRO_SUCCESS];
    [context addEventListener:(EventListener) ^(FailedRemoteEvent *event) {
        FMLOG(@"event.context.errorMessage:%@", event.context.errorMessage);
        if (result) {
            NSError *error = [event.context.errorMessage objectAtIndex:0];
            NSString *errorMessage = error.localizedDescription;
            result(NO, errorMessage);
        }
    }                 forType:TBRO_FAILED];
    [context request];
}

+ (void)isItemSubscribed:(NSString *)itemId result:(void (^)(BOOL))result {
    RemoteContext *context = [[RemoteContext alloc] init];
    ClientApiInfo *info = [ClientApiInfo objectWithHost:API_ERSHOU_HOST api:@"is.idle.item.subscribed"
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
        FMLOG(@"%@", event.context.errorMessage);
        if (result) {
            result(NO);
        }
    }                 forType:TBRO_FAILED];
    [context request];
}

+ (void)getSubscribeList:(NSUInteger)page
                  result:(void (^)(BOOL, FMItemDOList *))result {
    RemoteContext *context = [[RemoteContext alloc] init];
    ClientApiInfo *info = [ClientApiInfo objectWithHost:API_ERSHOU_HOST api:@"get.subscribe.list"
                                                version:@"2"];
    info.returnClass = [FMItemDOList class];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                    [NSNumber numberWithInt:page], @"pageNumber",
                    @"20",@"rowsPerPage",nil];
    context.info = info;
    context.parameter = params;
    [context addEventListener:(EventListener) ^(SuccessRemoteEvent *event) {
        ClientApiBaseReturn *clientApiBaseReturn = (ClientApiBaseReturn *) event.responseData;
        if (result) {
            result(clientApiBaseReturn.ret == TBRO_CLIENT_OK, clientApiBaseReturn.data);
        }
    }                 forType:TBRO_SUCCESS];
    [context addEventListener:(EventListener) ^(FailedRemoteEvent *event) {
        FMLOG(@"%@", event.context.errorMessage);
        if (result) {
            result(NO,nil);
        }
    }                 forType:TBRO_FAILED];
    [context request];
}


@end