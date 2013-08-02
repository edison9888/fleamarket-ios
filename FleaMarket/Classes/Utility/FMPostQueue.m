//
//  FMPostQueue.m
//  FleaMarket
//
//  Created by Henson on 8/29/12.
//  Copyright (c) 2012 taobao.com. All rights reserved.
//

#define kPostQueueCacheName      @"FM_POST_QUEUES"

#import <iOS_Util/NSObject+TBIU_BeanCopy.h>
#import "FMPostQueue.h"
#import "FMItemDO.h"
#import "FMPreference.h"

static FMPostQueue *_sharedConstants = nil;

@implementation FMPostQueue

+ (FMPostQueue *)sharedInstance {
    @synchronized(self) {
	    if (_sharedConstants == nil) {
		    _sharedConstants = [[FMPostQueue alloc] init];
	    }
    }
	return _sharedConstants;
}

- (void)putPostQueue:(FMItemDO *)itemDO {
    FMItemDO *newItemDO = [[FMItemDO alloc] init];
    [newItemDO fromBean:itemDO];
    NSMutableDictionary *postQueues = [NSMutableDictionary dictionaryWithDictionary:[self getPostQueue]];
    NSString *timestamp = [NSString stringWithFormat:@"%.f", [[NSDate date] timeIntervalSince1970]];
    if ([newItemDO.queueKey length] > 0 && [postQueues objectForKey:newItemDO.queueKey] != nil) {
        [postQueues removeObjectForKey:newItemDO.queueKey];
        newItemDO.queueKey = timestamp;
        NSDictionary *postInfo = [NSDictionary dictionaryWithObjectsAndKeys:newItemDO,@"item",timestamp,@"time",nil];
        [postQueues setObject:postInfo forKey:timestamp];
    } else {
        newItemDO.queueKey = timestamp;
        NSDictionary *postInfo = [NSDictionary dictionaryWithObjectsAndKeys:newItemDO,@"item",timestamp,@"time",nil];
        [postQueues setObject:postInfo forKey:timestamp];
    }
    itemDO.queueKey = newItemDO.queueKey;
    [self save:postQueues];
}

- (void)deleteItem:(FMItemDO *)itemDO {
    if ([itemDO.queueKey length] < 1) {
        return;
    }
    NSMutableDictionary *postQueues = [self getPostQueue];
    [postQueues removeObjectForKey:itemDO.queueKey];
    [self save:postQueues];
}

- (NSMutableDictionary *)getPostQueue {
    return [FMPreference cacheByKey:kPostQueueCacheName];
}

- (void)clearQueue {
    [FMPreference removeDiskObjectByKey:kPostQueueCacheName];
}

- (void)save:(id)obj {
    [FMPreference setDiskObject:obj ForKey:kPostQueueCacheName];
}

- (NSUInteger)queueCount {
    return [[self getPostQueue] count];
}

@end
