//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-9-14 上午11:34.
//


#import <Foundation/Foundation.h>
#import "Verifiable.h"
#import "TBROCachedInfo.h"


@interface MtopInfo : TBROCachedInfo <Verifiable, TBROHasHandler>
@property(copy, nonatomic) NSString *api;
@property(copy, nonatomic) NSString *version;
@property(copy, nonatomic) NSString *sid;
@property(copy, nonatomic) NSString *token;
@property(copy, nonatomic) NSString *ecode;
@property(assign, nonatomic) BOOL needEcode;
@property(nonatomic) Class returnClass;

- (id)initWithApi:(NSString *)api version:(NSString *)version;

+ (id)objectWithApi:(NSString *)api version:(NSString *)version;

@end