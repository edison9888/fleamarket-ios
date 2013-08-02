//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-9-14 上午9:05.
//


#import "HttpHandler.h"
#import "RemoteEvent.h"
#import "AFNetworking.h"
#import "TBIUCommon.h"
#import "HttpRequestInfo.h"


static NSURLCache *REMOTE_CACHE = nil;

static NSString *const kTBRO_HTTP_CACHE_TIME = @"CACHE_TIME";


@implementation HttpHandler {

@private
    HttpHandlerSchedulingStrategy _schedulingStrategy;
    TBROWeak NSThread *_callbackThread;
    dispatch_queue_t _callbackQueue;
}
@synthesize schedulingStrategy = _schedulingStrategy;
@synthesize callbackThread = _callbackThread;
@synthesize callbackQueue = _callbackQueue;


+ (HttpHandler *)instance {
    static HttpHandler *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }

    return _instance;
}

- (id)init {
    self = [super init];
    if (self) {
        _schedulingStrategy = TBRO_Queue;
        @synchronized ([HttpHandler class]) {

            if (REMOTE_CACHE == nil) {
                if (TBRO_MEM_CACHE_SIZE > 0 || TBRO_DISK_CACHE_SIZE > 0) {
                    REMOTE_CACHE = [[NSURLCache alloc]
                                                initWithMemoryCapacity:TBRO_MEM_CACHE_SIZE
                                                          diskCapacity:TBRO_DISK_CACHE_SIZE
                                                              diskPath:@"tbro_url_cache"];
#if TARGET_OS_IPHONE
                    // Subscribe to app events
                    [[NSNotificationCenter defaultCenter] addObserver:self
                                                             selector:@selector(clearCache)
                                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                                               object:nil];
#endif
                }
            }
        }
    }
    return self;
}

- (void)clearCache {
    [self.urlCache removeAllCachedResponses];
}

- (BOOL)preProcess:(RemoteContext *)context {
    if (!context.info) {
        [context addErrorMessage:@"No Client Info"];
        return NO;
    }
    NSURLRequest *request = nil;
    if ([context.info isKindOfClass:[NSURLRequest class]]) {
        request = context.info;
    } else if ([context.info isKindOfClass:[HttpRequestInfo class]]) {
        HttpRequestInfo *info = (HttpRequestInfo *) context.info;
        if (![info validate]) {
            [context addErrorMessage:@"HttpRequestInfo Validate Failed"];
            return NO;
        }
        request = info.request;
    }

    //必要校验
    if (!request) {
        [context addErrorMessage:@"No Request"];
        return NO;
    }
    context.internal = request;
    return YES;
}


- (void)cancel:(RemoteContext *)context {
    if (context.internalOperation) {
        AFHTTPRequestOperation *operation = context.internalOperation;
        [operation cancel];
        context.internalOperation = nil;
    }
    [super cancel:context];
}


- (NSURLCache *)urlCache {
    return REMOTE_CACHE;
}


- (void)process:(RemoteContext *)context {
    NSURLRequest *request = context.internal;
    TBRO_LOG(@"Request:[%@]", request);
    if ([self processCache:context]) {
        TBRO_LOG(@"cache hit");
        return;
    }

    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [self schedule:context
  requestOperation:requestOperation];
    context.internalOperation = requestOperation;
    [requestOperation start];
}

