//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-9-12 上午11:47.
//


#import <Foundation/Foundation.h>
#import "Verifiable.h"
#import "TBROCachedInfo.h"


@interface ClientApiInfo : TBROCachedInfo <Verifiable, TBROHasHandler>

@property(copy, nonatomic) NSString *host;
@property(copy, nonatomic) NSString *api;
@property(copy, nonatomic) NSString *version;
@property(copy, nonatomic) NSString *signKey;
@property(copy, nonatomic) NSString *sid;
@property(copy, nonatomic) NSString *token;
@property(copy, nonatomic) NSString *forceHttpHeadHost;
@property(assign, nonatomic) BOOL forcePost;
@property(nonatomic) Class returnClass;
@property(copy, nonatomic) NSString *fields;

@property BOOL needDebugInfo;
@property BOOL needSignWithIp;

- (id)initWithHost:(NSString *)host api:(NSString *)api version:(NSString *)version;

+ (id)objectWithHost:(NSString *)host api:(NSString *)api version:(NSString *)version;


@end