//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-9-14 上午11:34.
//


#import "MtopInfo.h"
#import "TBRONSStringUtil.h"
#import "NSObject+TBIU_ToJson.h"
#import "BaseHandler.h"
#import "Mtop3Handler.h"


@implementation MtopInfo {

@private
    NSString *_api;
    NSString *_version;
    NSString *_sid;
    NSString *_token;
    NSString *_ecode;
    BOOL _needEcode;
    Class _returnClass;
}
@synthesize api = _api;
@synthesize version = _version;
@synthesize sid = _sid;
@synthesize token = _token;
@synthesize ecode = _ecode;
@synthesize needEcode = _needEcode;
@synthesize returnClass = _returnClass;


- (id)init {
    self = [super init];
    if (self) {
        _needEcode = NO;
    }
    return self;
}


- (id)initWithApi:(NSString *)api version:(NSString *)version {
    self = [super init];
    if (self) {
        _api = api;
        _version = version;
        _needEcode = NO;
    }
    return self;
}

+ (id)objectWithApi:(NSString *)api version:(NSString *)version {
    return [[MtopInfo alloc] initWithApi:api version:version];
}

- (NSString *)ecode {
    if (_needEcode) {
        return _ecode ? _ecode : @"";
    }
    return nil;
}


- (BOOL)validate {
    return !([TBRONSStringUtil isBlank:_api] || [TBRONSStringUtil isBlank:_version]);
}

- (NSString *)description {
    return [self toJSONString];
}

- (BaseHandler *)requestHandler {
    return [Mtop3Handler instance];
}


@end