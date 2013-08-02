//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-24 下午6:48.
//


#import <Foundation/Foundation.h>
#import "FMBaseService.h"

@class FMHomeRowList;

@interface FMHomeService : FMBaseService

+ (void)getHomeData:(NSUInteger)page result:(void (^)(BOOL isSuccess, FMHomeRowList *data, NSString *error))result;

@end