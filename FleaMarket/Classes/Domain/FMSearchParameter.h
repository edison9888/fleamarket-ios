//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-12-13 下午3:38.
//


#import <Foundation/Foundation.h>

typedef enum {
    FMSearchConditionStuffStatusAllNew = 10, //全新
    FMSearchConditionStuffStatusAllOld = 0, //非全新
    FMSearchConditionStuffStatusNoLimit = -1, //不限
} FMSearchConditionStuffStatus;

typedef enum {
    FMSearchConditionTradeTypeOnline = 0, //线上
    FMSearchConditionTradeTypeF2F    = 1, //见面交易
    FMSearchConditionTradeTypeAnyway = 2  //不限
} FMSearchConditionTradeType;

typedef enum {
    FMSearchConditionSortDefault = 0,
    FMSearchConditionSortTime = 1,
    FMSearchConditionSortDistance = 2,
    FMSearchConditionSortPriceUp = 3,
    FMSearchConditionSortPriceDown = 4,
} FMSearchConditionSortType;

@interface FMSearchParameter : NSObject <NSCopying, NSCoding>
//转换为Json用
@property(nonatomic, assign) NSUInteger pageNumber;
@property(nonatomic, assign) NSUInteger rowsPerPage;

@property(nonatomic, strong, readonly) NSNumber *categoryId;
@property(nonatomic, strong) NSNumber *startPrice;
@property(nonatomic, strong) NSNumber *endPrice;
@property(nonatomic, strong, readonly) NSNumber *offline;
@property(nonatomic, strong, readonly) NSNumber *stuffStatus;
@property(nonatomic, strong) NSString *province;
@property(nonatomic, strong) NSString *city;
@property(nonatomic, strong) NSString *area;
@property(nonatomic, strong, readonly) NSString *sortField;
@property(nonatomic, strong, readonly) NSString *sortValue;
@property(nonatomic, strong) NSString *keyword;
@property(nonatomic, strong) NSNumber *lat;
@property(nonatomic, strong) NSNumber *lng;
@property(nonatomic, strong) NSNumber *range;
@property(nonatomic, strong) NSNumber *front;
@property(nonatomic, strong) NSNumber *home;
@property(nonatomic, strong) NSNumber *inMap;

@property(nonatomic, copy) NSString *themeId;

@property(nonatomic, copy) NSString *sellerNick;

//控制用
@property(nonatomic, strong) NSArray *_category$FMCategory; //类目队列
@property(nonatomic, assign) FMSearchConditionStuffStatus _stuffStatus;
@property(nonatomic, assign) FMSearchConditionTradeType _offline;
@property(nonatomic, assign) NSInteger _locationID;

@property(nonatomic, assign) NSUInteger _filterChange;

- (void)fromAnotherParameter:(FMSearchParameter *)parameter;

- (void)setSortType:(FMSearchConditionSortType)_sortType;

- (FMSearchConditionSortType)sortType;

- (BOOL)hasFilter;

- (NSString *)getStatusString;

- (NSString *)getTradeTypeString;

- (id)initWithCoder:(NSCoder *)coder;

- (void)encodeWithCoder:(NSCoder *)coder;


@end