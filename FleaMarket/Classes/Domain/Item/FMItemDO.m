// 
// Created by henson on 6/13/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import "FMItemDO.h"
#import "NSString+Helper.h"
#import "FMItemCommentDO.h"
#import "FMTaoBaoTrade.h"

@implementation FMItemDOList {

@private
    NSMutableArray *_items;
    NSString *_serverTime;
    BOOL _nextPage;
    NSNumber *_totalCount;
}

@synthesize items = _items;
@synthesize serverTime = _serverTime;
@synthesize nextPage = _nextPage;
@synthesize totalCount = _totalCount;

- (id)init {
    self = [super init];
    if (self) {
        _items = [NSMutableArray arrayWithCapacity:1];
    }

    return self;
}


@end

@implementation FMItemDetailResellDO {

}
@end

@implementation FMItemDetailResponseDO {

}
@end

@implementation FMItemDO {

@private
    NSString *_collectNum;
    NSString *_commentNum;
    NSString *_originalPrice;
    NSString *_price;
    NSString *_province;
    NSString *_city;
    NSString *_area;
    NSString *_userId;
    NSString *_userNick;
    NSString *_voiceUrl;
    NSString *_title;
    NSString *_descUrl;
    NSString *_description;
    NSString *_descriptionInfo;
    NSArray *_imageUrls;
    NSString *_from;
    NSString *_detailFrom;
    NSString *_firstModified;
    NSString *_picUrl;
    FMItemTradeType _offline;
    FMItemCommentDOList *_itemCommentDOList;
    NSString *_queueKey;
    NSNumber *_voiceTime;
}

@synthesize collectNum = _collectNum;
@synthesize commentNum = _commentNum;
@synthesize originalPrice = _originalPrice;
@synthesize price = _price;
@synthesize province = _province;
@synthesize city = _city;
@synthesize area = _area;
@synthesize userId = _userId;
@synthesize userNick = _userNick;
@synthesize voiceUrl = _voiceUrl;
@synthesize title = _title;
@synthesize descUrl = _descUrl;
@synthesize description = _description;
@synthesize descriptionInfo = _descriptionInfo;
@synthesize imageUrls = _imageUrls;
@synthesize from = _from;
@synthesize detailFrom = _detailFrom;
@synthesize firstModified = _firstModified;
@synthesize picUrl = _picUrl;
@synthesize offline = _offline;
@synthesize itemCommentDOList = _itemCommentDOList;
@synthesize queueKey = _queueKey;
@synthesize voiceTime = _voiceTime;

- (id)init {
    self = [super init];
    if (self) {
        self.isEditItemChanged = NO;
        self.isDescriptionChanged = NO;
    }

    return self;
}

- (BOOL)isVoiceEmpty {
    if (!self.voiceUrl || [self.voiceUrl isBlank]) {
        return YES;
    }
    return NO;
}

- (BOOL)hasResellData {
    if (self.resell && self.resellData.buyTime
            && self.resellData.oriPrice
            && self.resellData.oriSellerNick
            && self.resellData.buyTime) {
        return YES;
    }
    return NO;
}

- (NSString *)getStuffStatusString {
    NSString *stuffStatusString = nil;
    if (self.stuffStatus == 10) {
        stuffStatusString = @"全新";
    } else if (self.stuffStatus == 0) {
        stuffStatusString = @"不限";
    } else {
        stuffStatusString = @"非全新";
    }
    return stuffStatusString;
}

- (NSString *)getTradeTypeString {
    NSString *tradeTypeString = @"";
    if (self.offline == FMItemTradeTypeF2F) {
        tradeTypeString = @"同城交易";
    } else if (self.offline == FMItemTradeTypeAnyway) {
        tradeTypeString = @"在线/同城";
    } else if (self.offline == FMItemTradeTypeOnline) {
        tradeTypeString = @"在线交易";
    }
    return tradeTypeString;
}

- (NSString *)getLocationText {
    if ([self.area containsString:@":"]) {
        NSArray *areaArray = [self.area componentsSeparatedByString:@":"];
        self.area = [areaArray objectAtIndex:areaArray.count - 1];
    }

    NSMutableArray *texts = [[NSMutableArray alloc] initWithCapacity:3];
    if (self.province) {
        [texts addObject:self.province];
    }

    if (self.city) {
        [texts addObject:self.city];
    }

    if (self.area) {
        [texts addObject:self.area];
    }

    return [texts componentsJoinedByString:@" "];
}

