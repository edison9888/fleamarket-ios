//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-12-13 下午7:41.
//

#import "FMLocationSelectionView.h"
#import "FMCommon.h"
#import "FMLocationSelectionViewController.h"
#import "TBMBBind.h"
#import "FMApplication.h"
#import "FMLocation.h"
#import "NSString+Helper.h"
#import "TBIUChinaDivisionManager.h"
#import "FMStyle.h"

#define KGpsTextlabelTag     (100001)
#define KSelectTextlabelTag  (100002)
#define KCityTextlabelTag    (100003)

#define SELECTION_NAME          @"name"
#define SELECTION_ID            @"keyID"

#define KFMRightMargin             (10)
#define KFMLeftMargin              (10)

#define KSelectionSelectedCellColor  FMColorWithRGB0X(0xe4e4e2);

@interface FMLocationSelectionView () <UITableViewDataSource, UITableViewDelegate>
@end

@implementation FMLocationSelectionView {
@private
    FMLocationFilterDO *_filterDO; //当前选择的位置
    FMLocationViewDO *_viewDO;
    id <FMLocationSelectionViewDelegate> _delegate;
}
@synthesize filterDO = _filterDO;
@synthesize viewDO = _viewDO;
@synthesize delegate = _delegate;


- (id)initWithFrame:(CGRect)frame AndViewDO:(FMLocationViewDO *)locationViewDO {
    self = [super initWithFrame:frame];
    if (self) {
        _viewDO = locationViewDO;
        [self initInternalView];
    }

    return self;
}


- (void)initInternalView {
    [super initInternalView];
    [self updateLocatingString];
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStyleGrouped];
    tableView.tag = 100000;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.backgroundColor = [FMColor instance].viewControllerBgGrayColor;
    tableView.backgroundView = nil;
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self addSubview:tableView];

}
#pragma mark - TableView data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_viewDO.style == FMLocSelectionCtrStyleLocationLimit) {
        return 2;
    }
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return _viewDO.style == FMLocSelectionCtrStyleLocationLimit ? 1 : 2;
    }
    return _viewDO.hotLocations.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return LS(@"您的位置");
        case 1:
            return LS(@"切换城市");
        case 2:
            return LS(@"热门城市");

        default:
            break;
    }

    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *gpsCellIdentifier = @"gps Cell";
    static NSString *selectCellIdentifier = @"select Cell";
    static NSString *hotCellIdentifier = @"hot Cell";

    UITableViewCell *cell = nil;
    NSInteger section = [indexPath section];
    if (section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:gpsCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]
                                     initWithStyle:UITableViewCellStyleDefault reuseIdentifier:gpsCellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            CGRect rect = CGRectMake(20, 0, cell.frame.size.width, cell.frame.size.height);
            UILabel *label = [[UILabel alloc] initWithFrame:rect];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [FMColor instance].cellColor;
            label.font = [FMFontSize instance].cellLabelSize;
            [label setTag:KGpsTextlabelTag];
            [cell addSubview:label];
        }
    } else if (section == 1 && [indexPath row] == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:selectCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]
                                     initWithStyle:UITableViewCellStyleDefault reuseIdentifier:selectCellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            CGRect rect = CGRectMake(20, 0, cell.frame.size.width - cell.frame.size.height - KFMLeftMargin - KFMRightMargin, cell.frame.size.height);
            UILabel *label = [[UILabel alloc] initWithFrame:rect];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [FMColor instance].cellColor;
            label.font = [FMFontSize instance].cellLabelSize;

            [label setTag:KSelectTextlabelTag];
            [cell addSubview:label];
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:hotCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]
                                     initWithStyle:UITableViewCellStyleDefault reuseIdentifier:hotCellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            CGRect rect = CGRectMake(20, 0, cell.frame.size.width - cell.frame.size.height - KFMLeftMargin - KFMRightMargin, cell.frame.size.height);
            UILabel *label = [[UILabel alloc] initWithFrame:rect];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [FMColor instance].cellColor;
            label.font = [FMFontSize instance].cellLabelSize;

            [label setTag:KCityTextlabelTag];
            [cell addSubview:label];
        }
    }

    int row = [indexPath row];
    switch (section) {
        case 0: {
            UILabel *textLabel = (UILabel *) [cell viewWithTag:KGpsTextlabelTag];
            NSString *text = nil;
            if (_viewDO.gpsString) {
                text = [_viewDO.gpsString copy];
            }
            if ((text == nil) || (text.length == 0)) {
                text = LS(@"无法获取当前位置");
            }
            textLabel.text = text;

            break;
        }
        case 1: {
            if (row == 0) {
                UILabel *textLabel = (UILabel *) [cell viewWithTag:KSelectTextlabelTag];
                textLabel.text = LS(@"选择城市");
                FMLocationFilterDO *filterDO = _filterDO;
                TBMBBindObjectWeak(tbKeyPath(self, filterDO.change), textLabel, ^(UILabel *host, id old, id new) {
                    host.text = [NSString stringWithFormat:@"%@ %@", LS(@"选择城市"), filterDO.locationStr] ? : @"";
                }
                );

            } else {
                UILabel *textLabel = (UILabel *) [cell viewWithTag:KCityTextlabelTag];
                textLabel.text = @"全国";
            }
            break;
        }
        case 2: {
            if (row < _viewDO.hotLocations.count) {
                UILabel *textLabel = (UILabel *) [cell viewWithTag:KCityTextlabelTag];
                textLabel.text = [[_viewDO.hotLocations objectAtIndex:(NSUInteger) row] objectForKey:SELECTION_NAME];
            }
        }
        default:
            break;
    }


    return cell;
}

