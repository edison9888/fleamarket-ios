//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-10-16 下午1:04.
//


#import <Foundation/Foundation.h>
#import "EventDefine.h"
#import "FMBaseService.h"

@class FMItemPostDO;
@class ProgressRemoteEvent;
@class FMPostRet;
@class FMCategoryList;


@interface FMPostService : FMBaseService


+ (void)getUploadToken:(EventListener)successListener
                failed:(EventListener)failedListener;

+ (void)publishOrUpdateWithPic:(FMItemPostDO *)postDO
                       success:(void (^)(FMPostRet *postRet))successListener
                        failed:(void (^)(NSString *error))failedListener
                      progress:(void (^)(ProgressRemoteEvent *progressRemoteEvent))progressListener;

+ (void)guessCategoryInfo:(NSString *)text
                    price:(NSString *)price
                   result:(void (^)(BOOL, FMCategoryList *, NSString *))result;
@end