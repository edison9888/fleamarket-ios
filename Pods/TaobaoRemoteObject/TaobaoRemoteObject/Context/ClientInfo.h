//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-8-26 下午6:58.
//


#import <Foundation/Foundation.h>


@interface ClientInfo : NSObject <NSCopying>
/*!*本机的外网ip ,可通过接口获取*/
@property(copy, nonatomic) NSString *ip;
@property(copy, nonatomic) NSString *ttid;
@property(copy, nonatomic) NSString *imei;
@property(copy, nonatomic) NSString *imsi;
//维度
@property(copy, nonatomic) NSString *lat;
//经度
@property(copy, nonatomic) NSString *lng;
@property(copy, nonatomic) NSString *deviceId;

+ (ClientInfo *)instance;

- (NSDate *)time;

- (void)setTime:(NSDate *)time;

- (void)resetTime;

- (NSString *)timeForString;

- (NSString *)timeForStringWithFormat:(NSString *)format;
@end