// 
// Created by henson on 6/13/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>
#import "FMCommon.h"

@class FMItemDO;
@class FMItemCommentDOList;
@class FMTaoBaoTradeOrder;

@interface FMItemDOList : NSObject

@annotate(FMItemDOList, TBIU_ANN_TYPE : @"FMItemDO")
@property(nonatomic, strong) NSMutableArray *items;
@property(nonatomic, strong) NSString *serverTime;
@property(nonatomic, assign) BOOL nextPage;
@property(nonatomic, strong) NSNumber *totalCount;

@end

@interface FMItemDetailResellDO : NSObject

@property(nonatomic, copy) NSString *buyTime;
@property(nonatomic, copy) NSString *oriPrice;
@property(nonatomic, copy) NSString *url;
@property(nonatomic, copy) NSString *oriSellerNick;
@property(nonatomic, copy) NSString *shortUrl;

@end

@interface FMItemDetailResponseDO : NSObject

@property(nonatomic, strong) FMItemDO *item;
@property(nonatomic, copy) NSString *serverTime;

@end

@interface FMItemDO : NSObject <NSCoding>

@property(nonatomic, copy) NSString *id;

@property(nonatomic, assign) BOOL canBuy;
@property(nonatomic, assign) BOOL canEditDescription;

@property(nonatomic, copy) NSString *categoryId;
@property(nonatomic, copy) NSString *categoryName;

@property(nonatomic, copy) NSString *contacts;
@property(nonatomic, assign) BOOL containsImage;
@property(nonatomic, assign) BOOL resell;
@property(nonatomic, copy) NSString *shortUrl;
@property(nonatomic, assign) NSInteger stuffStatus;
@property(nonatomic, assign) BOOL subscribed;
@property(nonatomic, copy) NSString *originalPrice;
@property(nonatomic, copy) NSString *price;
@property(nonatomic, copy) NSString *postPrice;
@property(nonatomic, copy) NSString *phone;
@property(nonatomic, copy) NSString *wxurl;

@property(nonatomic, copy) NSString *province;
@property(nonatomic, copy) NSString *city;
@property(nonatomic, copy) NSString *area;
@property(nonatomic, copy) NSString *divisionId;
@property(nonatomic, copy) NSString *gps;

@property(nonatomic, copy) NSString *userId;
@property(nonatomic, copy) NSString *userNick;

@property(nonatomic, copy) NSString *voiceUrl;
@property(nonatomic, copy) NSNumber *voiceTime;

@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *descUrl;
@property(nonatomic, copy) NSString *description;
@property(nonatomic, copy) NSString *descriptionInfo;

@property(nonatomic, strong) NSArray *imageUrls;

@property(nonatomic, copy) NSString *from;
@property(nonatomic, copy) NSString *detailFrom;
@property(nonatomic, copy) NSString *firstModified;
@property(nonatomic, copy) NSString *picUrl;
@property(nonatomic, copy) NSString *oriPicUrl;
@property(nonatomic, copy) NSString *picMeasure;

@property(nonatomic, copy) NSString *collectNum;
@property(nonatomic, copy) NSString *commentNum;

@property(nonatomic) FMItemTradeType offline;
@property(nonatomic, strong) FMItemDetailResellDO *resellData;
@property(nonatomic, strong) FMItemCommentDOList *itemCommentDOList;
@property(nonatomic, copy) NSString *queueKey;
@property(nonatomic, assign) BOOL isUserCategory;

// 编辑宝贝时用户是否修改过
@property(nonatomic, assign) BOOL isEditItemChanged;
@property(nonatomic, strong) FMTaoBaoTradeOrder *taoBaoTradeOrder; //一键转卖信息

//描述是否修改过，主要为了避免冲掉用户的富文本描述内容
@property(nonatomic, assign) BOOL isDescriptionChanged;

- (BOOL)isVoiceEmpty;

- (BOOL)hasResellData;

- (NSString *)getStuffStatusString;

- (NSString *)getTradeTypeString;

- (NSString *)getLocationText;

- (id)initWithCoder:(NSCoder *)coder;

- (void)encodeWithCoder:(NSCoder *)coder;

@end