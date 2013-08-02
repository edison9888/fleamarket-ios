//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-12-11 下午3:50.
//


#import <UIKit/UIKit.h>
#import "TBROMppSession.h"
#import "TBRONSStringUtil.h"
#import "MppHandler.h"
#import "RemoteEvent.h"
#import "TBROMppReturnData.h"
#import "NSDictionary+TBIU_ToObject.h"
#import "NSString+TBHelper.h"
#import "UIDevice+TBHelper.h"
#import "TBIUJson.h"

@interface TBROMppSession ()
@property(nonatomic, readonly) RemoteContext *currentContext;
@end

@implementation TBROMppSession {

@private
    NSString *_url;
    NSTimeInterval _timeOut;
    RemoteContext *_currentContext;
    NSString *_appId;
    NSString *_uid;
    NSString *_dt;
    NSString *_sid;

    TBRO_MPP_DATA_HANDLER _dataHandler;
    TBRO_MPP_FAILED_HANDLER _failedHandler;

    NSMutableDictionary *_subTypeHandlers;
    BOOL _isRunning;
    NSMutableSet *_subs;
    NSMutableDictionary *_subVersions;
}
@synthesize url = _url;
@synthesize timeOut = _timeOut;
@synthesize currentContext = _currentContext;
@synthesize appId = _appId;
@synthesize uid = _uid;
@synthesize dt = _dt;
@synthesize sid = _sid;
@synthesize isRunning = _isRunning;


- (id)init {
    self = [super init];
    if (self) {
        _timeOut = 0;
        _subTypeHandlers = [[NSMutableDictionary alloc] initWithCapacity:2];
        _isRunning = NO;
        _subs = [NSMutableSet set];
        _subVersions = [NSMutableDictionary dictionary];
    }
    return self;
}

- (const NSUInteger)key {
    const void *selfPtr = (__bridge const void *) self;
    return (const NSUInteger) selfPtr;
}

- (NSDictionary *)subsWithVersion {
    return _subVersions;
}

- (void)addSub:(NSString *)sub {
    [self addSub:sub
     withVersion:0L];
}

- (void)addSub:(NSString *)sub withVersion:(long long)version {
    if (sub) {
        if (![sub isKindOfClass:[NSString class]]) {
            sub = [NSString stringWithFormat:@"%@",
                                             sub];
        }
    } else {
        return;
    }
    if (![_subs containsObject:sub]) {
        [_subs addObject:sub];
    }
    [_subVersions setObject:[NSNumber numberWithLongLong:version]
                     forKey:sub];
}

- (void)addSubs:(NSArray *)subs {
    for (NSString *sub in subs) {
        [self addSub:sub];
    }
}

- (void)replaceSubs:(NSArray *)subs {
    if (!subs || subs.count == 0) {
        [self removeAllSubs];
        return;
    }
    NSMutableSet *newSubs = [NSMutableSet setWithArray:subs];
    NSMutableSet *needRemoveSubs = [NSMutableSet set];
    NSMutableSet *needAddSubs = [NSMutableSet set];
    for (NSString *sub in newSubs) { //遍历新的
        if (![_subs containsObject:sub]) {
            [needAddSubs addObject:sub];
        }
    }

    for (NSString *sub in _subs) { //遍历老的
        if (![newSubs containsObject:sub]) {
            [needRemoveSubs addObject:sub];
        }
    }

    if (needRemoveSubs.count > 0) {
        for (NSString *sub in needRemoveSubs) {
            [self removeSub:sub];
        }
    }

    if (needAddSubs.count > 0) {
        for (NSString *sub in needAddSubs) {
            [self addSub:sub];
        }
    }
}

- (void)removeSub:(NSString *)sub {
    if (sub) {
        if (![sub isKindOfClass:[NSString class]]) {
            sub = [NSString stringWithFormat:@"%@",
                                             sub];
        }
    } else {
        return;
    }
    [_subs removeObject:sub];
    [_subVersions removeObjectForKey:sub];
}

- (void)removeSubs:(NSArray *)subs {
    for (NSString *sub in subs) {
        [self removeSub:sub];
    }
}

- (void)removeAllSubs {
    [_subs removeAllObjects];
    [_subVersions removeAllObjects];
}

#define ADD_TO_URL_REQUEST_ARRAY(key,value,array)                                   \
         if ([TBRONSStringUtil isNotBlank:(value)]) {                                   \
            [array addObject:[NSString stringWithFormat:@"%@=%@", key ,             \
            [value makeURLEncode:kCFStringEncodingUTF8]]];                          \
         }

