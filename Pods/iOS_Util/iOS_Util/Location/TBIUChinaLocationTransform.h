//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-16 上午9:14.
//


#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

extern inline CLLocationCoordinate2D transformChinaLocation(CLLocationCoordinate2D coordinate2D);

extern inline void transformChinaLocationNoCopy(CLLocationCoordinate2D *coordinate2D);
