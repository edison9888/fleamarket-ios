//
// Created by yuanxiao on 12-10-9.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "FMCategoryService.h"
#import "RemoteContext.h"
#import "ClientApiInfo.h"
#import "RemoteEvent.h"
#import "ClientApiBaseReturn.h"
#import "FMCategory.h"


#define CATEGORY_CACHE_TIME 24 * 60 * 60

@implementation FMCategoryService

+ (void)getCategoryList:(NSString *)id
                success:(EventListener)successListener
                 failed:(EventListener)failedListener {
    RemoteContext *context = [[RemoteContext alloc] init];
    ClientApiInfo *info = [ClientApiInfo objectWithHost:API_ERSHOU_HOST
                                                    api:@"idle.get.category"
                                                version:kApiErShouVersion];
    info.cacheTime = CATEGORY_CACHE_TIME;
    context.clientInfo.time = [NSDate dateWithTimeIntervalSince1970:0];
    context.clientInfo.lat = nil;
    context.clientInfo.lng = nil;
    info.returnClass = [FMCategoryList class];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:id ? : @"", @"catId",
                                                                      [NSNumber numberWithInt:1],
                                                                      @"front",
                                                                      nil];
    context.info = info;
    context.parameter = params;
    [context addEventListener:successListener
                      forType:TBRO_SUCCESS];
    [context addEventListener:failedListener
                      forType:TBRO_FAILED];
    [context request];
}

+ (void)getStdCategoryList:(NSString *)id success:(void (^)(NSArray *))success failed:(void (^)(NSString *))failed {
    RemoteContext *context = [[RemoteContext alloc] init];
    ClientApiInfo *info = [ClientApiInfo objectWithHost:API_ERSHOU_HOST
                                                    api:@"idle.get.std.category"
                                                version:kApiErShouVersion];
    info.cacheTime = CATEGORY_CACHE_TIME;
    context.clientInfo.time = [NSDate dateWithTimeIntervalSince1970:0];
    context.clientInfo.lat = nil;
    context.clientInfo.lng = nil;
    info.returnClass = [FMCategoryList class];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:id ? : @"", @"catId",
                                                                      nil];
    context.info = info;
    context.parameter = params;
    [context addSuccessEventListener:^(SuccessRemoteEvent *event) {

        ClientApiBaseReturn *apiBaseReturn = event.responseData;
        if (apiBaseReturn.ret == 200) {
            FMCategoryList *responseData = apiBaseReturn.data;
            if (success) {
                success(responseData.items);
            }
        } else {
            FMLOG(@"getStdCategoryList ERROR:%@", apiBaseReturn.desc);
            if (failed) {
                failed(nil);
            }
        }
    }
    ];
    [context addFailedEventListener:^(FailedRemoteEvent *event) {
        FMLOG(@"getStdCategoryList ERROR:%@", event.context.errorMessage);
        if (failed) {
            failed(nil);
        }
    }
    ];

    [context request];
}


@end