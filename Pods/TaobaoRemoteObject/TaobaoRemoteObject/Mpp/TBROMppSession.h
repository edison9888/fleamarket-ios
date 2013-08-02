//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-12-11 下午3:50.
//


#import <Foundation/Foundation.h>

@class TBROMppReturnData;

typedef enum {
    TBRO_MPP_ERROR_TYPE_FAILED_LOGIN, //有相同的dt进行连接被强制退出
    TBRO_MPP_ERROR_TYPE_HTTP_FAILED, //request导致的错误比如 http的超时
    TBRO_MPP_ERROR_TYPE_NO_DATA,   //没法解析数据
    TBRO_MPP_ERROR_TYPE_BE_CLOSED,  //url拼的不对
    TBRO_MPP_ERROR_TYPE_OTHER   //未知错误
} TBROMppErrorType;

@class TBROMppReturnContent;
@class TBROMppReturnData;
@class TBROMppSession;

typedef void (^TBRO_MPP_DATA_HANDLER)(TBROMppSession *, TBROMppReturnData *);

typedef void (^TBRO_MPP_SUBTYPE_HANDLER)(TBROMppSession *, TBROMppReturnContent *);

typedef void (^TBRO_MPP_FAILED_HANDLER)(TBROMppSession *, TBROMppErrorType);

@interface TBROMppSession : NSObject

@property(nonatomic, readonly) BOOL isRunning;

@property(nonatomic, copy) NSString *url;

@property(nonatomic, copy) NSString *appId;  //app id

@property(nonatomic, copy) NSString *dt; //deviceToken

@property(nonatomic, copy) NSString *uid;  //userID 数字id

@property(nonatomic, copy) NSString *sid;  //session id

@property(nonatomic, assign) NSTimeInterval timeOut;  //超时时间 (秒)

- (NSDictionary *)subsWithVersion;

//所有的add操作都会覆盖掉原来的已有的值,主要是version
- (void)addSub:(NSString *)sub; //新加自定义id

- (void)addSub:(NSString *)sub withVersion:(long long)version; //新加自定义id

- (void)addSubs:(NSArray *)subs; //新加很多自定义id

- (void)replaceSubs:(NSArray *)subs; //替换自定义id,就是sub已存在的不会丢数据,不存在的没有

- (void)removeSub:(NSString *)sub;  //移除自定义id

- (void)removeSubs:(NSArray *)subs;   //移除自定义id

- (void)removeAllSubs;   //移除自定义id

//全局的Handler 有返回必调用
- (void)setDataHandler:(TBRO_MPP_DATA_HANDLER)handler;

//每个subType各自的Handler
- (void)addHandler:(TBRO_MPP_SUBTYPE_HANDLER)handler ForSubType:(int)subType;

//有错误时的回调
- (void)setFailedHandler:(TBRO_MPP_FAILED_HANDLER)handler;

- (BOOL)start;

- (void)stop;
@end