//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-9-14 上午9:05.
//


#import <Foundation/Foundation.h>
#import "HandlerDefine.h"
#import "BaseHandler.h"

@class SuccessRemoteEvent;
@class FailedRemoteEvent;


#ifndef TBRO_MEM_CACHE_SIZE
#define TBRO_MEM_CACHE_SIZE (1*1024*1024)
#endif

#ifndef TBRO_DISK_CACHE_SIZE
#define TBRO_DISK_CACHE_SIZE (30*1024*1024)
#endif

#define HTTP_EVENT_EXTRAS_REQUEST               @"request"
#define HTTP_EVENT_EXTRAS_RESPONSE              @"response"

typedef enum {
    TBRO_Thread,
    TBRO_Queue
} HttpHandlerSchedulingStrategy;

@interface HttpHandler : BaseHandler <RemoteHandlerProtocol>

@property(nonatomic) HttpHandlerSchedulingStrategy schedulingStrategy;
@property(nonatomic, TBROPropertyWeak) NSThread *callbackThread;
@property(nonatomic) dispatch_queue_t callbackQueue;

@property(nonatomic, readonly) NSURLCache *urlCache;

+ (HttpHandler *)instance;


- (FailedRemoteEvent *)createFailedEvent:(RemoteContext *)context
                                 request:(NSURLRequest *)request
                                response:(NSURLResponse *)response
                                   error:(NSError *)error;

- (SuccessRemoteEvent *)createSuccessEvent:(RemoteContext *)context
                                   request:(NSURLRequest *)request
                                  response:(NSURLResponse *)response
                            responseObject:(id)responseObject;

@end