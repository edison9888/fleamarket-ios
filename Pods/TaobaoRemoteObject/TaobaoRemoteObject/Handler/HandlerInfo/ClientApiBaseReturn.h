//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-9-14 上午10:09.
//


#import <Foundation/Foundation.h>

typedef enum {
    TBRO_CLIENT_OK = 200,
    TBRO_CLIENT_BAD_REQUEST = 400,
    TBRO_CLIENT_UNAUTHORIZED = 401,
    TBRO_CLIENT_FORBIDDEN = 403,
    TBRO_CLIENT_REQUEST_TIMEOUT = 408,
    TBRO_CLIENT_NOT_FOUND = 404,
    TBRO_CLIENT_SERVER_ERROR = 500
} TBRO_CLIENT_RET_CODE;


@interface ClientApiBaseReturn : NSObject
@property(copy, nonatomic) NSString *api;
@property(copy, nonatomic) NSString *v;
@property(copy, nonatomic) NSString *desc;
@property(copy, nonatomic) NSString *msg;
@property(assign, nonatomic) NSInteger ret;
@property(copy, nonatomic) NSString *debug;
@property(strong, nonatomic) id data;
@end