// 
// Created by henson on 5/2/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import "FMSortFilterViewController.h"
#import "FMBaseTableViewCell.h"
#import "FMStyle.h"

@interface FMSortFilterViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation FMSortFilterViewController {
    UITableView *_tableView;
    FMSearchParameter *_searchParameter;
    void (^_didSelectBlock)(FMSearchConditionSortType);
}

- (void)initNavigationBar {
    [self setTitle:@"排序"];
    [self setLeftBarButtonTitle:nil
                     buttonType:LeftButtonWithBack
                      iconImage:nil];
}

- (id)initWithSearchParameter:(FMSearchParameter *)searchParameter {
    self = [super init];
    if (self) {
        _searchParameter = searchParameter;
    }

    return self;
}

- (void)loadView {
    [super loadView];
    [self initNavigationBar];

    CGRect tableRect = {{0, kNavigationBarHeight},{FM_SCREEN_WIDTH, FM_SCREEN_HEIGHT - 20 - kNavigationBarHeight}};
    _tableView = [[UITableView alloc] initWithFrame:tableRect style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundView = nil;
    _tableView.backgroundColor = [FMColor instance].viewControllerBgGrayColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:_tableView];
}

- (void)setDidSelect:(void (^)(FMSearchConditionSortType))block {
    _didSelectBlock = block;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)dealloc {
    _didSelectBlock = nil;
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"SortCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[FMBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor = [FMColor instance].cellColor;
        cell.textLabel.font = [FMFontSize instance].cellLabelSize;
    }

    NSUInteger row = (NSUInteger) indexPath.row;
    NSString *text = nil;
    if (row == 0) {
        text = @"不限";
        if ([_searchParameter sortType] == FMSearchConditionSortDefault) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    } else if (row == 1) {
        if ([_searchParameter sortType] == FMSearchConditionSortTime) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        text = @"时间从近到远";
    } else if (row == 2) {
        if ([_searchParameter sortType] == FMSearchConditionSortPriceUp) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        text = @"价格从低到高";
    } else {
        if ([_searchParameter sortType] == FMSearchConditionSortPriceDown) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        text = @"价格从高到低";
    }
    cell.textLabel.text = text;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;

    NSUInteger row = (NSUInteger) indexPath.row;
    FMSearchConditionSortType sortType = FMSearchConditionSortDefault;
    if (row == 0) {
        [_searchParameter setSortType:FMSearchConditionSortDefault];
        sortType = FMSearchConditionSortDefault;
    } else if (row == 1) {
        [_searchParameter setSortType:FMSearchConditionSortTime];
        sortType = FMSearchConditionSortTime;
    } else if (row == 2) {
        [_searchParameter setSortType:FMSearchConditionSortPriceUp];
        sortType = FMSearchConditionSortPriceUp;
    } else if (row == 3) {
        [_searchParameter setSortType:FMSearchConditionSortPriceDown];
        sortType = FMSearchConditionSortPriceDown;
    }
    [_tableView reloadData];

    if (_didSelectBlock) {
        _didSelectBlock(sortType);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end