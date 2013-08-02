//
// Created by yuanxiao on 13-6-8.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import <TaobaoRemoteObject/TBROSync.h>
#import <MBMvc/TBMBBind.h>
#import "FMBaseScrollView.h"
#import "TBMBGlobalFacade.h"
#import "FMStyle.h"
#import "FMImageView.h"


@implementation FMBaseScrollView {
@private
    CGFloat _startY;
    BOOL _isNeedLoadMore;

    UIView *_moreView;
    UILabel *_moreLabel;
    UIActivityIndicatorView *_indicatorLoading;

    BOOL _isBeginRequestMore;
    BOOL _isLoadingMore;

    CGFloat _titleHeight;

    //ego
    BOOL _reloading;
    __weak UITableView *_tableView;
    EGORefreshTableHeaderView *_refreshHeaderView;

    BOOL _flag;
    BOOL _closeGangedTitle;
    __weak UILabel *_noDataLabel;
}

@synthesize closeGangedTitle = _closeGangedTitle;
@synthesize noDataLabel = _noDataLabel;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

    }
    return self;
}

- (void)initMoreView {
    _moreView = [[UIView alloc] initWithFrame:
            CGRectMake(0, 0, _tableView.frame.size.width, kLoadMoreScrollOffsetHeight)];
    _moreView.backgroundColor = _tableView.backgroundColor;

    _moreLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 7, 100, 25)];
    _moreLabel.font = [FMFontSize instance].loadMoreLabelSize;
    _moreLabel.textColor = [FMColor instance].loadMoreLabelColor;
    _moreLabel.textAlignment = NSTextAlignmentCenter;
    _moreLabel.backgroundColor = [UIColor clearColor];
    [_moreView addSubview:_moreLabel];

    _indicatorLoading = [[UIActivityIndicatorView alloc]
            initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _indicatorLoading.frame = CGRectMake(100, 10, 20, 20);
    [_moreView addSubview:_indicatorLoading];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_flag)
        return;

    //for ego
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];

    CGFloat height = scrollView.contentSize.height - scrollView.frame.size.height;
    //for load more
    if (_isNeedLoadMore) {
        if (!_moreView) {
            [self initMoreView];
        }
        [self scrollViewForMore:scrollView];
    }
    if (!_closeGangedTitle) {
        CGFloat ignoreHeight = scrollView.contentInset.top;
        if (scrollView.contentOffset.y < -ignoreHeight + 1
                || scrollView.contentOffset.y > height + scrollView.contentInset.bottom) {
            //滑到顶了
            return;
        }

        CGFloat offset = scrollView.contentOffset.y - _startY;
        _startY = scrollView.contentOffset.y;

        if ((_titleHeight > ignoreHeight && offset > 0) || (_titleHeight < -ignoreHeight && offset < 0)) {
            return;
        }
        _titleHeight += offset;
        [self notificationTitle:offset];
    }

    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(scrollViewDidEndAnimation:) withObject:scrollView afterDelay:0.0001f];
}

