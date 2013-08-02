// 
// Created by henson on 12/15/12.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import "FMTradeFilterViewController.h"
#import "FMFilterFieldOptionDO.h"
#import "FMSearchParameter.h"
#import "FMBaseTableViewCell.h"
#import "FMStyle.h"

@interface FMTradeFilterViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation FMTradeFilterViewController {
    UITableView *_tableView;
    NSArray *_fieldItems;
    FMSearchParameter *_searchParameter;
    void (^_didSelectBlock)(FMFilterFieldOptionDO *);
}

- (void)initNavigationBar {
    [self setTitle:@"交易方式筛选"];
    [self setLeftBarButtonTitle:nil buttonType:LeftButtonWithBack iconImage:nil];
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

    CGRect tableViewRect = {{0, kNavigationBarHeight},{FM_SCREEN_WIDTH,self.view.frame.size.height}};
    _tableView = [[UITableView alloc] initWithFrame:tableViewRect style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundView = nil;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.backgroundColor = [FMColor instance].viewControllerBgGrayColor;
    [self.view addSubview:_tableView];
}

- (NSArray *)fieldItems {
    FMFilterFieldOptionDO *item0 = [FMFilterFieldOptionDO objectWithTitle:@"不限"
                                                                    value:[NSString stringWithFormat:@"%d", FMSearchConditionTradeTypeAnyway]];

    FMFilterFieldOptionDO *item1 = [FMFilterFieldOptionDO objectWithTitle:@"见面"
                                                                      value:[NSString stringWithFormat:@"%d", FMSearchConditionTradeTypeF2F]];

    FMFilterFieldOptionDO *item2 = [FMFilterFieldOptionDO objectWithTitle:@"线上"
                                                                      value:[NSString stringWithFormat:@"%d", FMSearchConditionTradeTypeOnline]];

    NSArray *array = [NSArray arrayWithObjects:item0,item1,item2,nil];
    return array;
}

- (void)setDidSelectAction:(void (^)(FMFilterFieldOptionDO *optionDO))block {
    if (block) {
        _didSelectBlock = block;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _fieldItems = [self fieldItems];
    [_tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _fieldItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"FilterOfflineTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[FMBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor = [FMColor instance].cellColor;
        cell.textLabel.font = [FMFontSize instance].cellLabelSize;
    }

    FMFilterFieldOptionDO *optionDO = [_fieldItems objectAtIndex:(NSUInteger) indexPath.row];
    cell.textLabel.text = optionDO.title;
    if ([_searchParameter.offline intValue] == [optionDO.value intValue]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FMFilterFieldOptionDO *optionDO = [_fieldItems objectAtIndex:(NSUInteger) indexPath.row];
    _searchParameter._offline = (FMSearchConditionTradeType) [optionDO.value intValue];
    [_tableView reloadData];
    if (_didSelectBlock) {
        _didSelectBlock(optionDO);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end