//
// Created by yuanxiao on 12-10-10.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "FMMessage.h"

@implementation FMMessageList

@synthesize items = items;
@synthesize nextPage = _nextPage;
@synthesize totalCount = _totalCount;
@synthesize serverTime = _serverTime;

- (id)init {
    self = [super init];
    if (self) {
        items = [NSMutableArray arrayWithCapacity:5];
    }

    return self;
}


+ (FMMessageList *)getMessageListWithMessageInfoList:(NSArray *)array {
    FMMessageList *messageList = [[FMMessageList alloc] init];
    [messageList.items addObjectsFromArray:array];
    return messageList;
}


@end
