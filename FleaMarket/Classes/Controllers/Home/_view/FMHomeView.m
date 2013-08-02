//
// Created by yuanxiao on 13-6-8.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <MBMvc/TBMBBind.h>
#import <MBMvc/TBMBDefaultPage.h>
#import "FMHomeView.h"
#import "FMHomeItemCell.h"
#import "FMStyle.h"
#import "FMHomeItemDO.h"
#import "FMHomeThreeItemsCell.h"

#define CELL_SEP_HEIGHT 8
#define PIC_HEIGHT 200


@implementation FMHomeViewDO
- (id)init {
    self = [super init];
    if (self) {
        self.items = [NSMutableArray array];
        self.pageNo = 1;
    }
    return self;
}

@end

@implementation FMHomeView {
@private
    id _delegate;

    UITableView *_tableView;
    FMHomeViewDO *_viewDO;

    NSInteger _animationMaxHeight;
    NSInteger _needAnimationWithRow;
}

@synthesize delegate = _delegate;
@synthesize viewDO = _viewDO;


- (void)loadView {
    [super loadView];
    UITableView *tableView = [[UITableView alloc]
                                           initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)
                                                   style:UITableViewStylePlain];
    tableView.contentInset = UIEdgeInsetsMake(kFMBaseScrollTitleHeight, 0, 0, 0);
    tableView.backgroundColor = [UIColor clearColor];
    TBMBAutoNilDelegate(UITableView *, tableView, delegate, self);
    TBMBAutoNilDelegate(UITableView *, tableView, dataSource, self);
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.tableFooterView = [self footerView];
    [self addSubview:tableView];
    _tableView = tableView;

    [self addMoreView:tableView];
    [self addEGORefresh:tableView];
}

TBMBWhenThisKeyPathChange(viewDO, items){
    [_tableView reloadData];
    [self requestFinish:_viewDO.more];
}

- (UIView *)footerView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, FM_SCREEN_WIDTH, CELL_SEP_HEIGHT)];
    view.backgroundColor = [FMColor instance].viewControllerBgColor;
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    FMHomeRowDO *rowDO = [_viewDO.items objectAtIndex:(NSUInteger) indexPath.row];
    CGFloat height;
    if (rowDO.type == FM_BANNER) {
        height = 80 + 8;
    } else if (rowDO.type == FM_ALL_SMALL) {
        height = 97 + 8;
    } else {
        height = CELL_SEP_HEIGHT + PIC_HEIGHT;
    }
    if (_animationMaxHeight < FM_SCREEN_HEIGHT - 20 - kNavigationBarHeight) {
        _animationMaxHeight += height;
        _needAnimationWithRow = indexPath.row;
    }
    return height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_viewDO.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"HomeItemCell";
    static NSString *threeItemCellIdentifier = @"HomeThreeItemsCell";
    if (indexPath.row >= _viewDO.items.count) {
        return nil;
    }

    __weak FMHomeView *selfWeak = self;
    FMHomeRowDO *rowDO = [_viewDO.items objectAtIndex:(NSUInteger) indexPath.row];
    if (rowDO.type == FM_ALL_SMALL) {
        FMHomeThreeItemsCell *cell = [tableView dequeueReusableCellWithIdentifier:threeItemCellIdentifier];
        if (cell == nil) {
            cell = [[FMHomeThreeItemsCell alloc]
                    initWithStyle:UITableViewCellStyleDefault
                  reuseIdentifier:threeItemCellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        if (indexPath.row <= _needAnimationWithRow) {
            cell.row = indexPath.row;
        } else {
            cell.row = -1;
        }
        [cell setData:rowDO];
        [cell setTouchAction:^(FMHomeItemDO *homeItemDO) {
            [selfWeak clickOnHomeItem:homeItemDO];
        }];
        return cell;
    }

    FMHomeItemCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[FMHomeItemCell alloc]
                                initWithStyle:UITableViewCellStyleDefault
                              reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    if (indexPath.row <= _needAnimationWithRow) {
        cell.row = indexPath.row;
    } else {
        cell.row = -1;
    }
    [cell setData:rowDO];
    [cell setTouchAction:^(FMHomeItemDO *homeItemDO) {
        [selfWeak clickOnHomeItem:homeItemDO];
    }];

    return cell;
}

- (void)clickOnHomeItem:(FMHomeItemDO *)homeItemDO {
    [self.delegate clickOnHomeItem:homeItemDO];
}

- (BOOL)hasNextPage {
    return YES;
}

- (void)requestMore {
    [self.delegate requestMore];
}

- (void)refreshData {
    [self.delegate refreshData];
}

@end