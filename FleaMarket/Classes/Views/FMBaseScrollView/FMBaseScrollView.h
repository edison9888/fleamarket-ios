//
// Created by yuanxiao on 13-6-8.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "EGORefreshTableHeaderView.h"
#import "TBMBDefaultPage.h"

#define kLoadMoreScrollOffsetHeight     40
#define kFMBaseScrollTitleHeight        kNavigationBarHeight

#define kAccountHeadViewHeight          116
#define kAccountScrollViewHeight        55

#define kMessageTapHeight               55
#define kMessageTitleHeight             (kNavigationBarHeight + kMessageTapHeight)

#define kFMListSortHeight               33
#define kFMBaseScrollListHeight         (kNavigationBarHeight * 2 + kFMListSortHeight)

@interface FMBaseScrollView : TBMBDefaultPage <UITableViewDelegate, UITableViewDataSource, EGORefreshTableHeaderDelegate>

@property (nonatomic) BOOL closeGangedTitle;  //关闭联动title
@property (nonatomic, weak) UILabel *noDataLabel;

- (void)notificationTitle:(CGFloat)offset;

//请求更多，需要子类实现
- (void)requestMore;

//下拉刷新，需要子类实现
- (void)refreshData;

//是否还有下一页，需要子类实现
- (BOOL)hasNextPage;

//请求完成，需要子类调，停止菊花等
- (void)requestFinish:(BOOL)isMore;

//设置moreView的背景颜色，需要子类调
- (void)setMoreViewBGColor:(UIColor *)bgColor;

- (void)addEGORefresh:(UITableView *)tableView;

- (void)addMoreView:(UITableView *)tableView;

- (void)initNoDataLabel:(UITableView *)scrollView text:(NSString *)text;

- (void)scrollViewDidEndAnimation:(UITableView *)tableView;

@end