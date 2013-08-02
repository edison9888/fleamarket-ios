//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-12 下午3:33.
//


#import <Foundation/Foundation.h>


@interface FMLocation : NSObject
@property(atomic, copy) NSString *lat;
@property(atomic, copy) NSString *lng;
@property(atomic, copy) NSString *province;
@property(atomic, copy) NSString *city;
@property(atomic, copy) NSString *area;
@property(atomic, copy) NSNumber *locationId;
@end