- (void)scrollViewDidEndAnimation:(UIScrollView *)scrollView {
    if (_closeGangedTitle) {
        return;
    }
    //for title
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    CGFloat ignoreHeight = scrollView.contentInset.top;
    if (_titleHeight > 0 && _titleHeight != ignoreHeight) {
        [self notificationTitle:ignoreHeight];
        if (scrollView.contentOffset.y < 0)  {
            if (ignoreHeight == kMessageTitleHeight) {
                [scrollView setContentOffset:CGPointMake(0, -kMessageTapHeight) animated:YES];
            } else {
                [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
            }
        }
        _flag = YES;
        _titleHeight = 0;
    } else if(_titleHeight < 0 && _titleHeight != -ignoreHeight) {
        [self notificationTitle:-ignoreHeight];
        _flag = YES;
        _titleHeight = 0;
    }
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    if (!_closeGangedTitle) {
        [self notificationTitle:-scrollView.contentInset.top];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _startY = scrollView.contentOffset.y;
    _flag = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    //for ego
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];

    //for more
    if (_isNeedLoadMore && !_isLoadingMore && _isBeginRequestMore && [self hasNextPage]) {
        _isLoadingMore = YES;
        _isBeginRequestMore = NO;
        _moreLabel.text = @"加载中...";
        [_indicatorLoading startAnimating];
        _indicatorLoading.hidden = NO;
        [self requestMore];
    }
}

CGFloat _offset;
- (void)notificationTitle:(CGFloat) offset {
    _offset += offset;
    if (_offset >= 1 || _offset <= -1) {
        TBMBGlobalSendNotificationForSELWithBody(@selector($$receiveScroll:offset:),
                [NSNumber numberWithFloat:_offset]);
        _offset = 0;
    }
}

- (void)scrollViewForMore:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y + scrollView.frame.size.height
            <= scrollView.contentSize.height + 15) {
        _isBeginRequestMore = NO;
        if (!_isLoadingMore) {
            if (![self hasNextPage]) {
                _moreLabel.text = @"";
                UIView *view = [[UIView alloc] initWithFrame:
                        CGRectMake(0, 0, scrollView.frame.size.width, 20)];
                ((UITableView *)scrollView).tableFooterView = view;
            } else {
                _moreLabel.text = @"上拉加载更多";
            }
        }
    } else if (scrollView.contentOffset.y + scrollView.frame.size.height >
            scrollView.contentSize.height + 15) {
        if ([self hasNextPage]) {
            if (!_isLoadingMore) {
                _moreLabel.text = @"松开加载更多";
                _isBeginRequestMore = YES;
            }
        }
    }
}

#pragma mark EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
    [self reloadTableViewDataSource];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view {
    return _reloading;
}

- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view {
    return [[TBROSync instance] getDate];
}

- (void)reloadTableViewDataSource {
    _reloading = YES;
    [self refreshData];
}

- (void)doneLoadingTableViewData {
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
    _reloading = NO;
}

- (void)addEGORefresh:(UITableView *)tableView {
    _tableView = tableView;

    _reloading = NO;
    if (_refreshHeaderView == nil) {
        _refreshHeaderView = [[EGORefreshTableHeaderView alloc]
                initWithFrame:CGRectMake(0, 0 - tableView.bounds.size.height,
                        tableView.bounds.size.width, tableView.bounds.size.height)
                   edgeInsets:tableView.contentInset];
        _refreshHeaderView.backgroundColor = tableView.backgroundColor;
        [tableView addSubview:_refreshHeaderView];
        TBMBAutoNilDelegate(EGORefreshTableHeaderView *, _refreshHeaderView, delegate, self);
    }
    [_refreshHeaderView refreshLastUpdatedDate];
}

- (void)addMoreView:(UITableView *)tableView {
    _isNeedLoadMore = YES;
    _tableView = tableView;
    [self initMoreView];
    tableView.tableFooterView = _moreView;
}

- (void)initNoDataLabel:(UIScrollView *)scrollView text:(NSString *)text {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, scrollView.frame.size.width, 40)];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = text;
    label.font = FMFont(NO, 14);
    label.hidden = YES;
    [scrollView addSubview:label];
    _noDataLabel = label;
}

#pragma mark request
- (void)requestFinish:(BOOL)isMore {
    if (isMore) {
        _isLoadingMore = NO;
        [_indicatorLoading stopAnimating];
        _tableView.tableFooterView = _moreView;
        //加载更多，图片闪烁
        [FMImageView setUseAnimation:NO];
        [self performSelector:@selector(closeImageAnimation) withObject:nil afterDelay:0.1];
    } else {
        [self doneLoadingTableViewData];
    }
}

- (void)closeImageAnimation {
    [FMImageView setUseAnimation:YES];
}

- (void)setMoreViewBGColor:(UIColor *)bgColor {
    _moreView.backgroundColor = bgColor;
}

- (void)requestMore {

}

- (void)refreshData {

}

- (BOOL)hasNextPage {
    return NO;
}

@end