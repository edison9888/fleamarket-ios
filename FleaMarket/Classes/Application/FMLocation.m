//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-12 下午3:33.
//


#import "FMLocation.h"
#import "TBMBUtil.h"
#import "TBMBBind.h"
#import "ClientInfo.h"


@implementation FMLocation {

@private
    NSString *_lat;
    NSString *_lng;

    NSString *_province;
    NSString *_city;
    NSString *_area;
    NSNumber *_locationId;
}

@synthesize lat = _lat;
@synthesize lng = _lng;

@synthesize province = _province;
@synthesize city = _city;
@synthesize area = _area;
@synthesize locationId = _locationId;

- (id)init {
    self = [super init];
    if (self) {
        TBMBAutoBindingKeyPath(self);
    }
    return self;
}


TBMBWhenThisKeyPathChange(lat){
    if (!isInit) {
        [ClientInfo instance].lat = new;
    }
}

TBMBWhenThisKeyPathChange(lng){
    if (!isInit) {
        [ClientInfo instance].lng = new;
    }
}


@end