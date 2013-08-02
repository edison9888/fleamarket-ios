//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-8-27 下午4:57.
//


#import <Foundation/Foundation.h>
#import "HandlerDefine.h"
#import "BaseHandler.h"
#import "HttpHandler.h"


@interface ClientApiHandler : HttpHandler <RemoteHandlerProtocol>
@property(copy, nonatomic) NSString *signKey;
@property(assign, nonatomic) BOOL needDebugInfo;
@property(copy, nonatomic) NSString *forceHttpHeadHost;
@property(copy, nonatomic) NSString *sid;

+ (ClientApiHandler *)instance;

@end