//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-9-14 上午11:23.
//


#import <Foundation/Foundation.h>
#import "HttpHandler.h"
#import "Environment.h"


@interface Mtop3Handler : HttpHandler <RemoteHandlerProtocol>

@property(assign, nonatomic) TaoBaoEnvironment env;
@property(readonly, nonatomic) NSString *host;
@property(copy, nonatomic) NSString *customHost;
@property(copy, nonatomic) NSString *appKey;
@property(copy, nonatomic) NSString *appSecretKey;
@property(copy, nonatomic) NSString *sid;

+ (Mtop3Handler *)instance;

@end