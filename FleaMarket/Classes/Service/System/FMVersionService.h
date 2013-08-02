//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-11-3 上午10:15.
//

#import <Foundation/Foundation.h>
#import "FMBaseService.h"

@interface NewVersionInfo : NSObject

@property(nonatomic) BOOL hasNewVersion;
@property(nonatomic, copy) NSString *newestVersion;
@property(nonatomic, copy) NSString *itemUrl;
@property(nonatomic, copy) NSString *httpUrl;
@end

@interface FMVersionService : FMBaseService

+ (void)getNewVersion:(void (^)(NewVersionInfo *info))ret;

@end