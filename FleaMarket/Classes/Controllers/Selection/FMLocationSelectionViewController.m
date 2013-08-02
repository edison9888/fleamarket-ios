//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-12-13 下午6:26.
//


#import "FMLocationSelectionViewController.h"
#import "TBMBDefaultRootViewController+TBMBProxy.h"
#import "FMSearchParameter.h"
#import "NSString+Helper.h"
#import "FMCommon.h"
#import "FMLocation.h"

@implementation FMLocationFilterDO {
@private
    NSString *_province;
    NSString *_city;
    NSString *_area;
    NSNumber *_locationID;
    NSNumber *_lng;
    NSNumber *_lat;
    NSUInteger _change;
}

@synthesize province = _province;
@synthesize city = _city;
@synthesize area = _area;
@synthesize locationID = _locationID;
@synthesize lng = _lng;
@synthesize lat = _lat;
@synthesize change = _change;


+ (FMLocationFilterDO *)fromSearchParameter:(FMSearchParameter *)parameter {
    FMLocationFilterDO *filterDO = [[FMLocationFilterDO alloc] init];
    filterDO.province = parameter.province;
    filterDO.city = parameter.city;
    filterDO.area = parameter.area;
    filterDO.locationID = [NSNumber numberWithInteger:parameter._locationID];
    filterDO.lat = parameter.lat;
    filterDO.lng = parameter.lng;
    return filterDO;
}

- (void)toSearchParameter:(FMSearchParameter *)parameter {
    parameter.province = self.province;
    parameter.city = self.city;
    parameter.area = self.area;
    parameter._locationID = [self.locationID integerValue];
    parameter.lat = self.lat;
    parameter.lng = self.lng;
}

- (NSString *)locationStr {
    if (!(_province || _city || _area)) {
        return @"全国";
    }
    NSArray *array = @[_province ? : @"", _city ? : @"", _area ? : @""];
    NSMutableString *str = [[NSMutableString alloc] init];
    for (NSString *s in array) {
        if (![s isBlank]) {
            [str appendFormat:@" %@", s];
        }
    }
    return str;
}

- (void)clearLocation {
    self.province = nil;
    self.city = nil;
    self.area = nil;
    self.lat = nil;
    self.lng = nil;
    self.locationID = nil;
}

@end

@implementation FMLocationViewDO {
@private
    NSArray *_hotLocations;

    FMSelectedStatus _selectedStatus;
    NSUInteger _hotSelectedIndex;
    FMLocSelectionCtrStyle _style;
    FMLocation *_locationDetail;
}
@synthesize hotLocations = _hotLocations;
@synthesize selectedStatus = _selectedStatus;
@synthesize hotSelectedIndex = _hotSelectedIndex;
@synthesize style = _style;
@synthesize locationDetail = _locationDetail;


- (id)init {
    self = [super init];
    if (self) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"HotcityList" ofType:@"plist"];
        if (filePath) {
            _hotLocations = [NSArray arrayWithContentsOfFile:filePath];
        }
        _selectedStatus = FMSelectedStatusNone;
        _hotSelectedIndex = NSNotFound;
    }

    return self;
}

- (NSString *)gpsString {
    FMLocation *detail = _locationDetail;
    if ([detail.lng isBlank] || [detail.lat isBlank]) {
        return nil;
    }

    NSString *province = detail.province;
    NSString *city = detail.city;
    NSString *area = detail.area;
    if (province == nil) {
        province = [[NSUserDefaults standardUserDefaults] objectForKey:FM_SETTING_USER_PROVINCE];
        city = [[NSUserDefaults standardUserDefaults] objectForKey:FM_SETTING_USER_CITY];
        area = [[NSUserDefaults standardUserDefaults] objectForKey:FM_SETTING_USER_AREA];
    }

    NSString *retString = nil;
    if (province && city && area && (province.length > 0) && (city.length > 0) && (area.length > 0)) {
        retString = [NSString stringWithFormat:@"%@ %@ %@", province, city, area];
    }
    else if (province && city && (province.length > 0) && (city.length > 0)) {
        retString = [NSString stringWithFormat:@"%@ %@", province, city];
    }
    else if (province && (province.length > 0)) {
        retString = [province copy];
    }

    return retString;
}


- (void)dealloc {
    FMLOG(@"%@ dealloc", self);
}

@end

@interface FMLocationSelectionViewController () <FMLocationSelectionViewDelegate>
@end

@implementation FMLocationSelectionViewController {
@private

    void (^_didSelectBlock)(FMLocationFilterDO *);

    FMLocationFilterDO *_filterDO;
    FMLocationViewDO *_viewDO;

}
@synthesize viewDO = _viewDO;


- (id)init {
    self = [super init];
    if (self) {
        self.from = kFMPostCitySelectionFromNormal;
    }

    return self;
}

- (id)initWithFilterDO:(FMLocationFilterDO *)filterDO {
    self = [self init];
    if (self) {
        _viewDO = [[FMLocationViewDO alloc] init];
        _filterDO = filterDO;
        if (_filterDO) {
            if (_filterDO.lat && _filterDO.lng) {
                _viewDO.selectedStatus = FMSelectedStatusGPS;
            } else if (_filterDO.province || _filterDO.city || _filterDO.area) {
                _viewDO.selectedStatus = FMSelectedStatusCities;
            }
        }
    }

    return self;
}

- (void)setDidSelectAction:(void (^)(FMLocationFilterDO *))block {
    if (block) {
        _didSelectBlock = block;
    }
}


- (void)loadView {
    [super loadView];
    // init button
    self.leftBarButton.hidden = NO;
    [self setTitle:@"城市"];
    [self setRightButtonTitle:@"确定"];

    float statusHeight = self.from == kFMPostCitySelectionFromPost ? 0 : 20;
    CGRect rect = CGRectMake(0, kNavigationBarHeight, FM_SCREEN_WIDTH,
            FM_SCREEN_HEIGHT - kNavigationBarHeight - statusHeight);
    // layout selectionView
    FMLocationSelectionView *selectionView = [[FMLocationSelectionView alloc] initWithFrame:rect AndViewDO:_viewDO];
    selectionView.filterDO = _filterDO;
    selectionView.backgroundColor = [UIColor clearColor];
    selectionView.delegate = self.proxyObject;
    [self.view addSubview:selectionView];
}

- (void)rightAction:(id)sender {
    if (_didSelectBlock) {
        _didSelectBlock(_filterDO);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)gotoSelectCity {
    FMCitySelectionViewController *citySelectionViewController = [[FMCitySelectionViewController alloc]
            initWithFilterDO:_filterDO];
    citySelectionViewController.hidesBottomBarWhenPushed = YES;
    citySelectionViewController.from = self.from;
    citySelectionViewController.isLimited = (self.viewDO.style == FMLocSelectionCtrStyleLocationLimit);
    [self.navigationController pushViewController:citySelectionViewController animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.from == kFMPostCitySelectionFromPost) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    }
}

@end