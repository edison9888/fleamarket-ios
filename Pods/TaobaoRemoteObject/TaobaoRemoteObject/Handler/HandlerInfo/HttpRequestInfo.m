//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-18 上午10:07.
//


#import "HttpRequestInfo.h"
#import "BaseHandler.h"
#import "HttpHandler.h"


@implementation HttpRequestInfo {

@private
    NSURLRequest *_request;
}
@synthesize request = _request;

- (id)initWithRequest:(NSURLRequest *)request {
    self = [super init];
    if (self) {
        self.request = request;
    }

    return self;
}

+ (id)infoWithRequest:(NSURLRequest *)request {
    return [[self alloc] initWithRequest:request];
}


- (BOOL)validate {
    return _request != nil;
}

- (BaseHandler *)requestHandler {
    return [HttpHandler instance];
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString string];
    [description appendFormat:@"self.request=%@",
                              self.request];

    NSMutableString *superDescription = [[super description] mutableCopy];
    NSUInteger length = [superDescription length];

    if (length > 0 && [superDescription characterAtIndex:length - 1] == '>') {
        [superDescription insertString:@", "
                               atIndex:length - 1];
        [superDescription insertString:description
                               atIndex:length + 1];
        return superDescription;
    }
    else {
        return [NSString stringWithFormat:@"<%@: %@>",
                                          NSStringFromClass([self class]),
                                          description];
    }
}


@end