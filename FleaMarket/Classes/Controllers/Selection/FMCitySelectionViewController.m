//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-12-14 下午2:52.
//


#import "FMCitySelectionViewController.h"
#import "FMCitySelectionView.h"
#import "FMStyle.h"
#import "FMLocationSelectionViewController.h"
#import "TBMBBind.h"

@implementation FMCityDO {
@private
    NSInteger _locationID;
    NSString *_name;
    FMLocSelectionType _type;
}

@synthesize locationID = _locationID;
@synthesize name = _name;
@synthesize type = _type;

- (id)copyWithZone:(NSZone *)zone {
    FMCityDO *aDo = [[FMCityDO allocWithZone:zone] init];
    aDo.name = self.name;
    aDo.locationID = self.locationID;
    aDo.type = self.type;
    return aDo;
}


@end


@implementation FMCitySelectionViewDO {
@private
    NSUInteger _level;
    NSMutableDictionary *_citiesLevel;
    NSMutableArray *_selectCities;
    BOOL _selectCityEnd;
}

@synthesize level = _level;
@synthesize citiesLevel = _citiesLevel;
@synthesize selectCities = _selectCities;
@synthesize selectCityEnd = _selectCityEnd;


- (id)init {
    self = [super init];
    if (self) {
        _level = 0;
        _citiesLevel = [[NSMutableDictionary alloc] initWithCapacity:3];
        _selectCities = [[NSMutableArray alloc] initWithCapacity:3];
    }

    return self;
}


@end

@implementation FMCitySelectionViewController {
@private
    FMCitySelectionViewDO *_viewDO;
    FMLocationFilterDO *_filterDO;
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
        _filterDO = filterDO;
        _viewDO = [[FMCitySelectionViewDO alloc] init];
        if (_filterDO.province) {
            FMCityDO *province = [[FMCityDO alloc] init];
            province.name = _filterDO.province;
            province.type = FMLocSelectionStatusProvince;

            [_viewDO.selectCities addObject:province];
            _viewDO.selectCities = _viewDO.selectCities;
        }
        if (_filterDO.city) {
            FMCityDO *city = [[FMCityDO alloc] init];
            city.name = _filterDO.city;
            city.type = FMLocSelectionStatusCity;
            [_viewDO.selectCities addObject:city];
            _viewDO.selectCities = _viewDO.selectCities;
        }
        if (_filterDO.area) {
            FMCityDO *area = [[FMCityDO alloc] init];
            area.name = _filterDO.area;
            area.type = FMLocSelectionStatusArea;
            [_viewDO.selectCities addObject:area];
            _viewDO.selectCities = _viewDO.selectCities;
        }
        TBMBBindObjectWeak(tbKeyPath(self, viewDO.selectCities), self,
                ^(FMCitySelectionViewController *host, id old, id new) {

                    if (host.viewDO.selectCities.count > 0) {
                        NSMutableString *pos = [[NSMutableString alloc] init];
                        for (FMCityDO *c in host.viewDO.selectCities) {
                            [pos appendFormat:@"%@/", c.name];
                        }
                        [host setTitle:[pos substringToIndex:pos.length - 1]];
                    } else {
                        [host setTitle:@"请选择位置"];
                    }

                }
        );

        TBMBBindObjectWeak(tbKeyPath(self, viewDO.selectCityEnd), self,
                ^(FMCitySelectionViewController *host, id old, id new) {
                    if ([new boolValue])
                        [host rightAction:nil];
                }
        );
    }

    return self;
}

- (void)loadView {
    [super loadView];
    // init button
    self.leftBarButton.hidden = NO;
    [self setTitle:@"城市"];

    [self.view setBackgroundColor:[FMColor instance].viewControllerBgGrayColor];
    float statusHeight = self.from == kFMPostCitySelectionFromPost ? 0 : 20;
    CGRect rect = CGRectMake(0, kNavigationBarHeight, FM_SCREEN_WIDTH,
            FM_SCREEN_HEIGHT - kNavigationBarHeight - statusHeight);

    // layout selectionView
    FMCitySelectionView *selectionView = [[FMCitySelectionView alloc]
                                                               initWithFrame:rect
                                                                      viewDO:_viewDO];
    selectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:selectionView];

}

- (void)leftAction:(id)sender {
    if (_viewDO.level > 0) {
        if (_viewDO.level < _viewDO.selectCities.count) {
            [_viewDO.selectCities removeLastObject];
            _viewDO.selectCities = _viewDO.selectCities;
        }
        _viewDO.level--;
    } else {
        [super leftAction:sender];
    }

}

- (void)rightAction:(id)sender {
    [_filterDO clearLocation];

    for (FMCityDO *c in _viewDO.selectCities) {
        switch (c.type) {
            case FMLocSelectionStatusProvince:
                _filterDO.province = c.name;
                break;
            case FMLocSelectionStatusCity:
                _filterDO.city = c.name;
                break;
            case FMLocSelectionStatusArea:
                _filterDO.area = c.name;
                break;
            default:
                break;
        }
        _filterDO.locationID = [NSNumber numberWithInteger:c.locationID];
    }
    _filterDO.change++;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.from == kFMPostCitySelectionFromPost) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    }
}

@end