//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-18 上午10:05.
//


#import "TBROCachedInfo.h"


@implementation TBROCachedInfo {

@private
    NSTimeInterval _cacheTime;
}
@synthesize cacheTime = _cacheTime;

- (id)init {
    self = [super init];
    if (self) {
        _cacheTime = 0.0;
    }

    return self;
}


- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ",
                                                                     NSStringFromClass([self class])];
    [description appendFormat:@"self.cacheTime=%f",
                              self.cacheTime];
    [description appendString:@">"];
    return description;
}


@end