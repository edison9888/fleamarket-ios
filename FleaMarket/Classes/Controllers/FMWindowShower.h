//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-7-21 上午10:26.
//


#import <Foundation/Foundation.h>

@class RemoteContext;

@interface FMWindowShower : NSObject
+ (FMWindowShower *)instance;

- (void)gotoDetailWithId:(NSString *)itemId;

- (void)gotoSearch:(NSDictionary *)parameter;

- (void)goToMessageView:(BOOL)loginDone withKey:(NSString *)key;

- (void)retryLoginAndRequest:(RemoteContext *)context;

- (id)proxyObject;
@end