//
// Created by yuanxiao on 13-6-8.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <MBMvc/TBMBGlobalFacade.h>
#import "FMSearchBarView.h"
#import "NSString+Helper.h"
#import "UIImage+Helper.h"
#import "FMSearchHistoryService.h"
#import "FMBaseTableViewCell.h"
#import "FMTipsService.h"
#import "FMStyle.h"


#define kSearchBarHeight  44

@implementation FMSearchBarView {
@private
    UIView *_searchBarContainView;
    UISearchBar *_searchBar;
    UIButton *_cancelButton;

    UITableView *_tableView;
    NSMutableArray *_dataSource;

    NSString *_preKeyword;

    void (^_searchData)(NSString *keyword);
    void (^_filterBlock)();

    CGRect selfFrame;
    CGRect selfSuperFrame;
    FMSearchBarType _searchBarType;

    BOOL _isEditor;
}

- (id)initWithFrame:(CGRect)frame searchBarType:(FMSearchBarType)barType {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        _searchBarType = barType;
        selfFrame = frame;

        self.backgroundColor = [UIColor whiteColor];
        _searchBarContainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, FM_SCREEN_WIDTH, kSearchBarHeight)];
        _searchBarContainView.backgroundColor = FMColorWithRed(235, 235, 235);
        [self addSubview:_searchBarContainView];

        _searchBar = [self _searchBar];
        [_searchBarContainView addSubview:_searchBar];

        _cancelButton = [self _cancelButton];
        _cancelButton.hidden = !(_searchBarType == FMSearchBarTypeSearchResult);
        [_searchBarContainView addSubview:_cancelButton];
        [self setCancelTitle:YES];

        _dataSource = [NSMutableArray arrayWithCapacity:10];
    }
    return self;
}

- (CGFloat)getSearBarHeight:(BOOL)isInit {
    if (!isInit) {
        return 250;
    }
   return _searchBarType == FMSearchBarTypeSearchResult ? 250 : 310;
}

- (void)setCancelTitle:(BOOL)isInit {
    if (!isInit) {
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    } else {
        NSString *title = _searchBarType == FMSearchBarTypeSearchResult ? @"筛选" : @"取消";
        [_cancelButton setTitle:title forState:UIControlStateNormal];
    }
}

- (UISearchBar *)_searchBar {
    CGRect searchBarRect = {{5, (kSearchBarHeight - 30) / 2}, {[self getSearBarHeight:YES], 30}};
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:searchBarRect];
    searchBar.backgroundColor = [UIColor clearColor];
    searchBar.placeholder = @"请输入宝贝关键词";
    searchBar.delegate = self;
    for (UIView *subview in searchBar.subviews) {
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
            [subview removeFromSuperview];
        }
    }
    return searchBar;
}

- (UIButton *)_cancelButton {
    CGRect cancelButtonRect = {{260, (kSearchBarHeight - 30) / 2}, {47, 30}};
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = cancelButtonRect;
    [button setBackgroundImage:[[UIImage imageNamed:@"white_btn.png"]
            resizeImageWithCapInsets:UIEdgeInsetsMake(5, 4, 5, 5)]
                      forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self
               action:@selector(cancelButtonAction)
     forControlEvents:UIControlEventTouchUpInside];
    [button.titleLabel setFont:[UIFont systemFontOfSize:14.f]];
    return button;
}

- (void)cancelButtonAction {
    if (_filterBlock && ![_searchBar isFirstResponder] && !_isEditor
            && _searchBarType == FMSearchBarTypeSearchResult) {
        _filterBlock();
        return;
    }
    [self _cancelSearch];
    _searchBar.text = _preKeyword;
}

- (void)_cancelSearch {
    [self setCancelTitle:YES];

    [self setSuperview:YES];
    TBMBGlobalSendNotificationForSELWithBody(@selector($$receiveScrollTitle:offset:),
            [NSNumber numberWithFloat:-kNavigationBarHeight]);
    [self resetFrame];

    _cancelButton.hidden = !(_searchBarType == FMSearchBarTypeSearchResult);
    _tableView.hidden = YES;

    _isEditor = NO;
    [_searchBar resignFirstResponder];
}

- (void)resetFrame {
    CGRect searchBarRect = {_searchBar.frame.origin, {[self getSearBarHeight:YES], _searchBar.frame.size.height}};
    _searchBar.frame = searchBarRect;

    self.frame = selfFrame;
}

- (void)setSearchBlock:(void (^)(NSString *keyword))block {
    _searchData = block;
}

- (void)setFilterBlock:(void (^)())block {
    _filterBlock = block;
}

- (void)setKeyword:(NSString *)keyword {
    _keyword = keyword;
    _searchBar.text = _keyword;
    _preKeyword = _keyword;
}

#pragma mark - search bar delegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [self setCancelTitle:NO];

    [self setAnimation:searchBar];

    _isEditor = YES;
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if ([searchBar.text isBlank]) {
        return;
    }

    [self _cancelSearch];

    [self searchDada:_searchBar.text];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    _tableView.hidden = YES;

    [self setAnimation:searchBar];

    _isEditor = YES;
}

