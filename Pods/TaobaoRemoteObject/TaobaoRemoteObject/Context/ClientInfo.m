//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-8-26 下午6:58.
//


#import <UIKit/UIKit.h>
#import "ClientInfo.h"
#import "UIDevice+TBHelper.h"
#import "NSObject+TBIU_ToJson.h"
#import "TBROSync.h"

@implementation ClientInfo {

@private
    NSString *_ip;
    NSString *_ttid;
    NSString *_imei;
    NSString *_imsi;
    NSDate *_time;
    NSString *_lat;
    NSString *_lng;
    NSString *_deviceId;
}
@synthesize ip = _ip;
@synthesize ttid = _ttid;
@synthesize imei = _imei;
@synthesize imsi = _imsi;

@synthesize lat = _lat;
@synthesize lng = _lng;

@synthesize deviceId = _deviceId;

+ (ClientInfo *)instance {
    static ClientInfo *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }
    return _instance;
}

- (id)init {
    self = [super init];
    if (self) {
        _imei = [[UIDevice currentDevice] getUniqueGlobalDeviceIdentifier] ? : @"1234567890";
        _imsi = [[UIDevice currentDevice] getUniqueGlobalDeviceIdentifier] ? : @"1234567890";
    }

    return self;
}


- (NSDate *)time {
    if (_time == nil) {
        _time = [[TBROSync instance] getDate];
    }
    return _time;
}

- (void)setTime:(NSDate *)time {
    _time = time;
}


- (void)resetTime {
    _time = [NSDate date];
}


- (NSString *)timeForString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [formatter stringFromDate:[self time]];
}

- (NSString *)timeForStringWithFormat:(NSString *)format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:format];
    return [formatter stringFromDate:[self time]];
}

- (id)copyWithZone:(NSZone *)zone {
    ClientInfo *info = [[ClientInfo alloc] init];
    info.imei = self.imei;
    info.imsi = self.imsi;
    info.ttid = self.ttid;
    info.ip = self.ip;
    info.lat = self.lat;
    info.lng = self.lng;
    info.deviceId = self.deviceId;
    return info;
}

- (NSString *)description {
    return [self toJSONString];
}


@end