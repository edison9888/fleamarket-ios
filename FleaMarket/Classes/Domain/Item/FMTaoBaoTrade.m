//
// Created by henson on 2/19/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
//

#import "FMTaoBaoTrade.h"

@implementation FMTaoBaoTradeList {
@private
    long _onlineTotal;
}

@synthesize nextPage;
@synthesize serverTime;
@synthesize totalCount;
@synthesize items;
@synthesize onlineTotal = _onlineTotal;

@end


@implementation FMTaoBaoTrade {
@private
    NSInteger _totalCount;
    NSString *_postInsureFee;
}

@synthesize id;
@synthesize payStatus;
@synthesize payment;
@synthesize picUrl;
@synthesize postFee;
@synthesize orders;
@synthesize totalCount = _totalCount;
@synthesize postInsureFee = _postInsureFee;
@end

@implementation FMTaoBaoTradeOrder {
@private
    BOOL _archive;
    BOOL _virtual;
    NSInteger _status;
    NSString *_oriPrice;
}

@synthesize title;
@synthesize price;
@synthesize id;
@synthesize itemId;
@synthesize num;
@synthesize picUrl;
@synthesize archive = _archive;
@synthesize virtual = _virtual;
@synthesize status = _status;   //1=>正在转卖中

@synthesize oriPrice = _oriPrice;

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.price forKey:@"price"];
    [aCoder encodeInt64:self.id forKey:@"id"];
    [aCoder encodeInt64:self.itemId forKey:@"itemId"];
    [aCoder encodeInteger:self.num forKey:@"num"];
    [aCoder encodeObject:self.picUrl forKey:@"picUrl"];
    [aCoder encodeBool:self.archive forKey:@"archive"];
    [aCoder encodeBool:self.virtual forKey:@"virtual"];
    [aCoder encodeInteger:self.status forKey:@"status"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.price = [aDecoder decodeObjectForKey:@"price"];
        self.id = [aDecoder decodeInt64ForKey:@"id"];
        self.itemId = [aDecoder decodeInt64ForKey:@"itemId"];
        self.num = [aDecoder decodeIntegerForKey:@"num"];
        self.picUrl = [aDecoder decodeObjectForKey:@"picUrl"];
        self.archive = [aDecoder decodeBoolForKey:@"archive"];
        self.virtual = [aDecoder decodeBoolForKey:@"virtual"];
        self.status = [aDecoder decodeIntegerForKey:@"status"];
    }

    return self;
}

@end