- (void)setAnimation:(UISearchBar *)searchBar {
    if (_isEditor) {
        [self _showTableView:searchBar];
        return;
    }
    //设置父类
    [self setSuperview:NO];
    TBMBGlobalSendNotificationForSELWithBody(@selector($$receiveScrollTitle:offset:),
            [NSNumber numberWithFloat:kNavigationBarHeight]);
    self.frame = CGRectMake(0, selfFrame.origin.y, FM_SCREEN_WIDTH, FM_SCREEN_HEIGHT - 20);
    CGRect searchBarRect = {_searchBar.frame.origin, {[self getSearBarHeight:NO], _searchBar.frame.size.height}};
    _searchBar.frame = searchBarRect;

    [self _showTableView:searchBar];
    _cancelButton.hidden = NO;
}

- (void)_showTableView:(UISearchBar *)searchBar {
    if (_searchBarType == FMSearchBarTypeResell) {
        return;
    }
    NSString *text = searchBar.text;
    if (text == nil || [text isBlank]) {
        [self _showTableViewWithFlag:YES];
    } else {
        [self _showTableViewWithFlag:NO];
    }
}

- (void)setSuperview:(BOOL)flag {
    if (flag) {
        self.superview.frame = selfSuperFrame;
    } else {
        selfSuperFrame = self.superview.frame;
        self.superview.frame = CGRectMake(0, 0, FM_SCREEN_WIDTH, FM_SCREEN_HEIGHT - 20);
    }

    if (_searchBarType == FMSearchBarTypeSearchResult) {
        UITableView *tableView = (UITableView *)self.superview;
        while (tableView != nil) {
            if ([tableView isKindOfClass:[UITableView class]]) {
                tableView.scrollEnabled = flag;
                break;
            }
            tableView = (UITableView *)tableView.superview;
        }
    }
}

- (void)refreshData:(BOOL)flag {
    if (flag) {
        NSArray *array = [[FMSearchHistoryService instance] getAllSearchHistories];
        [self refreshTableView:array];
    } else {
        [FMTipsService getSearchTips:_searchBar.text result:^(NSArray *tips) {
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:10];
            for (id tip in tips) {
                [array addObject:[tip objectForKey:@"keyword"]];
            }
            [self refreshTableView:array];
        }];
    }
}

- (void)refreshTableView:(NSArray *)array {
    [_dataSource removeAllObjects];
    [_dataSource addObjectsFromArray:array];
    [_tableView reloadData];
}

- (void)_showTableViewWithFlag:(BOOL)flag {
    if (!_tableView) {
        CGFloat height = self.frame.size.height - kSearchBarHeight;
        if (_searchBarType == FMSearchBarTypeSearch) {
            height -= kNavigationBarHeight;
        }
        _tableView = [[UITableView alloc]
                initWithFrame:CGRectMake(0, kSearchBarHeight, FM_SCREEN_WIDTH, height)
                        style:UITableViewStylePlain];
        _tableView.backgroundView = nil;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollsToTop = NO;

        [self addSubview:_tableView];
    }

    _tableView.hidden = NO;
    [self refreshData:flag];
    [self bringSubviewToFront:_tableView];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger row = 0;
    if (_searchBar.text == nil || [_searchBar.text isBlank]) {
        row = 1;
    }
    if (_dataSource && [_dataSource count] > 0) {
        return [_dataSource count] + row;
    }
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SearchHistoriesCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[FMBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
        cell.backgroundView = nil;
        cell.textLabel.textColor = [FMColor instance].cellColor;
        cell.textLabel.font = [FMFontSize instance].cellLabelSize;
    }
    if (indexPath.row == _dataSource.count) {
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.accessoryType = UITableViewCellAccessoryNone;
        if (!_dataSource || _dataSource.count < 1) {
            cell.textLabel.text = @"无搜索历史";
        } else {
            cell.textLabel.text = @"清除搜索历史";
        }
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        NSString *keyword = [_dataSource objectAtIndex:(NSUInteger) indexPath.row];
        cell.textLabel.text = keyword;
    }

    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:tableView.indexPathForSelectedRow animated:NO];
    if (indexPath.row == _dataSource.count) {
        if (!_dataSource || _dataSource.count < 1) {
            return;
        }
        [_dataSource removeAllObjects];
        [[FMSearchHistoryService instance] removeAllSearchHistories];
        [tableView reloadData];
        return;
    }

    NSString *keyword = [_dataSource objectAtIndex:(NSUInteger) indexPath.row];
    [self _cancelSearch];
    _searchBar.text = keyword;

    [self searchDada:keyword];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_searchBar resignFirstResponder];
}

- (void)searchDada:(NSString *)keyword {
    [[FMSearchHistoryService instance] addSearchHistory:keyword];
    _preKeyword = [keyword copy];

    if (_searchData) {
        _searchData(keyword);
    }
}

- (void)dealloc {
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
}

@end