//
//  FMPostQueue.h
//  FleaMarket
//
//  Created by Henson on 8/29/12.
//  Copyright (c) 2012 taobao.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMItemDO;

@interface FMPostQueue : NSObject {
    
}

+ (FMPostQueue *)sharedInstance;

- (void)putPostQueue:(FMItemDO *)itemDetail;

- (NSMutableDictionary *)getPostQueue;

- (void)deleteItem:(FMItemDO *)itemDO;

- (void)clearQueue;

- (NSUInteger)queueCount;

@end
