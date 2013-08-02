//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-2-20 上午9:11.
//


#import <UIKit/UIKit.h>
#import "TBROSync.h"
#import "TBRONSStringUtil.h"
#import "ClientApiInfo.h"
#import "RemoteContext.h"
#import "ClientApiBaseReturn.h"
#import "RemoteEvent.h"
#import "ClientApiHandler.h"


@interface TBROSyncDO : NSObject
@property(nonatomic, strong) NSString *clientIp;
@property(nonatomic, assign) NSTimeInterval delay; //毫秒
@end

@implementation TBROSyncDO {
@private
    NSString *_clientIp;
    NSTimeInterval _delay;
}

@synthesize clientIp = _clientIp;
@synthesize delay = _delay;


@end

@interface TBROSync ()
@property(strong) TBROSyncDO *syncDO;
@end


@implementation TBROSync {
@private
    NSString *_host;
    NSString *_api;
    NSString *_version;

    TBROSyncDO *_syncDO;

}
@synthesize syncDO = _syncDO;

+ (TBROSync *)instance {
    static TBROSync *_instance = nil;
    static dispatch_once_t _oncePredicate_TBROSync;

    dispatch_once(&_oncePredicate_TBROSync, ^{
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }
    );

    return _instance;
}

- (void)startWithHost:(NSString *)host
                  api:(NSString *)api
              version:(NSString *)version
        needSyncFirst:(BOOL)needSyncFirst {
    _host = host;
    _api = api;
    _version = version;

    if ([TBRONSStringUtil isNotBlank:_host] && [TBRONSStringUtil isNotBlank:_api] && [TBRONSStringUtil isNotBlank:_version]) {
        if (needSyncFirst)
            [self getSyncData];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(getSyncData)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
    }

}

- (void)getSyncData {
    ClientApiInfo *info = [ClientApiInfo objectWithHost:_host
                                                    api:_api
                                                version:_version];
    info.returnClass = [TBROSyncDO class];
    RemoteContext *context = [[RemoteContext alloc] init];
    context.info = info;
    [context.clientInfo resetTime];
    [context.userInfo setObject:[NSDate date]
                         forKey:@"startTime"];
    [context addSuccessEventListener:^(SuccessRemoteEvent *event) {
        ClientApiBaseReturn *clientApiBaseReturn = (ClientApiBaseReturn *) event.responseData;
        if (clientApiBaseReturn.ret == TBRO_CLIENT_OK) {
            NSTimeInterval netDelay = 0;
            NSDate *startTime = [event.context.userInfo objectForKey:@"startTime"];
            if (startTime) {
                netDelay = ([startTime timeIntervalSinceNow] / 2) * 1000;  //ms
            }
            TBROSyncDO *syncDO = clientApiBaseReturn.data;
            syncDO.delay = syncDO.delay + netDelay;
            self.syncDO = syncDO;
        }
    }];
    [[ClientApiHandler instance] request:context];
}

- (void)reSync {
    if ([TBRONSStringUtil isNotBlank:_host] && [TBRONSStringUtil isNotBlank:_api] && [TBRONSStringUtil isNotBlank:_version]) {
        [self getSyncData];
    }
}

- (NSString *)getPublicIp {
    return self.syncDO.clientIp;
}

- (NSDate *)getDate {
    return [NSDate dateWithTimeInterval:(self.syncDO.delay / 1000)
                              sinceDate:[NSDate date]];
}


@end