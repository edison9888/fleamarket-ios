//
// Created by yuanxiao on 12-10-9.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "EventDefine.h"

@interface FMCategoryService : NSObject

+ (void)getCategoryList:(NSString *)id success:(EventListener)successListener failed:(EventListener)failedListener;


+ (void)getStdCategoryList:(NSString *)id
                   success:(void (^)(NSArray *cats))success
                    failed:(void (^)(NSString *error))failed;
@end