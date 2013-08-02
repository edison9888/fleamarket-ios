//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-8-27 下午6:00.
//


#import <Foundation/Foundation.h>
#import "HandlerDefine.h"


@interface BaseHandler : NSObject <RemoteHandlerProtocol> {
}

+ (NSArray *)getAllHandler;

+ (void)cancelAllByKey:(id)key;

- (void)removeContextFromMap:(RemoteContext *)remoteContext;

@property (nonatomic,copy) TBROMonitorFunction monitorFunction;


@end