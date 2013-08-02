//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-9-12 上午11:47.
//


#import "ClientApiInfo.h"
#import "TBRONSStringUtil.h"
#import "NSObject+TBIU_ToJson.h"
#import "BaseHandler.h"
#import "ClientApiHandler.h"


@implementation ClientApiInfo {
@private
    NSString *_host;
    NSString *_api;
    NSString *_version;
    BOOL _needDebugInfo;
    BOOL _needSignWithIp;
    Class _returnClass;
    NSString *_sid;
    NSString *_token;
    NSString *_signKey;
    NSString *_forceHttpHeadHost;
    BOOL _forcePost;
    NSString *_fields;
}
@synthesize host = _host;
@synthesize api = _api;
@synthesize version = _version;
@synthesize needDebugInfo = _needDebugInfo;
@synthesize needSignWithIp = _needSignWithIp;
@synthesize returnClass = _returnClass;
@synthesize sid = _sid;
@synthesize token = _token;
@synthesize signKey = _signKey;
@synthesize forceHttpHeadHost = _forceHttpHeadHost;


@synthesize forcePost = _forcePost;

@synthesize fields = _fields;

- (id)initWithHost:(NSString *)host api:(NSString *)api version:(NSString *)version {
    self = [super init];
    if (self) {
        _host = host;
        _api = api;
        _version = version;
        _forcePost = NO;
    }

    return self;
}

+ (id)objectWithHost:(NSString *)host api:(NSString *)api version:(NSString *)version {
    return [[ClientApiInfo alloc] initWithHost:host api:api version:version];
}

- (BOOL)validate {
    return !([TBRONSStringUtil isBlank:_host] || [TBRONSStringUtil isBlank:_api] || [TBRONSStringUtil isBlank:_version]);
}

- (NSString *)description {
    return [self toJSONString];
}

- (BaseHandler *)requestHandler {
    return [ClientApiHandler instance];
}


@end