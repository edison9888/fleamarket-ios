// 
// Created by henson on 6/7/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>

typedef enum {
    FM_BANNER = 0,
    FM_LEFT_BIG,
    FM_RIGHT_BIG,
    FM_ALL_SMALL,
    FM_HOME_TYPE_END
} FM_HOME_TYPE;


@interface FMHomeItemViewDO : NSObject
@property(nonatomic, copy) NSNumber *commentCount;
@property(nonatomic, copy) NSNumber *favCount;
@property(nonatomic, copy) NSNumber *hasVoice;
@property(nonatomic, copy) NSNumber *voiceTime;
@end

@interface FMHomeSellerViewDO : NSObject
@property(nonatomic, copy) NSString *seller;
@property(nonatomic, copy) NSString *sellerHeadUrl;
@property(nonatomic, copy) NSString *typeUrl;
@end

@interface FMHomeActionDO : NSObject
@property(nonatomic, copy) NSString *itemId;
@property(nonatomic, copy) NSString *webUrl;
@property(nonatomic, strong) NSDictionary *search;
@property(nonatomic, copy) NSString *withTitle;
@property(nonatomic, copy) NSString *withPicUrl;
@property(nonatomic, copy) NSString *withUserNick;
@end

@interface FMHomeItemDO : NSObject

@property(nonatomic, strong) NSArray *picUrls;
@property(nonatomic, strong) FMHomeItemViewDO *item;
@property(nonatomic, strong) FMHomeSellerViewDO *seller;
@property(nonatomic, strong) FMHomeActionDO *action;

@end

@interface FMHomeRowDO : NSObject
@property(nonatomic, assign) FM_HOME_TYPE type;
@annotate(FMHomeRowDO, TBIU_ANN_TYPE : @"FMHomeItemDO")
@property(nonatomic, strong) NSArray *items;

@end

@interface FMHomeRowList : NSObject

@annotate(FMHomeRowList, TBIU_ANN_TYPE : @"FMHomeRowDO")
@property(nonatomic, strong) NSArray *items;

@end




