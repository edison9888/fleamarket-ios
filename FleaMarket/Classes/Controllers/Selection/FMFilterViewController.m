//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-12-13 下午6:22.
//

#define kFilteredValueLabelTag (1212)

#import "FMFilterViewController.h"
#import "FMFilterFieldDO.h"
#import "FMSearchParameter.h"
#import "FMCategory.h"
#import "FMCommon.h"
#import "FMPriceFilterViewController.h"
#import "FMStuffStatusViewController.h"
#import "FMFilterFieldOptionDO.h"
#import "FMFrontCategoryViewController.h"
#import "FMLocationSelectionViewController.h"
#import "FMTradeFilterViewController.h"
#import "NSString+Helper.h"
#import "FMBaseTableViewCell.h"
#import "FMStyle.h"

@interface FMFilterViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation FMFilterViewController {
    UITableView *_filterTableView;
    NSUInteger _filterFields;
    NSArray *_fieldDOs;
    FMSearchParameter *_searchParameter;
    FMSearchParameter *_filterSearchParameter;

    void(^_filterDoneBlock)();

}

@synthesize searchParameter = _searchParameter;

- (void)initNavigationBar {
    [self setTitle:@"筛选"];
    [self setLeftBarButtonTitle:nil buttonType:LeftButtonWithBack
                      iconImage:nil];
    [self setRightButtonTitle:@"确定"];
}

- (id)initWithFilterFields:(NSUInteger)filterFields {
    self = [super init];
    if (self) {
        _filterFields = filterFields;
        _searchParameter = [[FMSearchParameter alloc] init];
        _filterSearchParameter = [[FMSearchParameter alloc] init];
    }

    return self;
}

- (void)setFilterDone:(void (^)())filterDoneBlock {
    _filterDoneBlock = filterDoneBlock;
}


- (void)loadView {
    [super loadView];
    [self initNavigationBar];

    CGRect tableViewRect = {{0, kNavigationBarHeight}, {FM_SCREEN_WIDTH, self.view.frame.size.height}};
    _filterTableView = [[UITableView alloc] initWithFrame:tableViewRect style:UITableViewStyleGrouped];
    _filterTableView.delegate = self;
    _filterTableView.dataSource = self;
    _filterTableView.backgroundColor = [FMColor instance].viewControllerBgGrayColor;
    _filterTableView.backgroundView = nil;
    _filterTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:_filterTableView];
}

- (void)setSearchParameter:(FMSearchParameter *)searchParameter {
    _searchParameter = searchParameter;
    _filterSearchParameter = [_searchParameter copy];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupFilterFieldsArray];
    [_filterTableView reloadData];
}

- (void)setupFilterFieldsArray {
    if (_fieldDOs != nil) {
        _fieldDOs = nil;
    }

    FMFilterFieldDO *categoryField = [[FMFilterFieldDO alloc] init];
    categoryField.key = FM_FILTER_FIELD_CATEGORY;
    categoryField.title = @"所在类目";

    FMFilterFieldDO *stuffStatusField = [[FMFilterFieldDO alloc] init];
    stuffStatusField.key = FM_FILTER_FIELD_STUFF_STATUS;
    stuffStatusField.title = @"新旧程度";

    FMFilterFieldDO *priceField = [[FMFilterFieldDO alloc] init];
    priceField.key = FM_FILTER_FIELD_PRICE;
    priceField.title = @"价格";

    FMFilterFieldDO *locationField = [[FMFilterFieldDO alloc] init];
    locationField.key = FM_FILTER_FIELD_LOCATION;
    locationField.title = @"城市";

    FMFilterFieldDO *offlineField = [[FMFilterFieldDO alloc] init];
    offlineField.key = FM_FILTER_FIELD_TRADE;
    offlineField.title = @"交易方式";

    NSMutableArray *array = [NSMutableArray arrayWithCapacity:4];
    if (_filterFields & FMFilterFieldCategory) {
        if (_filterSearchParameter._category$FMCategory.count < 1) {
            categoryField.value = @"全部";
        } else {
            FMCategory *category = [_filterSearchParameter._category$FMCategory lastObject];
            categoryField.value = category.name;
        }
        [array addObject:categoryField];
    }

    if (_filterFields & FMFilterFieldStatus) {
        NSString *value = [_searchParameter getStatusString];
        stuffStatusField.value = value;
        [array addObject:stuffStatusField];
    }

    if (_filterFields & FMFilterFieldPrice) {
        priceField.value = [self priceString:_filterSearchParameter.startPrice endPrice:_filterSearchParameter.endPrice];
        [array addObject:priceField];
    }

    if (_filterFields & FMFilterFieldLocation) {
        NSString *province = _filterSearchParameter.province;
        NSString *city = _filterSearchParameter.city;
        NSString *area = _filterSearchParameter.area;
        NSString *location = [FMCommon locationStringbyProvince:province city:city area:area bySeperatedString:@","];
        if (location.length < 1) {
            locationField.value = @"全国";
        } else {
            locationField.value = location;
        }
        [array addObject:locationField];
    }

    if (_filterFields & FMFilterFieldTrade) {
        offlineField.value = [_searchParameter getTradeTypeString];
        [array addObject:offlineField];
    }

    _fieldDOs = [NSArray arrayWithArray:array];
}

