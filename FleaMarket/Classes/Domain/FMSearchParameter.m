//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-12-13 下午3:38.
//


#import "FMSearchParameter.h"
#import "FMCategory.h"
#import "TBMBBind.h"
#import "NSString+Helper.h"
#import "NSObject+TBIU_ToJson.h"

@implementation FMSearchParameter {
@private
    NSUInteger __filterChange;
    NSString *_themeId;
    NSString *_sellerNick;
}
@synthesize pageNumber = _pageNumber;
@synthesize rowsPerPage = _rowsPerPage;
@synthesize endPrice = _endPrice;
@synthesize startPrice = _startPrice;
@synthesize province = _province;
@synthesize city = _city;
@synthesize area = _area;
@synthesize sortField = _sortField;
@synthesize sortValue = _sortValue;
@synthesize keyword = _keyword;
@synthesize lat = _lat;
@synthesize lng = _lng;
@synthesize range = _range;
@synthesize front = _front;
@synthesize home = _home;
@synthesize inMap = _inMap;
@synthesize _category$FMCategory = __category$FMCategory;
@synthesize _stuffStatus = __stuffStatus;
@synthesize _locationID = __locationID;
@synthesize _filterChange = __filterChange;
@synthesize _offline = __offline;
@synthesize themeId = _themeId;
@synthesize sellerNick = _sellerNick;

- (id)init {
    self = [super init];
    if (self) {
        __stuffStatus = FMSearchConditionStuffStatusNoLimit;
        _pageNumber = 1;
        _rowsPerPage = 20;
        _range = [NSNumber numberWithLongLong:50000000000L];
        __locationID = -1;
        _front = [NSNumber numberWithBool:YES];
        __offline = FMSearchConditionTradeTypeAnyway;

        TBMBBindObjectWeak(tbKeyPath(self, categoryId), self, ^(FMSearchParameter *host, id old, id new) {
            host._filterChange++;
        }
        );
        TBMBBindObjectWeak(tbKeyPath(self, startPrice), self, ^(FMSearchParameter *host, id old, id new) {
            host._filterChange++;
        }
        );
        TBMBBindObjectWeak(tbKeyPath(self, endPrice), self, ^(FMSearchParameter *host, id old, id new) {
            host._filterChange++;
        }
        );
        TBMBBindObjectWeak(tbKeyPath(self, stuffStatus), self, ^(FMSearchParameter *host, id old, id new) {
            host._filterChange++;
        }
        );
        TBMBBindObjectWeak(tbKeyPath(self, offline), self, ^(FMSearchParameter *host, id old, id new) {
            host._filterChange++;
        }
        );
        TBMBBindObjectWeak(tbKeyPath(self, city), self, ^(FMSearchParameter *host, id old, id new) {
            host._filterChange++;
        }
        );
        TBMBBindObjectWeak(tbKeyPath(self, area), self, ^(FMSearchParameter *host, id old, id new) {
            host._filterChange++;
        }
        );
        TBMBBindObjectWeak(tbKeyPath(self, _locationID), self, ^(FMSearchParameter *host, id old, id new) {
            host._filterChange++;
        }
        );
    }

    return self;
}

- (NSNumber *)categoryId {
    if (__category$FMCategory && __category$FMCategory.count > 0) {
        FMCategory *category = [__category$FMCategory lastObject];
        if (![category.id isBlank])
            return [[[NSNumberFormatter alloc] init] numberFromString:category.id];
    }
    return nil;
}

- (NSNumber *)stuffStatus {
    if (__stuffStatus != FMSearchConditionStuffStatusNoLimit) {
        return [NSNumber numberWithInteger:__stuffStatus];
    } else {
        return nil;
    }
}

- (NSNumber *)offline {
    return [NSNumber numberWithInteger:__offline];
}

- (NSNumber *)range {
    return _range;
}

