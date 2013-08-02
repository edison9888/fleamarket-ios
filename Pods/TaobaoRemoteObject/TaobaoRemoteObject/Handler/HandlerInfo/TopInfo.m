//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-9-14 下午3:58.
//


#import "TopInfo.h"
#import "TBRONSStringUtil.h"
#import "NSObject+TBIU_ToJson.h"
#import "BaseHandler.h"
#import "TopHandler.h"


@implementation TopInfo {

@private
    NSString *_method;
    NSMutableArray *_fields;
    NSString *_version;
    NSString *_topSession;
    Class _returnClass;
}
@synthesize method = _method;
@synthesize version = _version;
@synthesize topSession = _topSession;
@synthesize returnClass = _returnClass;


- (NSString *)fields {
    return _fields ? [_fields componentsJoinedByString:@","] : @"";
}


- (id)initWithMethod:(NSString *)method version:(NSString *)version {
    self = [super init];
    if (self) {
        _method = method;
        _version = version;
    }

    return self;
}

+ (id)objectWithMethod:(NSString *)method version:(NSString *)version {
    return [[TopInfo alloc] initWithMethod:method version:version];
}

- (void)addField:(NSString *)field {
    if (_fields == nil) {
        _fields = [[NSMutableArray alloc] initWithCapacity:5];
    }
    [_fields addObject:field];
}

- (void)addFields:(NSString *)fields {
    for (NSString *field in [fields componentsSeparatedByString:@","]) {
        [self addField:field];
    }
}

- (void)addFieldArray:(NSArray *)fields {
    if (_fields == nil) {
        _fields = [NSMutableArray arrayWithArray:fields];
    } else {
        [_fields addObjectsFromArray:fields];
    }
}


- (BOOL)validate {
    return !([TBRONSStringUtil isBlank:_method] || [TBRONSStringUtil isBlank:_version]);
}

- (NSString *)description {
    return [self toJSONString];
}

- (BaseHandler *)requestHandler {
    return [TopHandler instance];
}


@end