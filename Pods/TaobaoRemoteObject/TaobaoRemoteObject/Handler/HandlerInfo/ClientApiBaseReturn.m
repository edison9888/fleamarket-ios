//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-9-14 上午10:09.
//


#import "ClientApiBaseReturn.h"
#import "NSObject+TBIU_ToJson.h"


@implementation ClientApiBaseReturn {

@private
    NSString *_api;
    NSString *_desc;
    NSInteger _ret;
    NSString *_debug;
    id _data;
    NSString *_v;
    NSString *_msg;
}
@synthesize api = _api;
@synthesize desc = _desc;
@synthesize ret = _ret;
@synthesize debug = _debug;
@synthesize data = _data;
@synthesize v = _v;
@synthesize msg = _msg;

- (id)init {
    self = [super init];
    if (self) {
        _msg = @"";
        _desc = @"";
    }

    return self;
}


- (NSString *)description {
    return [self toJSONString];
}


@end