- (BOOL)processCache:(RemoteContext *)context {
    NSURLRequest *request = context.internal;
    if ([context.info isKindOfClass:[TBROCachedInfo class]]) {
        TBROCachedInfo *info = context.info;
        TBRO_LOG(@"check cache policy:[%@]", info);
        if (info.cacheTime > 0) {
            NSURLCache *cache = self.urlCache;
            NSCachedURLResponse *response = [cache cachedResponseForRequest:request];
            if (response) {
                NSNumber *cacheTime = [response.userInfo objectForKey:kTBRO_HTTP_CACHE_TIME];
                if (cacheTime) {
                    if ([[NSDate date] timeIntervalSince1970] - [cacheTime doubleValue] <= info.cacheTime) {
                        NSURLResponse *urlResponse = response.response;
                        SuccessRemoteEvent *event = [self createSuccessEvent:context
                                                                     request:request
                                                                    response:urlResponse
                                                              responseObject:response.data];
                        event.isCache = YES;
                        TBIURunInCurrent *current = [[TBIURunInCurrent alloc] init];
                        current.currentQueue = _callbackQueue ? : dispatch_get_current_queue();
                        current.currentThread = _callbackThread ? : [NSThread currentThread];
                        TBIURunType type = TBIU_AUTO;
                        if (_schedulingStrategy == TBRO_Queue) {
                            type = TBIU_QUEUE;
                        } else if (_schedulingStrategy == TBRO_Thread) {
                            type = TBIU_THREAD;
                        }

                        if ([context hasEventListenerByType:TBRO_SUCCESS]) {
                            [current runInType:type
                                     withBlock:^{
                                         [context getEventListenerByType:TBRO_SUCCESS](event);
                                     }];
                        }

                        return YES;
                    } else {
                        [cache removeCachedResponseForRequest:request];
                    }
                } else {
                    [cache removeCachedResponseForRequest:request];
                }

            }
        }
    }
    return NO;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"


- (void)schedule:(RemoteContext *)context requestOperation:(AFHTTPRequestOperation *)requestOperation {
    TBIURunInCurrent *current = [[TBIURunInCurrent alloc] init];
    current.currentQueue = _callbackQueue ? : dispatch_get_current_queue();
    current.currentThread = _callbackThread ? : [NSThread currentThread];
    TBIURunType type = TBIU_AUTO;
    if (_schedulingStrategy == TBRO_Queue) {
        type = TBIU_QUEUE;
    } else if (_schedulingStrategy == TBRO_Thread) {
        type = TBIU_THREAD;
    }

    [requestOperation setCompletionBlock:^{
        context.internalOperation = nil;      //需要清空
        if (requestOperation.isCancelled) {
            if ([context hasEventListenerByType:TBRO_CANCEL]) {
                CancelRemoteEvent *event = [[CancelRemoteEvent alloc] init];
                event.context = context;
                [current run:^{
                    [context getEventListenerByType:TBRO_CANCEL](event);
                }
                      inType:type];
            }
            return;
        }
        [self removeContextFromMap:context];
        if (requestOperation.error) {
            if ([context hasEventListenerByType:TBRO_FAILED]) {
                FailedRemoteEvent *event = [self createFailedEvent:context
                                                           request:requestOperation.request
                                                          response:requestOperation.response
                                                             error:requestOperation.error];
                [current run:^{
                    [context getEventListenerByType:TBRO_FAILED](event);
                }
                      inType:type];
            }
        } else {
            if ([context hasEventListenerByType:TBRO_SUCCESS]) {
                SuccessRemoteEvent *event = [self createSuccessEvent:context
                                                             request:requestOperation.request
                                                            response:requestOperation.response
                                                      responseObject:requestOperation.responseData];
                [current run:^{
                    [context getEventListenerByType:TBRO_SUCCESS](event);
                }
                      inType:type];
            }
            [self saveToCache:context
             requestOperation:requestOperation];
        }
    }];

    if ([context hasEventListenerByType:TBRO_PROGRESS]) {
        [requestOperation setUploadProgressBlock:^(NSUInteger bytesWritten, long long int totalBytesWritten, long long int totalBytesExpectedToWrite) {
            ProgressRemoteEvent *event = [[ProgressRemoteEvent alloc] init];
            event.context = context;
            event.status = TBRO_UPLOAD;
            event.bytesWritten = bytesWritten;
            event.totalBytesWritten = totalBytesWritten;
            event.totalBytesExpectedToWrite = totalBytesExpectedToWrite;
            [current run:^{
                [context getEventListenerByType:TBRO_PROGRESS](event);
            }
                  inType:type];

        }];
        [requestOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long int totalBytesRead, long long int totalBytesExpectedToRead) {
            ProgressRemoteEvent *event = [[ProgressRemoteEvent alloc] init];
            event.context = context;
            event.status = TBRO_DOWNLOAD;
            event.bytesRead = bytesRead;
            event.totalBytesRead = totalBytesRead;
            event.totalBytesExpectedToRead = totalBytesExpectedToRead;
            [current run:^{
                [context getEventListenerByType:TBRO_PROGRESS](event);
            }
                  inType:type];
        }];
    }
}

- (void)saveToCache:(RemoteContext *)context requestOperation:(AFHTTPRequestOperation *)requestOperation {
    if ([context.info isKindOfClass:[TBROCachedInfo class]]) {
        TBROCachedInfo *info = context.info;
        TBRO_LOG(@"store cache policy:[%@]", info);
        if (info.cacheTime > 0) {
            NSData *data = nil;
            if (requestOperation.responseData && [requestOperation.responseData isKindOfClass:[NSData class]]) {
                data = requestOperation.responseData;
            }
            [self.urlCache
                    storeCachedResponse:[[NSCachedURLResponse alloc]
                                                              initWithResponse:requestOperation.response
                                                                          data:data
                                                                      userInfo:[NSDictionary
                                                                              dictionaryWithObject:[NSNumber
                                                                                      numberWithDouble:[[NSDate date]
                                                                                                                timeIntervalSince1970]]
                                                                                            forKey:kTBRO_HTTP_CACHE_TIME]
                                                                 storagePolicy:NSURLCacheStorageAllowed]
                             forRequest:requestOperation.request];
        }
    }
}

#pragma clang diagnostic pop
- (FailedRemoteEvent *)createFailedEvent:(RemoteContext *)context
                                 request:(NSURLRequest *)request
                                response:(NSURLResponse *)response
                                   error:(NSError *)error {
    FailedRemoteEvent *event = [[FailedRemoteEvent alloc] init];
    event.context = context;
    [context addNSError:error];
    [event.extra setObject:request ? : [NSNull null]
                    forKey:HTTP_EVENT_EXTRAS_REQUEST];
    [event.extra setObject:response ? : [NSNull null]
                    forKey:HTTP_EVENT_EXTRAS_RESPONSE];
    return event;
}

- (SuccessRemoteEvent *)createSuccessEvent:(RemoteContext *)context
                                   request:(NSURLRequest *)request
                                  response:(NSURLResponse *)response
                            responseObject:(id)responseObject {
    SuccessRemoteEvent *event = [[SuccessRemoteEvent alloc] init];
    event.context = context;
    event.oriResponseData = responseObject;
    event.responseData = responseObject;
    [event.extra setObject:request ? : [NSNull null]
                    forKey:HTTP_EVENT_EXTRAS_REQUEST];
    [event.extra setObject:response ? : [NSNull null]
                    forKey:HTTP_EVENT_EXTRAS_RESPONSE];
    return event;
}

@end