- (NSURLRequest *)request {
    NSURL *url = nil;
    if ([TBRONSStringUtil isNotBlank:_url] && [TBRONSStringUtil isNotBlank:_appId]) {
        NSMutableArray *urlRequestArray = [[NSMutableArray alloc] initWithCapacity:3];

        ADD_TO_URL_REQUEST_ARRAY(@"appId", _appId, urlRequestArray);
        ADD_TO_URL_REQUEST_ARRAY(@"dt", _dt ? : [[UIDevice currentDevice]
                                                           getUniqueGlobalDeviceIdentifier], urlRequestArray);
        ADD_TO_URL_REQUEST_ARRAY(@"uid", _uid ? : @"", urlRequestArray);
        ADD_TO_URL_REQUEST_ARRAY(@"sid", _sid, urlRequestArray);
        if (_subs && _subs.count > 0) {
            NSArray *subArray = _subs.allObjects;
            NSMutableArray *versionArray = [NSMutableArray arrayWithCapacity:subArray.count];
            for (NSString *sub in subArray) {
                NSNumber *version = [_subVersions objectForKey:sub];
                [versionArray addObject:version ? [NSString stringWithFormat:@"%@",
                                                                             version] : @"0"];
            }

            NSString *subs = [subArray componentsJoinedByString:@","];
            NSString *versions = [versionArray componentsJoinedByString:@","];
            ADD_TO_URL_REQUEST_ARRAY(@"subs", subs, urlRequestArray);
            ADD_TO_URL_REQUEST_ARRAY(@"v", versions, urlRequestArray);
        }


        NSString *urlRequestString = [urlRequestArray componentsJoinedByString:@"&"];
        url = [NSURL URLWithString:[_url stringByAppendingFormat:@"?%@",
                                                                 urlRequestString]];
    }
    if (url) {
        NSURLRequest *urlRequest = [[NSURLRequest alloc]
                                                  initWithURL:url
                                                  cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                              timeoutInterval:_timeOut];
        return urlRequest;
    }
    return nil;

}

- (void)setDataHandler:(TBRO_MPP_DATA_HANDLER)handler {
    _dataHandler = [handler copy];
}

- (void)addHandler:(TBRO_MPP_SUBTYPE_HANDLER)handler ForSubType:(int)subType {
    NSMutableSet *handlers = nil;
    if (!(handlers = [_subTypeHandlers objectForKey:[NSNumber numberWithInt:subType]])) {
        handlers = [[NSMutableSet alloc] initWithCapacity:1];
        [_subTypeHandlers setObject:handlers
                             forKey:[NSNumber numberWithInt:subType]];
    }
    [handlers addObject:[handler copy]];
}

- (void)setFailedHandler:(TBRO_MPP_FAILED_HANDLER)handler {
    _failedHandler = [handler copy];
}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
- (BOOL)start {
    [self stop];
    NSURLRequest *urlRequest = self.request;
    if (!urlRequest) {
        return NO;
    }
    _currentContext = [[RemoteContext alloc] init];
    _currentContext.info = urlRequest;
    [_currentContext addSuccessEventListener:^(SuccessRemoteEvent *event) {
        id dic = nil;
        if ([event.responseData length] == 0) {
            TBRO_LOG(@"Mpp return NULL");
        } else {
            dic = TBIUJSONDecode(event.responseData, nil);
        }
        if (dic && [dic respondsToSelector:@selector(toObjectWithClass:)]) {
            TBROMppReturnData *data = [dic toObjectWithClass:[TBROMppReturnData class]];
            if (_dataHandler)
                _dataHandler(self, data);
            if (data.type == TBRO_MPP_TYPE_QUIT) {
                [self stop];
                if (_failedHandler)
                    _failedHandler(self, TBRO_MPP_ERROR_TYPE_FAILED_LOGIN);
            } else if (data.type == TBRO_MPP_TYPE_TIMEOUT) {
                [self reStart];
            } else if (data.type == TBRO_MPP_TYPE_CLOSE) {
                [self stop];
                if (_failedHandler)
                    _failedHandler(self, TBRO_MPP_ERROR_TYPE_BE_CLOSED);
            } else if (data.type == TBRO_MPP_TYPE_CONTENT) {
                for (TBROMppReturnContent *content in data.st$TBROMppReturnContent) {
                    if (content.i && content.v) {
                        [self addSub:content.i
                         withVersion:content.v];
                    }
                    NSMutableSet *handlers = nil;
                    if ((handlers = [_subTypeHandlers objectForKey:[NSNumber numberWithInt:content.t2]])) {
                        for (TBRO_MPP_SUBTYPE_HANDLER handler in handlers) {
                            handler(self, content);
                        }
                    }
                }
                [self reStart];
            } else {
                [self stop];
                if (_failedHandler)
                    _failedHandler(self, TBRO_MPP_ERROR_TYPE_OTHER);
            }
        } else {
            [self stop];
            if (_failedHandler)
                _failedHandler(self, TBRO_MPP_ERROR_TYPE_NO_DATA);
        }
    }];
    [_currentContext addFailedEventListener:^(FailedRemoteEvent *event) {
        [self stop];
        if (_failedHandler)
            _failedHandler(self, TBRO_MPP_ERROR_TYPE_HTTP_FAILED);
    }];
    [[MppHandler instance] request:_currentContext];
    _isRunning = YES;
    return YES;
}
#pragma clang diagnostic pop

- (void)reStart {
    if (self.currentContext) {
        self.currentContext.info = [self request];
        [[MppHandler instance] request:self.currentContext];
    }
}

- (void)stop {
    if (_currentContext) {
        [[MppHandler instance] cancel:_currentContext];
    }
    _currentContext = nil;
    _isRunning = NO;
}

- (void)dealloc {
    _currentContext = nil;
    TBRO_LOG(@"%@ dealloc", self);
}
@end