- (NSString *)oriPicUrl {
    return _oriPicUrl ? : _picUrl;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.collectNum = [coder decodeObjectForKey:@"self.collectNum"];
        self.commentNum = [coder decodeObjectForKey:@"self.commentNum"];
        self.originalPrice = [coder decodeObjectForKey:@"self.originalPrice"];
        self.price = [coder decodeObjectForKey:@"self.price"];
        self.province = [coder decodeObjectForKey:@"self.province"];
        self.city = [coder decodeObjectForKey:@"self.city"];
        self.area = [coder decodeObjectForKey:@"self.area"];
        self.userId = [coder decodeObjectForKey:@"self.userId"];
        self.userNick = [coder decodeObjectForKey:@"self.userNick"];
        self.voiceUrl = [coder decodeObjectForKey:@"self.voiceUrl"];
        self.title = [coder decodeObjectForKey:@"self.title"];
        self.descUrl = [coder decodeObjectForKey:@"self.descUrl"];
        self.description = [coder decodeObjectForKey:@"self.description"];
        self.descriptionInfo = [coder decodeObjectForKey:@"self.descriptionInfo"];
        self.imageUrls = [coder decodeObjectForKey:@"self.imageUrls"];
        self.from = [coder decodeObjectForKey:@"self.from"];
        self.detailFrom = [coder decodeObjectForKey:@"self.detailFrom"];
        self.firstModified = [coder decodeObjectForKey:@"self.firstModified"];
        self.picUrl = [coder decodeObjectForKey:@"self.picUrl"];
        self.offline = (FMItemTradeType) [coder decodeIntForKey:@"self.offline"];
        self.queueKey = [coder decodeObjectForKey:@"self.queueKey"];
        self.voiceTime = [coder decodeObjectForKey:@"self.voiceTime"];
        self.id = [coder decodeObjectForKey:@"self.id"];
        self.canBuy = [coder decodeBoolForKey:@"self.canBuy"];
        self.canEditDescription = [coder decodeBoolForKey:@"self.canEditDescription"];
        self.categoryId = [coder decodeObjectForKey:@"self.categoryId"];
        self.categoryName = [coder decodeObjectForKey:@"self.categoryName"];
        self.contacts = [coder decodeObjectForKey:@"self.contacts"];
        self.containsImage = [coder decodeBoolForKey:@"self.containsImage"];
        self.resell = [coder decodeBoolForKey:@"self.resell"];
        self.shortUrl = [coder decodeObjectForKey:@"self.shortUrl"];
        self.stuffStatus = [coder decodeIntForKey:@"self.stuffStatus"];
        self.subscribed = [coder decodeBoolForKey:@"self.subscribed"];
        self.postPrice = [coder decodeObjectForKey:@"self.postPrice"];
        self.phone = [coder decodeObjectForKey:@"self.phone"];
        self.wxurl = [coder decodeObjectForKey:@"self.wxurl"];
        self.divisionId = [coder decodeObjectForKey:@"self.divisionId"];
        self.gps = [coder decodeObjectForKey:@"self.gps"];
        self.oriPicUrl = [coder decodeObjectForKey:@"self.oriPicUrl"];
        self.picMeasure = [coder decodeObjectForKey:@"self.picMeasure"];
        self.isUserCategory = [coder decodeBoolForKey:@"self.isUserCategory"];
        self.isEditItemChanged = [coder decodeBoolForKey:@"self.isEditItemChanged"];
        self.taoBaoTradeOrder = [coder decodeObjectForKey:@"self.taoBaoTradeOrder"];
        self.isDescriptionChanged = [coder decodeBoolForKey:@"self.isDescriptionChanged"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.collectNum forKey:@"self.collectNum"];
    [coder encodeObject:self.commentNum forKey:@"self.commentNum"];
    [coder encodeObject:self.originalPrice forKey:@"self.originalPrice"];
    [coder encodeObject:self.price forKey:@"self.price"];
    [coder encodeObject:self.province forKey:@"self.province"];
    [coder encodeObject:self.city forKey:@"self.city"];
    [coder encodeObject:self.area forKey:@"self.area"];
    [coder encodeObject:self.userId forKey:@"self.userId"];
    [coder encodeObject:self.userNick forKey:@"self.userNick"];
    [coder encodeObject:self.voiceUrl forKey:@"self.voiceUrl"];
    [coder encodeObject:self.title forKey:@"self.title"];
    [coder encodeObject:self.descUrl forKey:@"self.descUrl"];
    [coder encodeObject:self.description forKey:@"self.description"];
    [coder encodeObject:self.descriptionInfo forKey:@"self.descriptionInfo"];
    [coder encodeObject:self.imageUrls forKey:@"self.imageUrls"];
    [coder encodeObject:self.from forKey:@"self.from"];
    [coder encodeObject:self.detailFrom forKey:@"self.detailFrom"];
    [coder encodeObject:self.firstModified forKey:@"self.firstModified"];
    [coder encodeObject:self.picUrl forKey:@"self.picUrl"];
    [coder encodeInt:self.offline forKey:@"self.offline"];
    [coder encodeObject:self.queueKey forKey:@"self.queueKey"];
    [coder encodeObject:self.voiceTime forKey:@"self.voiceTime"];
    [coder encodeObject:self.id forKey:@"self.id"];
    [coder encodeBool:self.canBuy forKey:@"self.canBuy"];
    [coder encodeBool:self.canEditDescription forKey:@"self.canEditDescription"];
    [coder encodeObject:self.categoryId forKey:@"self.categoryId"];
    [coder encodeObject:self.categoryName forKey:@"self.categoryName"];
    [coder encodeObject:self.contacts forKey:@"self.contacts"];
    [coder encodeBool:self.containsImage forKey:@"self.containsImage"];
    [coder encodeBool:self.resell forKey:@"self.resell"];
    [coder encodeObject:self.shortUrl forKey:@"self.shortUrl"];
    [coder encodeInt:self.stuffStatus forKey:@"self.stuffStatus"];
    [coder encodeBool:self.subscribed forKey:@"self.subscribed"];
    [coder encodeObject:self.postPrice forKey:@"self.postPrice"];
    [coder encodeObject:self.phone forKey:@"self.phone"];
    [coder encodeObject:self.wxurl forKey:@"self.wxurl"];
    [coder encodeObject:self.divisionId forKey:@"self.divisionId"];
    [coder encodeObject:self.gps forKey:@"self.gps"];
    [coder encodeObject:self.oriPicUrl forKey:@"self.oriPicUrl"];
    [coder encodeObject:self.picMeasure forKey:@"self.picMeasure"];
    [coder encodeBool:self.isUserCategory forKey:@"self.isUserCategory"];
    [coder encodeBool:self.isEditItemChanged forKey:@"self.isEditItemChanged"];
    [coder encodeObject:self.taoBaoTradeOrder forKey:@"self.taoBaoTradeOrder"];
    [coder encodeBool:self.isDescriptionChanged forKey:@"self.isDescriptionChanged"];
}

@end