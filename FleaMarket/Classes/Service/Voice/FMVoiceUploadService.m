#import <TaobaoRemoteObject/RemoteEvent.h>//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-17 下午5:14.
//


#import <TaobaoRemoteObject/ClientApiInfo.h>
#import <TaobaoRemoteObject/ClientApiBaseReturn.h>
#import "FMVoiceUploadService.h"
#import "PostData.h"


@implementation FMVoiceUploadService {

}
+ (void)uploadVoice:(NSData *)data uploadType:(FM_UPLOAD_TYPE)uploadType
             result:(void (^)(NSString *url, BOOL isSuccess, NSString *error))result
         onProgress:(void (^)(NSUInteger progress))progressBlock {
    RemoteContext *context = [[RemoteContext alloc] init];
    ClientApiInfo *info = [ClientApiInfo objectWithHost:API_ERSHOU_HOST
                                                    api:@"upload.idle.voice"
                                                version:@"1"];
    context.info = info;
    context.parameter = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:uploadType], @"type",
                                                                   nil];
    PostData *postData = [[PostData alloc] init];
    postData.fileData = data;
    postData.fileName = [NSString stringWithFormat:@"voice.amr"];
    postData.contentType = @"audio/amr";

    [context.extra setObject:postData
                      forKey:@"voice"];


    [context addSuccessEventListener:^(SuccessRemoteEvent *event) {
        if (event.isSidInvalid) {
            return;
        }
        ClientApiBaseReturn *apiBaseReturn = event.responseData;
        if (apiBaseReturn.ret == 200) {
            NSString *picUrl = [apiBaseReturn.data objectForKey:@"url"];
            if (result) {
                result(picUrl, YES, nil);
            }
        } else {
            if (result) {
                result(nil, NO, apiBaseReturn.msg);
            }
        }
    }];


    [context addFailedEventListener:^(FailedRemoteEvent *event) {
        FMLOG(@"uploadPic ERROR:%@", event.context.errorMessage);
        if (result) {
            result(nil, NO, nil);
        }
    }];
    [context addProgressEventListener:^(ProgressRemoteEvent *event) {
        if (event.status == TBRO_UPLOAD && event.totalBytesExpectedToWrite > 0 && progressBlock) {
            float percent = event.totalBytesWritten * 100.f / event.totalBytesExpectedToWrite;
            NSUInteger intPercent = [[NSNumber numberWithFloat:percent] unsignedIntegerValue];
            progressBlock(intPercent);
        }
    }
    ];

    [context request];

}

@end