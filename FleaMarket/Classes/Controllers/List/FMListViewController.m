//
// Created by yuanxiao on 13-6-14.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <MBMvc/TBMBBind.h>
#import <MBMvc/TBMBDefaultRootViewController+TBMBProxy.h>
#import <MBMvc/TBMBSimpleStaticCommand+TBMBProxy.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "FMListViewController.h"
#import "FMSearchBarView.h"
#import "FMSegmentedControl.h"
#import "FMFilterViewController.h"
#import "FMSearchParameter.h"
#import "FMSearchService.h"
#import "FMItemDO.h"
#import "FMItemCommentService.h"
#import "FMItemCommentDO.h"
#import "FMUserTrack.h"
#import "GTDBMBase64.h"
#import "WBUtil.h"
#import "FMWebviewController.h"
#import "FMApplication.h"
#import "FMUser.h"
#import "FMLoginViewController.h"
#import "FMUserService.h"

@implementation FMListViewController {
@private
    __weak FMSegmentedControl *_segmentedControl;

    FMSearchParameter *_searchCondition;
    NSMutableDictionary *_searchDictionary;
}

- (id)initWithKeyword:(NSString *)keyword {
    if (self = [self init]) {
        _titleUrl = nil;
        _searchCondition.keyword = keyword;
        self.listType = FMListTypeSearch;
    }
    return self;
}

- (id)initWithTheme:(NSString *)themeId {
    if (self = [self init]) {
        _searchCondition.themeId = themeId;
        self.listType = FMListTypeTheme;
        _titleUrl = nil;
    }
    return self;
}

- (id)initWithCategory:(NSArray *)array {
    if (self = [self init]) {
        _titleUrl = nil;
        self.listType = FMListTypeSearch;
        if (array.count > 0) {
            _searchCondition._category$FMCategory = array;
        }
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self initSearchCondition];
    }
    return self;
}


- (id)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        _titleUrl = nil;
        self.listType = FMListTypeTheme;
        _searchDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    }
    return self;
}

- (void)initSearchCondition {
    _searchCondition = [[FMSearchParameter alloc] init];
    _searchCondition.rowsPerPage = kListPageNum;
}

- (void)setItemDO:(FMItemDO *)itemDO {
    _itemDO = itemDO;
    _searchCondition.sellerNick = itemDO.userNick;
    self.listType = FMListTypeSearchSeller;
    [FMUserTrack ctrlClicked:@"FM_SELLER_HOME" onPage:self];
}

- (void)setTitleUrl:(NSString *)titleUrl {
    _titleUrl = titleUrl;
    self.listType = FMListTypeTheme;
}

- (void)loadView {
    [super loadView];
    __weak FMListViewController *weakSelf = self;
    [self.listView setRequestCommentBlock:^(NSString *id, NSUInteger row) {
        [weakSelf requestComment:id row:row];
    }];
    self.listView.titleUrl = _titleUrl;

    if (_itemDO && _itemDO.userNick) {
        [self.listView setSearchSellerWithItemDO:_itemDO];
    }

    if (!_hideSearchView) {
        [self initListTitleView];
    }
}

- (void)initListTitleView {
    UIView *listTitleView = self.titleView;
    CGRect listTitleRect = {{0, 0}, {FM_SCREEN_WIDTH, kFMBaseScrollListHeight}};
    listTitleView.frame = listTitleRect;

    __weak FMListViewController *weakSelf = self;
    CGRect searchRect = {{0, kNavigationBarHeight}, {FM_SCREEN_WIDTH, kNavigationBarHeight}};
    FMSearchBarView *searchView = [[FMSearchBarView alloc] initWithFrame:searchRect
                                                           searchBarType:FMSearchBarTypeSearchResult];
    searchView.keyword = _searchCondition.keyword;
    [searchView setFilterBlock:^{
        [weakSelf presentFilterViewController];
    }];
    [searchView setSearchBlock:^(NSString *keyword) {
        [weakSelf searchWithKeyword:keyword];
    }];

    UIView *hLine = [[UIView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight * 2, FM_SCREEN_WIDTH, 1)];
    hLine.backgroundColor = FMColorWithRed(206, 206, 206);
    [listTitleView insertSubview:hLine atIndex:0];

    _segmentedControl = [self _segmentedControl];
    [listTitleView insertSubview:_segmentedControl atIndex:1];

    UIView *vLine = [[UIView alloc] initWithFrame:
            CGRectMake(FM_SCREEN_WIDTH / 2 - 0.5, kNavigationBarHeight * 2, 1, kFMListSortHeight - 1)];
    vLine.backgroundColor = FMColorWithRed(206, 206, 206);
    [listTitleView insertSubview:vLine atIndex:2];

    [listTitleView insertSubview:searchView atIndex:3];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_itemDO && _itemDO.userNick) {
        [self requestFlagWithNick];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self $$receiveScroll:nil offset:[NSNumber numberWithFloat:-kFMBaseScrollListHeight]];
}