- (void)setSortType:(FMSearchConditionSortType)_sortType {
    switch (_sortType) {
        case FMSearchConditionSortTime:
            _sortField = @"time";
            _sortValue = @"desc";
            break;
        case FMSearchConditionSortDistance:
            _sortField = @"pos";
            _sortValue = @"asc";
            break;
        case FMSearchConditionSortPriceUp:
            _sortField = @"price";
            _sortValue = @"asc";
            break;
        case FMSearchConditionSortPriceDown:
            _sortField = @"price";
            _sortValue = @"desc";
            break;
        case FMSearchConditionSortDefault:
            _sortField = @"";
            _sortValue = @"";
            break;
        default:
            break;
    }
}

- (FMSearchConditionSortType)sortType {
    if ([_sortField isEqualToString:@"time"] && [_sortValue isEqualToString:@"desc"]) {
        return FMSearchConditionSortTime;
    }

    if ([_sortField isEqualToString:@"pos"] && [_sortValue isEqualToString:@"asc"]) {
        return FMSearchConditionSortDistance;
    }

    if ([_sortField isEqualToString:@"price"] && [_sortValue isEqualToString:@"asc"]) {
        return FMSearchConditionSortPriceUp;
    }

    if ([_sortField isEqualToString:@"price"] && [_sortValue isEqualToString:@"desc"]) {
        return FMSearchConditionSortPriceDown;
    }

    return FMSearchConditionSortDefault;
}

- (BOOL)hasFilter {
    return self.categoryId ||      //类目
            __stuffStatus != FMSearchConditionStuffStatusNoLimit ||       //新旧
            [self.offline integerValue] < 2 ||           //交易方式
            _endPrice || _startPrice ||   //价格
            ![_province isBlank] || ![_city isBlank]
            || ![_area isBlank] || __locationID > 0;  //城市
}

- (NSString *)getStatusString {
    NSString *string = nil;
    switch (__stuffStatus) {
        case FMSearchConditionStuffStatusNoLimit:
            string = @"不限";
            break;
        case FMSearchConditionStuffStatusAllOld:
            string = @"非全新";
            break;
        case FMSearchConditionStuffStatusAllNew:
            string = @"全新";
            break;
        default:
            string = @"不限";
            break;
    }
    return string;
}

- (NSString *)getTradeTypeString {
    NSString *string = nil;
    switch (__offline) {
        case FMSearchConditionTradeTypeAnyway:
            string = @"不限";
            break;
        case FMSearchConditionTradeTypeF2F:
            string = @"见面";
            break;
        case FMSearchConditionTradeTypeOnline:
            string = @"线上";
            break;
        default:
            string = @"不限";
            break;
    }
    return string;
}

- (NSString *)description {
    return [self toJSONString];
}

- (void)fromAnotherParameter:(FMSearchParameter *)parameter {
    self.endPrice = parameter.endPrice;
    self.pageNumber = parameter.pageNumber;
    self.rowsPerPage = parameter.rowsPerPage;
    self.startPrice = parameter.startPrice;
    self.province = parameter.province;
    self.city = parameter.city;
    self.area = parameter.area;
    self.keyword = parameter.keyword;
//    self.lat = parameter.lat;
//    self.lng = parameter.lng;
    self.range = parameter.range;
    self.front = parameter.front;
    self.home = parameter.home;
    self.inMap = parameter.inMap;
    self._category$FMCategory = parameter._category$FMCategory;
    self._stuffStatus = parameter._stuffStatus;
    self._offline = parameter._offline;
    self._locationID = parameter._locationID;
    self._filterChange++;

    self.themeId = parameter.themeId;
    self.sellerNick = parameter.sellerNick;
}

- (id)copyWithZone:(NSZone *)zone {
    FMSearchParameter *clone = [[FMSearchParameter allocWithZone:zone] init];
    clone->_endPrice = _endPrice;
    clone->_pageNumber = _pageNumber;
    clone->_rowsPerPage = _rowsPerPage;
    clone->_startPrice = _startPrice;
    clone->_province = _province;
    clone->_city = _city;
    clone->_area = _area;
    clone->_sortField = _sortField;
    clone->_sortValue = _sortValue;
    clone->_keyword = _keyword;
//    clone->_lat = _lat;
//    clone->_lng = _lng;
    clone->_range = _range;
    clone->_front = _front;
    clone->_home = _home;
    clone->_inMap = _inMap;
    clone->__category$FMCategory = __category$FMCategory;
    clone->__stuffStatus = __stuffStatus;
    clone->__offline = __offline;
    clone->__locationID = __locationID;

    clone->_themeId = _themeId;
    clone->_sellerNick = _sellerNick;
    return clone;
}

