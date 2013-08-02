// 
// Created by henson on 7/31/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <MBMvc/TBMBGlobalFacade.h>
#import "FMResellViewController.h"
#import "FMTradesService.h"
#import "FMTaoBaoTrade.h"
#import "FMResellCell.h"
#import "FMSearchBarView.h"

@implementation FMResellViewController {
    UITableView *_tableView;

    NSMutableArray *_items;
    NSUInteger _page;
    BOOL _nextPage;
    long _onlineTotal;

    UILabel *_footLabel;
    UILabel *_noItemsPromptLabel;
    bool _isBeginRequestMore;
    bool _isLoadingMore;
}

- (id)init {
    self = [super init];
    if (self) {
        _items = [NSMutableArray arrayWithCapacity:20];
        _page = 1;
        _onlineTotal = -1;
    }

    return self;
}

- (void)initNavigationBar {
    [self setTitle:@"一键转卖"];
    [self setLeftBarButtonTitle:nil
                     buttonType:LeftButtonWithBack
                      iconImage:nil];
}

- (void)initTitleView {
    UIView *listTitleView = self.titleView;
    CGRect listTitleRect = {{0, 0}, {FM_SCREEN_WIDTH, kNavigationBarHeight * 2}};
    listTitleView.frame = listTitleRect;

    CGRect searchRect = {{0, kNavigationBarHeight}, {FM_SCREEN_WIDTH, kNavigationBarHeight}};
    FMSearchBarView *searchView = [[FMSearchBarView alloc] initWithFrame:searchRect
                                                           searchBarType:FMSearchBarTypeResell];
    __weak FMResellViewController *weakSelf = self;
    [searchView setSearchBlock:^(NSString *keyword) {
        weakSelf.keyWord = keyword;
        [weakSelf requestResellItems];
    }];
    [listTitleView insertSubview:searchView atIndex:0];
}

- (void)loadView {
    [super loadView];
    [self initNavigationBar];
    [self initTitleView];

    CGRect tableRect = {{0, kNavigationBarHeight * 2}, {FM_SCREEN_WIDTH, FM_SCREEN_HEIGHT - kNavigationBarHeight * 2}};
    UITableView *tableView = [[UITableView alloc] initWithFrame:tableRect
                                                          style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.backgroundView = nil;
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.sectionHeaderHeight = 20;
    tableView.sectionFooterHeight = 0;
    tableView.tableFooterView = [self tableFootView];
    tableView.hidden = YES;
    [self.view addSubview:tableView];
    _tableView = tableView;

    CGRect noItemsRect = {{0, kNavigationBarHeight + 20}, {FM_SCREEN_WIDTH, 20}};
    UILabel *noItemsPromptLabel = [[UILabel alloc] initWithFrame:noItemsRect];
    noItemsPromptLabel.backgroundColor = [UIColor clearColor];
    noItemsPromptLabel.textAlignment = NSTextAlignmentCenter;
    noItemsPromptLabel.font = FMFont(NO, 15);
    noItemsPromptLabel.hidden = YES;
    noItemsPromptLabel.text = @"亲，您暂无转卖的商品";
    [self.view addSubview:noItemsPromptLabel];
    _noItemsPromptLabel = noItemsPromptLabel;
}

- (UIView *)tableFootView {
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, FM_SCREEN_WIDTH, 30)];
    UILabel *footLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, FM_SCREEN_WIDTH, 30)];
    footLabel.backgroundColor = [UIColor clearColor];
    footLabel.textAlignment = NSTextAlignmentCenter;
    footLabel.font = [UIFont systemFontOfSize:14.f];
    footLabel.text = @"上拉加载更多";
    [footView addSubview:footLabel];
    _footLabel = footLabel;

    return footView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self requestResellItems];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

- (void)dealloc {
    FMLog(@"%@ dealloc", [self description]);
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
}

