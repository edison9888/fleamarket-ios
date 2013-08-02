//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-12-11 下午5:04.
//


#import "TBROMppReturnData.h"
#import "NSObject+TBIU_ToJson.h"
#import "NSDictionary+TBIU_ToObject.h"

@implementation TBROMppReturnContent {
@private
    id _content;
    long long _v;
    int _t1;
    int _t2;
    NSString *_i;
    long long _o;
}

@synthesize content = _content;
@synthesize v = _v;
@synthesize t1 = _t1;
@synthesize t2 = _t2;
@synthesize i = _i;
@synthesize o = _o;


- (NSString *)description {
    return [self toJSONString];
}

- (id)getContentByClass:(Class)clazz {
    if (_content && [_content isKindOfClass:[NSDictionary class]]) {
        return [_content toObjectWithClass:clazz];
    }
    return _content;
}

@end

@implementation TBROMppReturnData {

@private
    NSArray *_st$TBROMppReturnContent;
    TBROMppType _type;
}
@synthesize st$TBROMppReturnContent = _st$TBROMppReturnContent;
@synthesize type = _type;

- (NSString *)description {
    return [self toJSONString];
}
@end