- (void)dealloc {
    FMLOG(@"<FMSearchParameter> dealloc");
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self._filterChange = (NSUInteger) [coder decodeIntForKey:@"self._filterChange"];
        self.pageNumber = (NSUInteger) [coder decodeIntForKey:@"self.pageNumber"];
        self.rowsPerPage = (NSUInteger) [coder decodeIntForKey:@"self.rowsPerPage"];
        self.endPrice = [coder decodeObjectForKey:@"self.endPrice"];
        self.startPrice = [coder decodeObjectForKey:@"self.startPrice"];
        self.province = [coder decodeObjectForKey:@"self.province"];
        self.city = [coder decodeObjectForKey:@"self.city"];
        self.area = [coder decodeObjectForKey:@"self.area"];
        _sortField = [coder decodeObjectForKey:@"_sortField"];
        _sortValue = [coder decodeObjectForKey:@"_sortValue"];
        self.keyword = [coder decodeObjectForKey:@"self.keyword"];
//        self.lat = [coder decodeObjectForKey:@"self.lat"];
//        self.lng = [coder decodeObjectForKey:@"self.lng"];
        self.range = [coder decodeObjectForKey:@"self.range"];
        self.front = [coder decodeObjectForKey:@"self.front"];
        self.home = [coder decodeObjectForKey:@"self.home"];
        self.inMap = [coder decodeObjectForKey:@"self.inMap"];
        self._category$FMCategory = [coder decodeObjectForKey:@"self._category$FMCategory"];
        self._stuffStatus = (FMSearchConditionStuffStatus) [coder decodeIntForKey:@"self._stuffStatus"];
        self._locationID = [coder decodeIntForKey:@"self._locationID"];
        self._offline = (FMSearchConditionTradeType) [coder decodeIntForKey:@"self._offline"];

        self.themeId = [coder decodeObjectForKey:@"self.themeId"];
        self.sellerNick = [coder decodeObjectForKey:@"self.sellerNick"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:self._filterChange forKey:@"self._filterChange"];
    [coder encodeInt:self.pageNumber forKey:@"self.pageNumber"];
    [coder encodeInt:self.rowsPerPage forKey:@"self.rowsPerPage"];
    [coder encodeObject:self.endPrice forKey:@"self.endPrice"];
    [coder encodeObject:self.startPrice forKey:@"self.startPrice"];
    [coder encodeObject:self.province forKey:@"self.province"];
    [coder encodeObject:self.city forKey:@"self.city"];
    [coder encodeObject:self.area forKey:@"self.area"];
    [coder encodeObject:self.sortField forKey:@"_sortField"];
    [coder encodeObject:self.sortValue forKey:@"_sortValue"];
    [coder encodeObject:self.keyword forKey:@"self.keyword"];
//    [coder encodeObject:self.lat forKey:@"self.lat"];
//    [coder encodeObject:self.lng forKey:@"self.lng"];
    [coder encodeObject:self.range forKey:@"self.range"];
    [coder encodeObject:self.front forKey:@"self.front"];
    [coder encodeObject:self.home forKey:@"self.home"];
    [coder encodeObject:self.inMap forKey:@"self.inMap"];
    [coder encodeObject:self._category$FMCategory forKey:@"self._category$FMCategory"];
    [coder encodeInt:self._stuffStatus forKey:@"self._stuffStatus"];
    [coder encodeInt:self._locationID forKey:@"self._locationID"];
    [coder encodeInt:self._offline forKey:@"self._offline"];

    [coder encodeObject:self.themeId forKey:@"self.themeId"];
    [coder encodeObject:self.sellerNick forKey:@"self.sellerNick"];
}

@end