#pragma mark - segment
- (FMSegmentedControl *)_segmentedControl {
    FMSegmentedControlItem *item1 = [[FMSegmentedControlItem alloc] initWithTitle:@"时间"
                                                                    hasArrowImage:NO isRepeatTouch:NO];
    item1.tag = 1;
    item1.image = [UIImage imageWithFileName:@"segmented_search_normal.png"] ;
    item1.selectedImage = [UIImage imageWithFileName:@"segmented_search_normal_selected.png"];
    FMSegmentedControlItem *item2 = [[FMSegmentedControlItem alloc] initWithTitle:@"价格"
                                                                    hasArrowImage:YES isRepeatTouch:YES];
    item2.tag = 2;
    item2.image = [UIImage imageWithFileName:@"segmented_search_normal.png"];
    item2.selectedImage = [UIImage imageWithFileName:@"segmented_search_normal_selected.png"];
    NSArray *items = @[item1, item2];
    CGRect segmentedControlRect = {{0, kNavigationBarHeight * 2 + 1}, {FM_SCREEN_WIDTH, kFMListSortHeight - 1}};
    FMSegmentedControl *segmentedControl = [[FMSegmentedControl alloc]
            initWithFrame:segmentedControlRect];
    [segmentedControl setSegmentedItems:items];
    TBMBAutoNilDelegate(FMSegmentedControl *, segmentedControl, delegate, self);
    segmentedControl.backgroundColor = FMColorWithRed(235, 235, 235);
    return segmentedControl;
}

- (void)selectedSegmentedControl:(FMSegmentedControlItem *)segmentedControlItem {
    switch (segmentedControlItem.tag) {
        case 1:
            [_searchCondition setSortType:FMSearchConditionSortTime];
            break;
        case 2:
            if ([_searchCondition.sortField isEqualToString:@"price"]) {
                if ([_searchCondition.sortValue isEqualToString:@"asc"]) {
                    [_searchCondition setSortType:FMSearchConditionSortPriceDown];
                    segmentedControlItem.arrowImage = [[UIImage imageWithFileName:@"sort_arrow_up.png"] topMirrorImageToBottom];
                } else {
                    [_searchCondition setSortType:FMSearchConditionSortPriceUp];
                    segmentedControlItem.arrowImage = [UIImage imageWithFileName:@"sort_arrow_up.png"];
                }
            } else {
                [_searchCondition setSortType:FMSearchConditionSortPriceUp];
                segmentedControlItem.arrowImage = [UIImage imageWithFileName:@"sort_arrow_up.png"];
            }
            break;
        default:
            break;
    }
    [self loadingView];
    [self requestItem:NO];
}

- (void)$$receiveScrollTitle:(id <TBMBNotification>)notification offset:(NSNumber *)offset {
    if (!self.showing) {
        return;
    }
    _segmentedControl.hidden = [offset floatValue] > 0;
    [self $$receiveScroll:notification offset:offset];
}

- (void)$$toWangWang:(id <TBMBNotification>)notification {
    if (!self.showing) {
        return;
    }
    if (![[FMApplication instance].loginUser isLogin]) {
        FMLoginViewController *loginViewController = [[FMLoginViewController alloc] init];
        loginViewController.loginCallback = ^(BOOL isLoginSuccess) {
            if (isLoginSuccess) {
                [self toWangWang];
            }
        };
        UINavigationController *loginNavigationController = [[UINavigationController alloc]
                initWithRootViewController:loginViewController];
        [self presentViewController:loginNavigationController
                           animated:YES
                         completion:nil];
    } else {
        [self toWangWang];
    }
}

