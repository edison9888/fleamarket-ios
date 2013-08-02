//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-11-15 下午5:12.
//

#import "FMPicService.h"
#import "RemoteContext.h"
#import "ClientApiInfo.h"
#import "PostData.h"
#import "RemoteEvent.h"
#import "ClientApiBaseReturn.h"
#import "ClientApiHandler.h"
#import "UIImage+Helper.h"
#import "FMSetting.h"
#import "FMApplication.h"
#import "FMCommon.h"

@implementation FMPicService

static void uploadRecursion(NSArray *picUrls, NSUInteger idx, NSMutableArray *urls, NSMutableArray *errors,
        FM_UPLOAD_PIC_RESULT_GROUP_BLOCK result, FM_UPLOAD_PIC_PROGRESS_GROUP_BLOCK progress) {
    NSString *pathUrl = [picUrls objectAtIndex:idx];
    [FMPicService uploadPicWithUrl:pathUrl
                            result:^(NSString *url, BOOL isSuccess, NSString *error) {
                                if (isSuccess) {
                                    [urls addObject:url ? : @""];
                                    [errors addObject:@""];
                                } else {
                                    [urls addObject:@""];
                                    [errors addObject:error ? : @""];
                                }
                                NSUInteger nextIdx = idx + 1;
                                if (nextIdx < [picUrls count]) {
                                    uploadRecursion(picUrls, nextIdx, urls, errors, result, progress);
                                } else {
                                    if (result) {
                                        result(urls, errors);
                                    }
                                }
                            }
                        onProgress:^(NSUInteger percent) {
                            if (progress) {
                                progress(idx, percent);
                            }
                        }];
}

static void uploadRecursionWithImage(NSArray *images, NSUInteger idx, NSMutableArray *urls, NSMutableArray *errors,
        FM_UPLOAD_PIC_RESULT_GROUP_BLOCK result, FM_UPLOAD_PIC_PROGRESS_GROUP_BLOCK progress) {
    UIImage *image = [images objectAtIndex:idx];
    [FMPicService uploadImage:image
                            result:^(NSString *url, BOOL isSuccess, NSString *error) {
                                if (isSuccess) {
                                    [urls addObject:url ? : @""];
                                    [errors addObject:@""];
                                } else {
                                    [urls addObject:@""];
                                    [errors addObject:error ? : @""];
                                }
                                NSUInteger nextIdx = idx + 1;
                                if (nextIdx < [images count]) {
                                    uploadRecursionWithImage(images, nextIdx, urls, errors, result, progress);
                                } else {
                                    if (result) {
                                        result(urls, errors);
                                    }
                                }
                            }
                        onProgress:^(NSUInteger percent) {
                            if (progress) {
                                progress(idx, percent);
                            }
                        }];
}

+ (void)uploadPicWithUrls:(NSArray *)picUrls
                   result:(FM_UPLOAD_PIC_RESULT_GROUP_BLOCK)result
               onProgress:(FM_UPLOAD_PIC_PROGRESS_GROUP_BLOCK)onProgress {
    if (picUrls && [picUrls count] > 0) {
        NSUInteger idx = 0;
        NSMutableArray *urls = [[NSMutableArray alloc] initWithCapacity:[picUrls count]];
        NSMutableArray *errors = [[NSMutableArray alloc] initWithCapacity:[picUrls count]];
        uploadRecursion(picUrls, idx, urls, errors, result, onProgress);
    } else {
        if (result) {
            result([NSArray array], [NSArray array]);
        }
    }
}

+ (void)uploadPicWithImages:(NSArray *)images
                     result:(FM_UPLOAD_PIC_RESULT_GROUP_BLOCK)result
                 onProgress:(FM_UPLOAD_PIC_PROGRESS_GROUP_BLOCK)onProgress {
    if (images && [images count] > 0) {
        NSUInteger idx = 0;
        NSMutableArray *urls = [[NSMutableArray alloc] initWithCapacity:[images count]];
        NSMutableArray *errors = [[NSMutableArray alloc] initWithCapacity:[images count]];
        uploadRecursionWithImage(images, idx, urls, errors, result, onProgress);
    } else {
        if (result) {
            result([NSArray array], [NSArray array]);
        }
    }
}

+ (void)uploadPicWithUrl:(NSString *)picUrl
                  result:(FM_UPLOAD_PIC_RESULT_BLOCK)result
              onProgress:(FM_UPLOAD_PIC_PROGRESS_BLOCK)onProgress {

    [self uploadImage:[UIImage imageWithContentsOfFile:picUrl]
               result:result
           onProgress:onProgress];

}

+ (void)uploadImage:(UIImage *)image
             result:(void (^)(NSString *, BOOL, NSString *))result
         onProgress:(void (^)(NSUInteger))onProgress {
    BOOL isAutoImageCompress = [FMApplication instance].setting.isAutoImageCompress;
    UIImage *uploadImage = [image scaleToSize:isAutoImageCompress ? CGSizeMake(640, 960) : CGSizeMake(image.size.width, image.size.width)];
    NSData *jpgData = UIImageJPEGRepresentation(uploadImage, 0.8f);
    [self uploadPic:jpgData
             result:result
         onProgress:onProgress];
}

+ (void)uploadPic:(NSData *)picData
           result:(void (^)(NSString *, BOOL, NSString *))result
       onProgress:(void (^)(NSUInteger))onProgress {
    RemoteContext *context = [[RemoteContext alloc] init];
    ClientApiInfo *info = [ClientApiInfo objectWithHost:API_ERSHOU_HOST api:@"upload.idle.pic"
                                                version:@"1"];
    context.info = info;
    context.parameter = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:FM_UPLOAD_TYPE_POST], @"type",
                                                                   nil];

    PostData *postData = [[PostData alloc] init];
    postData.fileData = picData;
    postData.fileName = [NSString stringWithFormat:@"imagefile.jpg"];
    postData.contentType = @"image/jpeg";

    [context.extra setObject:postData forKey:@"pic"];
    [context addEventListener:(EventListener) ^(SuccessRemoteEvent *event) {
            ClientApiBaseReturn *apiBaseReturn = event.responseData;
            if (apiBaseReturn.ret == 200) {
                NSString *picUrl = [apiBaseReturn.data objectForKey:@"url"];
                if (result) {
                    result(picUrl, YES, nil);
                }
            } else {
                if (result) {
                    NSString *error = nil;
                    NSString *returnDescription = apiBaseReturn.desc;
                    if ([returnDescription hasPrefix:@"="]) {
                        error = [returnDescription substringFromIndex:1];
                    }
                    result(nil, NO, error);
                }
            }
        }                 forType:TBRO_SUCCESS];
    [context addEventListener:(EventListener) ^(FailedRemoteEvent *event) {
            FMLog(@"uploadPic ERROR:%@", event.context.errorMessage);
            if (result) {
                result(nil, NO, nil);
            }
        }                 forType:TBRO_FAILED];
    [context addEventListener:(EventListener) ^(ProgressRemoteEvent *event) {
            if (event.status == TBRO_UPLOAD && event.totalBytesExpectedToWrite > 0 && onProgress) {
                float percent = event.totalBytesWritten * 100.f / event.totalBytesExpectedToWrite;
                NSUInteger intPercent = [[NSNumber numberWithFloat:percent] unsignedIntegerValue];
                onProgress(intPercent);
            }
        }                 forType:TBRO_PROGRESS];
    [[ClientApiHandler instance] request:context];
}

@end