- (NSString *)priceString:(NSNumber *)startPrice endPrice:(NSNumber *)endPrice {
    if ([endPrice longLongValue] < 1 && [startPrice longLongValue] < 1) {
        return @"不限";
    } else if ([startPrice longLongValue] > 0 && [endPrice longLongValue] > 0) {
        return [NSString stringWithFormat:@"%lld - %lld元", [startPrice longLongValue] / 100, [endPrice longLongValue] / 100];
    } else if ([startPrice longLongValue] > 0) {
        return [NSString stringWithFormat:@"%lld元以上", ([startPrice longLongValue] / 100)];
    }
    return [NSString stringWithFormat:@"%lld元以下", ([endPrice longLongValue] / 100)];
}

- (void)rightAction:(id)sender {
    [_searchParameter fromAnotherParameter:_filterSearchParameter];
    if (_filterDoneBlock) {
        _filterDoneBlock();
    }
    [self dismissModalViewControllerAnimated:YES];
}

- (void)leftAction:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - TableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _fieldDOs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"FilterTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[FMBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor = [FMColor instance].cellColor;
        cell.textLabel.font = [FMFontSize instance].cellLabelSize;
        CGRect filteredValueRect = {{120, 12}, {260 - 100, 20}};
        UILabel *filteredValueLabel = [[UILabel alloc] initWithFrame:filteredValueRect];
        filteredValueLabel.backgroundColor = [UIColor clearColor];
        filteredValueLabel.textColor = FMColorWithRed(0x22, 0x22, 0x22);
        filteredValueLabel.font = [FMFontSize instance].cellLabelSize;
        filteredValueLabel.textAlignment = NSTextAlignmentRight;
        filteredValueLabel.tag = kFilteredValueLabelTag;
        [cell addSubview:filteredValueLabel];
    }

    FMFilterFieldDO *filterDO = [_fieldDOs objectAtIndex:(NSUInteger) indexPath.row];
    cell.textLabel.text = filterDO.title;
    UILabel *filteredValueLabel = (UILabel *) [cell viewWithTag:kFilteredValueLabelTag];
    filteredValueLabel.text = filterDO.value;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FMFilterFieldDO *filterFieldDO = [_fieldDOs objectAtIndex:(NSUInteger) indexPath.row];

    if (filterFieldDO.key == FM_FILTER_FIELD_CATEGORY) {
        FMFrontCategoryViewController *frontCategoryViewController = [[FMFrontCategoryViewController alloc]
                                                                                                     initWithSearchParameter:_filterSearchParameter];
        frontCategoryViewController.hidesBottomBarWhenPushed = YES;
        [frontCategoryViewController setDidSelectAction:^(NSArray *array) {
            _filterSearchParameter._category$FMCategory = array;
            if (array.count < 1) {
                filterFieldDO.value = @"全部";
            } else {
                FMCategory *category = [array lastObject];
                filterFieldDO.value = category.name;
            }
            [_filterTableView reloadData];
        }];
        [self.navigationController pushViewController:frontCategoryViewController animated:YES];
        return;
    }

    if (filterFieldDO.key == FM_FILTER_FIELD_PRICE) {
        FMPriceFilterViewController *priceFilterViewController = [[FMPriceFilterViewController alloc]
                                                                                               initWithSearchParameter:_filterSearchParameter];
        priceFilterViewController.hidesBottomBarWhenPushed = YES;
        [priceFilterViewController setDidSelectAction:^(FMFilterFieldOptionDO *optionDOStart, FMFilterFieldOptionDO *optionDOEnd) {
            if ([optionDOStart.value unsignedLongLongValue] > 0) {
                _filterSearchParameter.endPrice = [NSNumber numberWithUnsignedLongLong:[optionDOStart.value unsignedLongLongValue]];
            }
            else {
                _filterSearchParameter.endPrice = nil;
            }
            filterFieldDO.value = optionDOStart.title;
            if ([optionDOEnd.value unsignedLongLongValue] > 0) {
                _filterSearchParameter.endPrice = [NSNumber numberWithLongLong:[optionDOEnd.value unsignedLongLongValue]];
            } else {
                _filterSearchParameter.endPrice = nil;
            }
            if ([optionDOStart.value unsignedLongLongValue] > 0) {
                _filterSearchParameter.startPrice = [NSNumber numberWithLongLong:[optionDOStart.value unsignedLongLongValue]];
            } else {
                _filterSearchParameter.startPrice = nil;
            }
            filterFieldDO.value = [self priceString:_filterSearchParameter.startPrice endPrice:_filterSearchParameter.endPrice];
            [_filterTableView reloadData];
        }];
        [self.navigationController pushViewController:priceFilterViewController animated:YES];
        return;
    }

    if (filterFieldDO.key == FM_FILTER_FIELD_STUFF_STATUS) {
        FMStuffStatusViewController *statusViewController = [[FMStuffStatusViewController alloc]
                                                                                          initWithSearchParameter:_filterSearchParameter];
        statusViewController.hidesBottomBarWhenPushed = YES;
        [statusViewController setDidSelectAction:^(FMFilterFieldOptionDO *optionDO) {
            _filterSearchParameter._stuffStatus = (FMSearchConditionStuffStatus) [optionDO.value intValue];
            filterFieldDO.value = optionDO.title;
            [_filterTableView reloadData];
        }];
        [self.navigationController pushViewController:statusViewController animated:YES];
        return;
    }

    if (filterFieldDO.key == FM_FILTER_FIELD_LOCATION) {
        FMLocationFilterDO *filterDO = [FMLocationFilterDO fromSearchParameter:_filterSearchParameter];
        FMLocationSelectionViewController *locationViewController = [[FMLocationSelectionViewController alloc]
                                                                                                        initWithFilterDO:filterDO];
        locationViewController.hidesBottomBarWhenPushed = YES;
        [locationViewController setDidSelectAction:^(FMLocationFilterDO *optionDO) {
            [optionDO toSearchParameter:_filterSearchParameter];
            filterFieldDO.value = optionDO.locationStr;
            [_filterTableView reloadData];
        }];
        [self.navigationController pushViewController:locationViewController animated:YES];
        return;
    }

    if (filterFieldDO.key == FM_FILTER_FIELD_TRADE) {
        FMTradeFilterViewController *tradeViewController = [[FMTradeFilterViewController alloc]
                                                                                         initWithSearchParameter:_searchParameter];
        tradeViewController.hidesBottomBarWhenPushed = YES;
        [tradeViewController setDidSelectAction:^(FMFilterFieldOptionDO *optionDO) {
            _filterSearchParameter._offline = (FMSearchConditionTradeType) [optionDO.value intValue];
            filterFieldDO.value = optionDO.title;
            [_filterTableView reloadData];
        }];
        [self.navigationController pushViewController:tradeViewController animated:YES];
        return;
    }
    return;
}

@end