- (void)toWangWang {
    [FMUserTrack ctrlClicked:@"与卖家旺旺聊天"
                      onPage:self];
    NSString *wwSellerName = [GTDBMBase64 stringByEncodingData:[_itemDO.userNick dataUsingEncoding:
            CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)]];
    NSString *url = [NSString stringWithFormat:@"http://im.m.taobao.com/ww/wap_ww_dialog.htm?toUser=%@&sid=%@&ttid=%@&item_num_id=%@",
                                               [wwSellerName URLEncodedString],
                                               [FMApplication instance].loginUser.sid,
                                               kCurrentTTID,
                                               _itemDO.id ? : @""];
    FMWebViewController *webView = [[FMWebViewController alloc] init];
    webView.webViewType = FMWebViewTypeRequest;
    webView.url = url;
    webView.clearCookie = YES;
    webView.title = @"旺旺";
    [self pushViewControllerWithLogin:webView animated:YES];
}

- (void)presentFilterViewController {
    NSUInteger filterFields = FMFilterFieldLocation | FMFilterFieldStatus | FMFilterFieldPrice |
            FMFilterFieldCategory | FMFilterFieldTrade;
    FMFilterViewController *filterViewController = [[FMFilterViewController alloc] initWithFilterFields:filterFields];
    filterViewController.searchParameter = _searchCondition;
    [filterViewController setFilterDone:^{
        [self loadingView];
        [self requestItem:NO];
    }];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:filterViewController];
    [self.navigationController presentViewController:nav
                                            animated:YES
                                          completion:nil];
}

#pragma mark -- request
- (void)requestItem:(BOOL)isRequestMore {
    if (isRequestMore) {
        _searchCondition.pageNumber++;
        NSNumber *pageNumber = [_searchDictionary objectForKey:@"pageNumber"] ? : [NSNumber numberWithUnsignedInteger:1];
        pageNumber = [NSNumber numberWithUnsignedInteger:[pageNumber unsignedIntegerValue] + 1];
        [_searchDictionary setObject:pageNumber
                              forKey:@"pageNumber"];
    } else {
        _searchCondition.pageNumber = 1;
        [_searchDictionary setObject:[NSNumber numberWithUnsignedInteger:1]
                              forKey:@"pageNumber"];
    }
    id searchParameter = _searchCondition ? [_searchCondition copy] : _searchDictionary;
    id selfProxy = self.proxyObject;
    [[FMSearchService proxyObject]
            searchItems:searchParameter
                 result:^(BOOL isSuccess, FMItemDOList *itemDOList, NSString *errorMsg) {
                     [selfProxy requestItemFinish:itemDOList
                                    isRequestMore:isRequestMore
                                        isSuccess:isSuccess
                                         errorMsg:errorMsg];
                 }];
}

- (void)requestItemFinish:(FMItemDOList *)itemDOList
            isRequestMore:(BOOL)isRequestMore
                isSuccess:(BOOL)isSuccess
                 errorMsg:(NSString *)errorMsg {
    [super requestItemFinish:itemDOList
               isRequestMore:isRequestMore
                   isSuccess:isSuccess
                    errorMsg:errorMsg];

    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)requestComment:(NSString *)id row:(NSUInteger)row {
    [[FMItemCommentService proxyObject]
            getComments:id
                   page:[NSString stringWithFormat:@"%d", 1]
                 result:^(BOOL isSuccess, FMItemCommentDOList *itemCommentDOList, NSString *errMsg) {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         if (isSuccess && itemCommentDOList.items.count > 0) {
                             FMItemDO *itemDO = [self.listDO.items objectAtIndex:row];
                             itemDO.itemCommentDOList = itemCommentDOList;
                             [self.listView refreshRow:row];
                         }
                     }
                     );
                 }];
}

- (void)loadingView {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"加载中...";
}

- (void)searchWithKeyword:(NSString *)keyword {
    _searchCondition.keyword = keyword;
    [self requestItem:NO];
    [self loadingView];
}

- (void)requestFlagWithNick {
    [FMUserService
            getUserFlagWithNick:_itemDO.userNick
                         result:^(NSArray *array) {
                             [self.listView setSellerFlags:array];
                             [self requestVipWithNick];
                         }];
}

- (void)requestVipWithNick {
    [FMUserService
            getUserInfo:_itemDO.userNick
                success:^(id data) {
                    [self.listView setSellerVip:data];
                }
                 failed:^(NSString *error) {

                 }];
}

@end