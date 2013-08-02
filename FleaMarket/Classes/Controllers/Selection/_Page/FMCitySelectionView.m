//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-12-14 下午3:21.
//


#import "FMCitySelectionView.h"
#import "FMLocationSelectionViewController.h"
#import "TBMBBind.h"
#import "TBIUChinaDivisionManager.h"
#import "FMBaseTableViewCell.h"
#import "FMStyle.h"

@interface FMCitySelectionView () <UITableViewDelegate, UITableViewDataSource>
@end

@implementation FMCitySelectionView {

@private
    FMCitySelectionViewDO *_viewDO;

}
@synthesize viewDO = _viewDO;

- (id)initWithFrame:(CGRect)frame  viewDO:(FMCitySelectionViewDO *)viewDO {
    self = [super initWithFrame:frame];
    if (self) {
        _viewDO = viewDO;
        [self initInternalView];
    }

    return self;
}

- (void)initInternalView {
    [super initInternalView];
    if (![_viewDO.citiesLevel objectForKey:[NSNumber numberWithUnsignedInteger:0]]) {
        [self getCities:nil];
    }
    UITableView *cityTableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStyleGrouped];
    cityTableView.delegate = self;
    cityTableView.dataSource = self;
    cityTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    cityTableView.backgroundView = nil;
    cityTableView.backgroundColor = [FMColor instance].viewControllerBgGrayColor;
    [self addSubview:cityTableView];

    TBMBBindObjectStrong(tbKeyPath(self, viewDO.level), cityTableView, ^(UITableView *host, id old, id new) {
        [host reloadData];
    }
    );


}

#pragma - tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *cities = [_viewDO.citiesLevel objectForKey:[NSNumber
            numberWithUnsignedInteger:_viewDO.level]];
    return [cities count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *cities = [_viewDO.citiesLevel objectForKey:[NSNumber
            numberWithUnsignedInteger:_viewDO.level]];
    static NSString *cellIdentifier = @"CityCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[FMBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor = [FMColor instance].cellColor;
        cell.textLabel.font = [FMFontSize instance].cellLabelSize;
    }
    if (indexPath.row >= 0 && indexPath.row < cities.count) {
        FMCityDO *city = [cities objectAtIndex:(NSUInteger) indexPath.row];
        cell.textLabel.text = city.name;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (_viewDO.level < _viewDO.selectCities.count) {
            FMCityDO *selectedCity = [_viewDO.selectCities objectAtIndex:_viewDO.level];
            if (selectedCity.locationID == city.locationID || [selectedCity.name isEqualToString:city.name]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
        if (_viewDO.level > 1) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        return cell;
    } else {
        return nil;
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *cities = [_viewDO.citiesLevel objectForKey:[NSNumber
            numberWithUnsignedInteger:_viewDO.level]];
    if (indexPath.row < 0 || indexPath.row >= cities.count) {
        return;
    }
    FMCityDO *city = [cities objectAtIndex:(NSUInteger) indexPath.row];
    if (_viewDO.level < _viewDO.selectCities.count) {
        NSUInteger i = _viewDO.selectCities.count;
        while (i > _viewDO.level && _viewDO.selectCities.count) {
            [_viewDO.selectCities removeLastObject];
            _viewDO.selectCities = _viewDO.selectCities;
            i--;
        }
    }
    [_viewDO.selectCities addObject:[city copy]];
    _viewDO.selectCities = _viewDO.selectCities;
    [tableView deselectRowAtIndexPath:tableView.indexPathForSelectedRow animated:NO];
    if (city.type != FMLocSelectionStatusArea) {
        [self getCities:city];
    } else {
        [tableView reloadData];
        _viewDO.selectCityEnd = YES;
    }
}


- (void)getCities:(FMCityDO *)cityInfo {
    FMLocSelectionType type = cityInfo ? cityInfo.type + 1 : FMLocSelectionStatusProvince;
    if (type >= FMLocSelectionStatusEnd) {
        _viewDO.selectCityEnd = YES;
        return;
    }
    NSInteger locationID;
    if (!cityInfo) {
        locationID = KRootLocation;
    } else {
        locationID = cityInfo.locationID;
    }
    [[TBIUChinaDivisionManager instance] locationWithFatherID:locationID withResult:^(NSArray *details) {
        [self setDataSource:details type:type];
    }];
}

- (void)setDataSource:(NSArray *)dataSource type:(FMLocSelectionType)type {
    if (!dataSource || dataSource.count == 0) {
        _viewDO.selectCityEnd = YES;
        return;
    }
    NSMutableArray *cities = [[NSMutableArray alloc] initWithCapacity:dataSource.count];
    for (TBIULocationDetail *detail in dataSource) {
        FMCityDO *cityDO = [[FMCityDO alloc] init];
        cityDO.type = type;
        cityDO.locationID = detail.locationID;
        switch (type) {
            case FMLocSelectionStatusProvince:
                cityDO.name = detail.province;
                break;
            case FMLocSelectionStatusCity:
                cityDO.name = detail.city;
                break;
            case FMLocSelectionStatusArea:
                cityDO.name = detail.district;
                break;
            default:
                continue;
        }

        [cities addObject:cityDO];
    }
    if (type == FMLocSelectionStatusProvince) {
        [_viewDO.citiesLevel setObject:cities forKey:[NSNumber numberWithUnsignedInteger:0]];
        _viewDO.level = 0;
    } else {
        [_viewDO.citiesLevel setObject:cities forKey:[NSNumber numberWithUnsignedInteger:_viewDO.level + 1]];
        _viewDO.level++;
    }
}


@end