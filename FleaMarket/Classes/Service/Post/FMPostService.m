//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-10-16 下午1:04.
//


#import "FMPostService.h"
#import "ClientApiInfo.h"
#import "RemoteContext.h"
#import "FMPostRet.h"
#import "ClientApiHandler.h"
#import "MtopInfo.h"
#import "Mtop3Handler.h"
#import "FMItemPostDO.h"
#import "RemoteEvent.h"
#import "ClientApiBaseReturn.h"
#import "NSString+Helper.h"
#import "FMCategory.h"

#define kApiGetPostToken @"com.taobao.wireless.mtop.getdisposabletoken"
#define kApiPostItem @"idle.item.publish"
#define kApiEditItem @"idle.item.edit"

@implementation FMPostService

+ (void)getUploadToken:(EventListener)successListener failed:(EventListener)failedListener {
    RemoteContext *context = [[RemoteContext alloc] init];
    MtopInfo *info = [[MtopInfo alloc] initWithApi:kApiGetPostToken version:@"1.0"];
    info.needEcode = YES;
    context.info = info;
    context.parameter = [NSDictionary dictionaryWithObjectsAndKeys:@"ershou_upload", @"from", nil];
    [context addEventListener:successListener forType:TBRO_SUCCESS];
    [context addEventListener:failedListener forType:TBRO_FAILED];
    [[Mtop3Handler instance] request:context];
}


+ (void)publishOrUpdateWithPic:(FMItemPostDO *)postDO
                       success:(void (^)(FMPostRet *))successListener
                        failed:(void (^)(NSString *))failedListener
                      progress:(void (^)(ProgressRemoteEvent *))progressListener {
    NSString *api = [postDO.itemId isNotBlank] ? @"idle.item.edit" : @"idle.item.publish";
    RemoteContext *context = [[RemoteContext alloc] init];
    ClientApiInfo *info = [ClientApiInfo objectWithHost:API_ERSHOU_HOST api:api
                                                version:@"2"];
    info.returnClass = [FMPostRet class];
    info.forcePost = YES;
    context.info = info;
    context.parameter = postDO;
    [context addEventListener:(EventListener) ^(SuccessRemoteEvent *event) {
            ClientApiBaseReturn *apiBaseReturn = event.responseData;
            if (apiBaseReturn.ret == 200) {
                FMPostRet *responseData = apiBaseReturn.data;
                if (successListener) {
                    successListener(responseData);
                }
                return;
            } else {
                NSString *error = @"系统忙，请稍后再试";
                if (apiBaseReturn.ret == 400) {
                    NSString *returnDescription = apiBaseReturn.desc;
                    FMLOG(@"publishOrUpdateWithPic ERROR:%@", returnDescription);
                    if ([returnDescription hasPrefix:@"="]) {
                        error = [returnDescription substringFromIndex:1];
                    }
                }
                if (failedListener) {
                    failedListener(error);
                }
            }
        }                 forType:TBRO_SUCCESS];
    [context addEventListener:(EventListener) ^(FailedRemoteEvent *event) {
            FMLOG(@"publishOrUpdateWithPic ERROR:%@", event.context.errorMessage);
            if (failedListener) {
                failedListener(@"系统忙，请稍后再试");
            }

        }                 forType:TBRO_FAILED];
    if (progressListener) {
        [context addEventListener:(EventListener) progressListener forType:TBRO_PROGRESS];
    }

    [[ClientApiHandler instance] request:context];
}

+ (void)guessCategoryInfo:(NSString *)text
                    price:(NSString *)price
                   result:(void (^)(BOOL,FMCategoryList *, NSString *))result {
    if (!text || [text isBlank]) {
        if (result) {
            result(NO, nil, @"");
        }
        return;
    }

    RemoteContext *context = [[RemoteContext alloc] init];
    ClientApiInfo *info = [ClientApiInfo objectWithHost:API_ERSHOU_HOST api:@"guess.category"
                                                version:kApiErShouVersion];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:text ? : @"", @"title",
                                                                      price, @"price",nil];
    context.info = info;
    context.parameter = params;
    info.returnClass = [FMCategoryList class];
    [context addEventListener:(EventListener) ^(SuccessRemoteEvent *event) {
        ClientApiBaseReturn *clientApiBaseReturn = (ClientApiBaseReturn *) event.responseData;
        if (clientApiBaseReturn.ret == TBRO_CLIENT_OK) {
            if (result) {
                result(YES, clientApiBaseReturn.data, nil);
            }
        } else {
            if (result) {
                result(NO, nil, @"获取失败");
            }
        }
    }                 forType:TBRO_SUCCESS];
    [context addEventListener:(EventListener) ^(FailedRemoteEvent *event) {
        FMLOG(@"%@", event.context.errorMessage);
        if (result) {
            result(NO, nil, @"服务不可用");
        }
    }                 forType:TBRO_FAILED];
    [[ClientApiHandler instance] request:context];
}

@end