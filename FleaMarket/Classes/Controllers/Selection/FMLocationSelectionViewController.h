//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-12-13 下午6:26.
//


#import <Foundation/Foundation.h>
#import "FMBaseViewController.h"
#import "FMLocationSelectionView.h"
#import "FMCitySelectionViewController.h"

@class FMLocation;
@class FMSearchParameter;

typedef enum {
    FMLocSelectionCtrStyleLocation = 101,
    FMLocSelectionCtrStyleLocationLimit = 102
} FMLocSelectionCtrStyle;

typedef enum {
    FMSelectedStatusGPS = 0,
    FMSelectedStatusCities = 1,
    FMSelectedStatusHot = 2,
    FMSelectedStatusNone = 3,
} FMSelectedStatus;

@interface FMLocationViewDO : NSObject
@property(nonatomic, strong) NSArray *hotLocations;
@property(nonatomic, strong) FMLocation *locationDetail;
@property(nonatomic, assign) FMSelectedStatus selectedStatus;
@property(nonatomic, assign) NSUInteger hotSelectedIndex;
@property(nonatomic, assign) FMLocSelectionCtrStyle style;

- (NSString *)gpsString;
@end

@interface FMLocationFilterDO : NSObject

@property(nonatomic, copy) NSString *province;
@property(nonatomic, copy) NSString *city;
@property(nonatomic, copy) NSString *area;
@property(nonatomic, strong) NSNumber *lat;
@property(nonatomic, strong) NSNumber *lng;
@property(nonatomic, strong) NSNumber *locationID;

@property(nonatomic, assign) NSUInteger change;

+ (FMLocationFilterDO *)fromSearchParameter:(FMSearchParameter *)parameter;

-(void)toSearchParameter:(FMSearchParameter *)parameter;

- (NSString *)locationStr;

- (void)clearLocation;
@end


@interface FMLocationSelectionViewController : FMBaseViewController

@property(nonatomic, readonly) FMLocationViewDO *viewDO;
@property(nonatomic) kFMPostCitySelectionFrom from;

- (id)initWithFilterDO:(FMLocationFilterDO *)filterDO;

- (void)setDidSelectAction:(void (^)(FMLocationFilterDO *))block;

@end