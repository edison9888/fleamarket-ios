//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-8-26 下午5:16.
//


#import "RemoteContext.h"
#import "HandlerDefine.h"
#import "ClientApiHandler.h"

@implementation RemoteContext {

@private
    id _info;
    id _parameter;
    NSMutableDictionary *_extra;

    ClientInfo *_clientInfo;
    /*! 结构为 key:RemoteEventType value: EventListener  */
    NSMutableDictionary *_eventListener;
    NSMutableArray *_errorMessage;
    id _internal;
    id <RemoteHandlerProtocol> _internalHandler;
    TBROWeak id _internalOperation;
    id _key;
    NSMutableDictionary *_userInfo;
}
@synthesize info = _info;
@synthesize parameter = _parameter;
@synthesize extra = _extra;
@synthesize clientInfo = _clientInfo;
@synthesize errorMessage = _errorMessage;
@synthesize internal = _internal;
@synthesize internalHandler = _internalHandler;
@synthesize internalOperation = _internalOperation;
@synthesize key = _key;
@synthesize userInfo = _userInfo;


- (id)init {
    self = [super init];
    if (self) {
        _eventListener = [[NSMutableDictionary alloc] initWithCapacity:2];
        _extra = [[NSMutableDictionary alloc] init];
        _userInfo = [[NSMutableDictionary alloc] initWithCapacity:0];
        self.clientInfo = [ClientInfo instance];
    }
    return self;
}


- (void)addEventListener:(EventListener)eventListener forType:(RemoteEventType)eventType {
    [_eventListener setObject:[eventListener copy]
                       forKey:[NSNumber numberWithInt:eventType]];
}

- (void)addSuccessEventListener:(SuccessEventListener)eventListener {
    [self addEventListener:(EventListener) eventListener
                   forType:TBRO_SUCCESS];
}

- (void)addFailedEventListener:(FailedEventListener)eventListener {
    [self addEventListener:(EventListener) eventListener
                   forType:TBRO_FAILED];
}

- (void)addProgressEventListener:(ProgressEventListener)eventListener {
    [self addEventListener:(EventListener) eventListener
                   forType:TBRO_PROGRESS];
}

- (void)addCancelEventListener:(CancelEventListener)eventListener {
    [self addEventListener:(EventListener) eventListener
                   forType:TBRO_CANCEL];
}


- (BOOL)hasEventListenerByType:(RemoteEventType)eventType {
    return [self getEventListenerByType:eventType] != nil;
}

- (EventListener)getEventListenerByType:(RemoteEventType)eventType {
    return [_eventListener objectForKey:[NSNumber numberWithInt:eventType]];
}

- (BOOL)hasError {
    return _errorMessage != nil && _errorMessage.count > 0;
}

- (void)addErrorMessage:(NSString *)error {
    [self addNSError:[NSError errorWithDomain:@"TBRemoteObject"
                                         code:400
                                     userInfo:[NSDictionary
                                             dictionaryWithObjectsAndKeys:error, @"message",
                                                                          nil]]];
}

- (void)addNSError:(NSError *)error {
    if (error) {
        TBRO_LOG(@"Error:[%@]", error);
        if (!_errorMessage) {
            _errorMessage = [[NSMutableArray alloc] initWithCapacity:1];
        }
        [_errorMessage addObject:error];
    }
}

- (void)request {
    if (_info) {
        if ([_info isKindOfClass:[NSURLRequest class]]) {
            [[HttpHandler instance] request:self];
        } else if ([_info conformsToProtocol:@protocol(TBROHasHandler)]
                && [_info respondsToSelector:@selector(requestHandler)]) {
            BaseHandler *handler = [_info requestHandler];
            if (handler) {
                [handler request:self];
            }
        }
    }
}


- (void)dealloc {
    TBRO_LOG(@"%@ dealloc", self);
}
@end