- (void)requestResellItems {
    if (!self.keyWord) {
        [self showPageLoadingView];
    }
    __weak FMResellViewController *selfWeak = self;
    [FMTradesService getAllTradeBought:_page
                           onlineTotal:_onlineTotal
                               keyword:self.keyWord
                                result:^(BOOL success, FMTaoBaoTradeList *tradeList) {
                                    if (success) {
                                        _nextPage = tradeList.nextPage;
                                        _onlineTotal = tradeList.onlineTotal;
                                        [_items removeAllObjects];
                                        [_items addObjectsFromArray:tradeList.items];
                                        [self removePageLoadingView];
                                        if ([tradeList.items count] < 1) {
                                            _noItemsPromptLabel.hidden = NO;
                                            return;
                                        }
                                        [_tableView reloadData];
                                        _tableView.hidden = NO;
//                                        [self doneLoadingTableViewData];
                                        return;
                                    }

                                    if (!self.keyWord) {
                                        [self showRefreshPage:^{
                                            [selfWeak requestResellItems];
                                        }];
                                    }
                                }];
}

- (void)requestMoreItems {
    _page++;
    [FMTradesService getAllTradeBought:_page
                           onlineTotal:_onlineTotal
                               keyword:self.keyWord
                                result:^(BOOL b, FMTaoBaoTradeList *tradeList) {
                                    _nextPage = tradeList.nextPage;
                                    _onlineTotal = tradeList.onlineTotal;

                                    [_items addObjectsFromArray:tradeList.items];
                                    [_tableView reloadData];
                                    if ([self hasNextPage]) {
                                        _footLabel.text = @"上拉加载更多";
                                    } else {
                                        _footLabel.text = @"已加载全部";
                                    }
                                    _isLoadingMore = NO;
                                }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_items count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    FMTaoBaoTrade *trade = [_items objectAtIndex:(NSUInteger) section];
    return [trade.orders count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ResellCell";
    FMResellCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[FMResellCell alloc] initWithStyle:UITableViewCellStyleDefault
                                   reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
        cell.backgroundView = [self cellBackgroundView:cell.bounds];
    }

    FMTaoBaoTrade *trade = [_items objectAtIndex:(NSUInteger) indexPath.section];
    FMTaoBaoTradeOrder *order = [trade.orders objectAtIndex:(NSUInteger) indexPath.row];
    if ([trade.orders count] - 1 == indexPath.row) {
        [(FMResellCellBackgroundView *) cell.backgroundView setBottomLineHidden:NO];
    } else {
        [(FMResellCellBackgroundView *) cell.backgroundView setBottomLineHidden:YES];
    }
    [cell setOrder:order endTime:trade.endTime];
    return cell;
}

- (FMResellCellBackgroundView *)cellBackgroundView:(CGRect)rect {
    FMResellCellBackgroundView *view = [[FMResellCellBackgroundView alloc] initWithFrame:rect];
    return view;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y + (scrollView.frame.size.height) <= scrollView.contentSize.height +
            20 && scrollView.contentOffset.y > 0.0f) {
        _isBeginRequestMore = NO;
        if (!_isLoadingMore) {
            if (![self hasNextPage]) {
                _footLabel.text = @"已加载全部";
                return;
            }
            _footLabel.text = @"上拉加载更多";
        }
    } else if (scrollView.contentOffset.y > 0.0f && scrollView.contentOffset.y + (scrollView.frame.size.height) >
            scrollView.contentSize.height + 20) {
        if ([self hasNextPage]) {
            if (!_isLoadingMore) {
                _footLabel.text = @"松开加载更多";
            }
            _isBeginRequestMore = YES;
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!_isLoadingMore && _isBeginRequestMore && [self hasNextPage]) {
        _isLoadingMore = YES;
        _isBeginRequestMore = NO;
        _footLabel.text = @"加载中...";
        [self requestMoreItems];
    }
}

- (BOOL)hasNextPage {
    return _nextPage;
}

- (void)$$postResellCellActionNotification:(id <TBMBNotification>)notification
                                     order:(FMTaoBaoTradeOrder *)order {
    [self.navigationController popViewControllerAnimated:YES];
    TBMBGlobalSendNotificationForSELWithBody(@selector($$postResellActionNotification:order:), order);
}

@end