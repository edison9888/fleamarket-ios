//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-12-14 下午2:52.
//

#import <Foundation/Foundation.h>
#import "FMBaseViewController.h"

@class FMLocationFilterDO;

typedef enum {
    FMLocSelectionStatusProvince = 1,
    FMLocSelectionStatusCity,
    FMLocSelectionStatusArea,
    FMLocSelectionStatusEnd
} FMLocSelectionType;

typedef NS_ENUM(NSUInteger, kFMPostCitySelectionFrom) {
    kFMPostCitySelectionFromNormal,
    kFMPostCitySelectionFromPost
};

@interface FMCityDO : NSObject <NSCopying>
@property(nonatomic, copy) NSString *name;
@property(nonatomic, assign) NSInteger locationID;
@property(nonatomic, assign) FMLocSelectionType type;

@end

@interface FMCitySelectionViewDO : NSObject
@property(nonatomic, assign) NSUInteger level;
@property(nonatomic, strong) NSMutableDictionary *citiesLevel;
@property(nonatomic, strong) NSMutableArray *selectCities;
@property(nonatomic, assign) BOOL selectCityEnd;
@end

@interface FMCitySelectionViewController : FMBaseViewController
@property(nonatomic, readonly) FMCitySelectionViewDO *viewDO;
@property(nonatomic) BOOL isLimited;
@property(nonatomic) kFMPostCitySelectionFrom from;

- (id)initWithFilterDO:(FMLocationFilterDO *)filterDO;

@end