//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-8-26 下午5:16.
//


#import <Foundation/Foundation.h>
#import "EventDefine.h"
#import "ClientInfo.h"
#import "Verifiable.h"
#import "TBROCommon.h"

@protocol RemoteHandlerProtocol;

@interface RemoteContext : NSObject

@property(retain, nonatomic) id info;
@property(retain, nonatomic) id parameter;
@property(readonly, nonatomic) NSMutableDictionary *extra;
@property(readonly, nonatomic) NSMutableDictionary *userInfo;
@property(copy, nonatomic) ClientInfo *clientInfo;
@property(readonly, nonatomic) NSArray *errorMessage;
/*! 用于存 内部流转需要的对象*/
@property(retain, nonatomic) id internal;
/*! 用于Cancel 没有没法cancel*/
@property(TBROPropertyWeak, atomic) id internalOperation;
@property(retain, nonatomic) id <RemoteHandlerProtocol> internalHandler;
/*! 用于放入 映射表 用于以后 cancel 用*/
@property(retain, nonatomic) id key;

/*!
添加相同的RemoteEventType 后面的会覆盖前面的
 */
- (void)addEventListener:(EventListener)eventListener forType:(RemoteEventType)eventType;

- (void)addSuccessEventListener:(SuccessEventListener)eventListener;

- (void)addFailedEventListener:(FailedEventListener)eventListener;

- (void)addProgressEventListener:(ProgressEventListener)eventListener;

- (void)addCancelEventListener:(CancelEventListener)eventListener;

- (BOOL)hasEventListenerByType:(RemoteEventType)eventType;

- (EventListener)getEventListenerByType:(RemoteEventType)eventType;

- (BOOL)hasError;

- (void)addErrorMessage:(NSString *)error;

- (void)addNSError:(NSError *)error;

- (void)request;
@end