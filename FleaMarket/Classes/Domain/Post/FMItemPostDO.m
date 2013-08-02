//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-11-6 上午10:48.
//


#import "FMItemPostDO.h"


@implementation FMItemPostDO {

@private
    long long int _orderId;
    BOOL _resell;
    BOOL _archive;
}

@synthesize itemId = _itemId;
@synthesize area = _area;
@synthesize city = _city;
@synthesize prov = _prov;
@synthesize gps = _gps;
@synthesize divisionId = _divisionId;
@synthesize offline = _offline;
@synthesize stuffStatus = _stuffStatus;
@synthesize categoryId = _categoryId;
@synthesize contacts = _contacts;
@synthesize description = _description;
@synthesize originalPrice = _originalPrice;
@synthesize phone = _phone;
@synthesize postPrice = _postPrice;
@synthesize reservePrice = _reservePrice;
@synthesize title = _title;
@synthesize mainPic = _mainPic;
@synthesize otherPics = _otherPics;
@synthesize orderId = _orderId;
@synthesize resell = _resell;
@synthesize archive = _archive;

- (id)init {
    self = [super init];
    if (self) {
        _mainPic = [[NSMutableArray alloc] initWithCapacity:1];
        _otherPics = [[NSMutableArray alloc] initWithCapacity:4];
    }

    return self;
}


@end