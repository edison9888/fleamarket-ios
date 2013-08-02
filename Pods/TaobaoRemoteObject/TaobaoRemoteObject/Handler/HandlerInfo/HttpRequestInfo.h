//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-18 上午10:07.
//


#import <Foundation/Foundation.h>
#import "TBROCachedInfo.h"
#import "Verifiable.h"


@interface HttpRequestInfo : TBROCachedInfo <Verifiable, TBROHasHandler>
@property(nonatomic, strong) NSURLRequest *request;

- (id)initWithRequest:(NSURLRequest *)request;

- (NSString *)description;

+ (id)infoWithRequest:(NSURLRequest *)request;

@end