- (void)resetSelectStatus:(FMSelectedStatus)status {
    _viewDO.selectedStatus = status;
    if (_viewDO.selectedStatus != FMSelectedStatusHot) {
        _viewDO.hotSelectedIndex = NSNotFound;
    }
}

- (void)updateLocatingString {
    if ([[FMApplication instance].location.lat isBlank] || [[FMApplication instance].location.lng isBlank]) {
        [[FMApplication instance]
                updateLocationWithBlock:^(TBIULocationManager *manager, CLLocation *newLocation, CLLocation *oldLocation) {
                    _viewDO.locationDetail = [FMApplication instance].location;
                    FMLog(@"FMLocationSelectionView success");
                }
                             errorBlock:^(TBIULocationManager *manager, NSError *error) {
                                 FMLog(@"FMLocationSelectionView:%@", error);
                             }];
    } else {
        _viewDO.locationDetail = [FMApplication instance].location;
    }
}

- (void)setGpsInfo {
    NSMutableArray *gpsArray = [NSMutableArray arrayWithArray:[_viewDO.gpsString
            componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    while (gpsArray.count < 3) {
        [gpsArray addObject:@""];
    }
    _filterDO.province = [gpsArray objectAtIndex:0];
    _filterDO.city = [gpsArray objectAtIndex:1];
    _filterDO.area = [gpsArray objectAtIndex:2];
    _filterDO.locationID = _viewDO.locationDetail.locationId;
    FMLocation *detail = _viewDO.locationDetail;
    if (detail) {
            _filterDO.lat = [NSNumber numberWithDouble:[detail.lat doubleValue]];
            _filterDO.lng = [NSNumber numberWithDouble:[detail.lng doubleValue]];
    }
}

- (void)selectAll {
    [_filterDO clearLocation];
}

- (void)selectHot {
    NSDictionary *dic = nil;
    if (_viewDO.hotSelectedIndex < _viewDO.hotLocations.count) {
        dic = [_viewDO.hotLocations objectAtIndex:_viewDO.hotSelectedIndex];
    } else
        return;
    NSInteger locationID = [[dic objectForKey:SELECTION_ID] intValue];

    NSMutableArray *array = [NSMutableArray arrayWithCapacity:3];
    [self selectHot:locationID array:array];
}

- (void)selectHot:(NSInteger)locationID array:(NSMutableArray *)array {
    if (locationID != KRootLocation) {
        [[TBIUChinaDivisionManager instance]
                locationWithID:locationID
                    withResult:^(TBIULocationDetail *detail) {
                        if (detail == nil)
                            return;
                        [array insertObject:detail atIndex:0];

                        [self selectHot:detail.fatherID array:array];
                    }];
    } else {
        [self selectHotHelp:locationID array:array];
    }
}

- (void)selectHotHelp:(NSInteger)locationID array:(NSMutableArray *)array {
    // get area, city, province,
    NSString *province = nil;
    NSString *city = nil;
    NSString *area = nil;
    if (array.count == 3) {
        // this is a area
        province = ((TBIULocationDetail *) [array objectAtIndex:0]).province;
        city = ((TBIULocationDetail *) [array objectAtIndex:1]).city;
        area = ((TBIULocationDetail *) [array objectAtIndex:2]).district;
    } else if (array.count == 2) {
        // this is a area
        province = ((TBIULocationDetail *) [array objectAtIndex:0]).province;
        city = ((TBIULocationDetail *) [array objectAtIndex:1]).city;
    } else {
        province = ((TBIULocationDetail *) [array objectAtIndex:0]).province;
    }
    [_filterDO clearLocation];
    _filterDO.province = province;
    _filterDO.city = city;
    _filterDO.area = area;
    _filterDO.locationID = [NSNumber numberWithInteger:locationID];
}


- (void)gotoSelectLocation {
    [_delegate gotoSelectCity];
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int row = [indexPath row];
    int section = [indexPath section];
    [self resetSelectStatus:(FMSelectedStatus) section];
    switch (section) {
        case 0: {
            if (_viewDO.gpsString) {
                _viewDO.selectedStatus = FMSelectedStatusGPS;
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                UIColor *altCellColor = KSelectionSelectedCellColor;
                cell.backgroundColor = altCellColor;
                [tableView reloadData];
                [self setGpsInfo];
            }
            else {
                [self updateLocatingString];
            }
            break;
        }

        case 1: {
            if (row == 0) {
                _viewDO.selectedStatus = FMSelectedStatusCities;
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                UIColor *altCellColor = KSelectionSelectedCellColor;
                cell.backgroundColor = altCellColor;
                [tableView reloadData];

                [self gotoSelectLocation];
            } else {
                _viewDO.selectedStatus = FMSelectedStatusNone;
                [self selectAll];
                [tableView reloadData];
            }

            break;
        }

        case 2: {
            if ((row != _viewDO.hotSelectedIndex)) {
                _viewDO.selectedStatus = FMSelectedStatusHot;
                _viewDO.hotSelectedIndex = (NSUInteger) row;
                [tableView reloadData];
                [self selectHot];
            }
            break;
        }

        default:
            break;
    }
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    int section = [indexPath section];
    switch (section) {
        case 0:
            if (_viewDO.selectedStatus == FMSelectedStatusGPS) {
                UIColor *altCellColor = KSelectionSelectedCellColor;
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                cell.backgroundColor = altCellColor;
            }
            else {
                UIColor *altCellColor = [UIColor whiteColor];
                cell.backgroundColor = altCellColor;
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
        case 1: {
            if ([indexPath row] == 0) {
                if (_viewDO.selectedStatus == FMSelectedStatusCities) {
                    UIColor *altCellColor = KSelectionSelectedCellColor;
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    cell.backgroundColor = altCellColor;
                } else {
                    UIColor *altCellColor = [UIColor whiteColor];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.backgroundColor = altCellColor;
                }
            } else {
                if (_viewDO.selectedStatus == FMSelectedStatusNone) {
                    UIColor *altCellColor = KSelectionSelectedCellColor;
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    cell.backgroundColor = altCellColor;
                } else {
                    UIColor *altCellColor = [UIColor whiteColor];
                    cell.backgroundColor = altCellColor;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }

            break;
        }

        case 2: {
            if (([indexPath row] == _viewDO.hotSelectedIndex) && (_viewDO.selectedStatus == FMSelectedStatusHot)) {
                UIColor *altCellColor = KSelectionSelectedCellColor;
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                cell.backgroundColor = altCellColor;
            }
            else {
                UIColor *altCellColor = [UIColor whiteColor];
                cell.backgroundColor = altCellColor;
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
        }
        default:
            break;
    }
}


@end