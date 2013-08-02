//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-17 下午5:14.
//


#import <Foundation/Foundation.h>
#import "FMBaseService.h"
#import "FMCommon.h"


@interface FMVoiceUploadService : FMBaseService

+ (void)uploadVoice:(NSData *)data uploadType:(FM_UPLOAD_TYPE)uploadType
             result:(void (^)(NSString *url, BOOL isSuccess, NSString *error))result
         onProgress:(void (^)(NSUInteger progress))progressBlock;

@end