//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-5 上午10:28.
//


#import <Foundation/Foundation.h>
#import "FMDatabaseQueue.h"

@interface FMDatabaseQueue (TBIU_Additions)
- (void)inDatabaseAsync:(id (^)(FMDatabase *db))block withResult:(void (^)(id result))resultBlock;
@end