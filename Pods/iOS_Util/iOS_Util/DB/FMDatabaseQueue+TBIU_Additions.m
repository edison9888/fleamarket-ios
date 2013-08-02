//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-5 上午10:28.
//


#import <objc/message.h>
#import "FMDatabaseQueue+TBIU_Additions.h"
#import "FMDatabase.h"
#import "TBIUCommon.h"


@implementation FMDatabaseQueue (TBIU_Additions)
- (void)inDatabaseAsync:(id (^)(FMDatabase *))block withResult:(void (^)(id))resultBlock {
    TBIURunInCurrent *currentContext = [[TBIURunInCurrent alloc] init];

    dispatch_async(_queue, ^() {
        FMDatabase *db = objc_msgSend(self, @selector(database));
        id ret = block(db);

        if ([db hasOpenResultSets]) {
            NSLog(@"Warning: there is at least one open result set around after performing [FMDatabaseQueue inDatabase:]");
        }
        if (resultBlock) {

            [currentContext run:^{
                resultBlock(ret);
            }];
        }
    }
    );
    FMDBRelease(self);
}

@end