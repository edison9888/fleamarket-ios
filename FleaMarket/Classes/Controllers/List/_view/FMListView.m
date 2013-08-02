//
// Created by yuanxiao on 13-6-14.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <MBMvc/TBMBBind.h>
#import <MBMvc/TBMBGlobalFacade.h>
#import "FMListView.h"
#import "FMStyle.h"
#import "FMImageView.h"
#import "FMListItemCell.h"
#import "FMItemCommentDO.h"
#import "FMItemDO.h"
#import "FMCommentView.h"
#import "FMAccountScrollView.h"
#import "FMAccountHeadView.h"
#import "FMAccountViewController.h"
#import "FMItemTitleView.h"
#import "FMSellerTitleView.h"


@implementation FMListView {
@private
    UITableView *_tableView;

    FMItemDOList *_listDO;

    NSString *_titleUrl;
    FMListType _listType;

    void (^_requestItemBlock)(FMListView *listView, BOOL isRequestMore);
    void (^_requestCommentBlock)(NSString *id, NSUInteger row);

    FMAccountInfo *_accountInfo;

    __weak FMSellerTitleView *_sellerView;
}

@synthesize titleUrl = _titleUrl;
@synthesize listDO = _listDO;
@synthesize accountInfo = _accountInfo;

- (id)initWithFrame:(CGRect)frame listType:(FMListType)listType {
    if (self = [super initWithFrame:frame]) {
        _listType = listType;
        self.backgroundColor = [FMColor instance].viewControllerBgColor;

        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)
                                                              style:UITableViewStylePlain];
        tableView.contentInset = UIEdgeInsetsMake([self topInsets], 0, 0, 0);
        tableView.backgroundColor = [UIColor whiteColor];
        TBMBAutoNilDelegate(UITableView *, tableView, delegate, self);
        TBMBAutoNilDelegate(UITableView *, tableView, dataSource, self);
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.showsVerticalScrollIndicator = NO;
        tableView.hidden = YES;
        [self addSubview:tableView];
        _tableView = tableView;

        [self addMoreView:tableView];
        [self addEGORefresh:tableView];
        [self initNoDataLabel:tableView text:[self getNoDataText:listType]];
    }
    return self;
}

- (CGFloat)topInsets {
    CGFloat topInsets = kFMBaseScrollTitleHeight;
    if (_listType == FMListTypeSearch) {
        topInsets = kFMBaseScrollListHeight;
    }
    return topInsets;
}

- (NSString *)getNoDataText:(FMListType)listType {
    if (listType == FMListTypeCollect) {
        return @"亲，你还没有收藏宝贝哦~";
    } else if (listType == FMListTypeSearch) {
        return @"亲，暂时没有你想要的宝贝哦~";
    } else if (listType == FMListTypeSell) {
        return @"亲，你还没有发布宝贝，快去发布吧~";
    }  else if (listType == FMListTypeTheme) {
        return @"亲，暂时没有主题相关宝贝~";
    } else if (listType == FMListTypeSearchSeller) {
        return @"亲，该卖家没有在售宝贝";
    }
    return @"";
}

- (void)setTitleUrl:(NSString *)titleUrl {
    if (titleUrl) {
        FMImageView *itemBannerImageView = [[FMImageView alloc] initWithFrame:CGRectMake(0, 0, FM_SCREEN_WIDTH, 120)];
        [itemBannerImageView setWebPImageWithURL:titleUrl
                                  imageScaleType:FMImageScaleNone
                                placeholderImage:FMPlaceholderImage];
        _tableView.tableHeaderView = itemBannerImageView;
    }
}

- (void)setAccountInfo:(FMAccountInfo *)accountInfo {
    _accountInfo = accountInfo;
    UIView *headGroupView = [[UIView alloc] initWithFrame:
            CGRectMake(0, 0, FM_SCREEN_WIDTH, kAccountHeadViewHeight + kAccountScrollViewHeight + 10)];
    headGroupView.backgroundColor = [UIColor clearColor];

    FMAccountScrollView *accountScrollView = [[FMAccountScrollView alloc]
            initWithFrame:CGRectMake(0, kAccountHeadViewHeight, FM_SCREEN_WIDTH, kAccountScrollViewHeight)];
    accountScrollView.accountInfo = _accountInfo;
    [headGroupView addSubview:accountScrollView];

    FMAccountHeadView *headView = [[FMAccountHeadView alloc] initWithFrame:
            CGRectMake(0, 0, FM_SCREEN_WIDTH, kAccountHeadViewHeight)];
    headView.accountInfo = _accountInfo;
    [headGroupView addSubview:headView];

    UILabel *onSellNum = [[UILabel alloc] initWithFrame:
            CGRectMake(10, kAccountHeadViewHeight + kAccountScrollViewHeight, FM_SCREEN_WIDTH, 30)];
    onSellNum.backgroundColor = [UIColor clearColor];
    onSellNum.font = FMFont(NO, 12);
    TBMBBindObjectWeak(tbKeyPath(self, listDO.totalCount), onSellNum, ^(UILabel *host, id old, id new) {
        NSInteger count = [new intValue];
        if (count > 0) {
            host.text = [NSString stringWithFormat:@"%d件在售宝贝", count];
        } else {
            host.text = @"";
        }
    }
    );
    [headGroupView addSubview:onSellNum];

    _tableView.tableHeaderView = headGroupView;
}

//搜卖家
- (void)setSearchSellerWithItemDO:(FMItemDO *)itemDO {
    FMSellerTitleView *sellerView = [[FMSellerTitleView alloc]
            initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width, 94)
               withItemDO:itemDO];
    sellerView.listDO = _listDO;
    _sellerView = sellerView;
    _tableView.tableHeaderView = sellerView;
}

- (void)setSellerFlags:(NSArray *)array {
    if (array && array.count > 0) {
        [_sellerView setFlagArray:array];
    }
}

- (void)setSellerVip:(id)data {
    [_sellerView setSellerVip:data];
}

- (void)setRequestItemsBlock:(void (^)(FMListView *listView, BOOL isRequestMore))block {
    _requestItemBlock = block;
}

- (void)setRequestCommentBlock:(void (^)(NSString *id, NSUInteger row))block {
    _requestCommentBlock = block;
}

- (void)refreshRow:(NSUInteger)row {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [_tableView beginUpdates];
    [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                          withRowAnimation:UITableViewRowAnimationFade];
    [_tableView endUpdates];
}

- (void)refreshCollect:(FMItemDO *)itemDO {
    NSArray *cellArray= [self getVisibleRowsArray];
    for (NSIndexPath *indexPath in cellArray) {
        NSUInteger row = (NSUInteger )indexPath.row;
        FMItemDO *DO = [_listDO.items objectAtIndex:row];
        if ([DO.id isEqualToString:itemDO.id]) {
            if (_listType == FMListTypeCollect) {
                [_listDO.items removeObject:DO];
                [_tableView beginUpdates];
                [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
                [_tableView endUpdates];
                if (_listDO.items.count == 0) {
                    self.noDataLabel.hidden = NO;
                } else if (_listDO.items.count == 1) {
                    [self notificationTitle:-(_tableView.contentInset.top + kNavigationBarShadeHeight)];
                }
            } else {
                FMListItemCell *cell = (FMListItemCell *)[_tableView cellForRowAtIndexPath:indexPath];
                [cell refreshCollect];
            }
            break;
        }
    }
}

- (NSArray *)getVisibleRowsArray {
    NSArray *cellArray = [_tableView indexPathsForVisibleRows];
    if (!cellArray || cellArray.count == 0) {
        cellArray = [_tableView visibleCells];
    }
    return cellArray;
}

- (void)refreshTableView:(BOOL)isRequestMore{
    _tableView.hidden = NO;
    if (_listDO.items.count < 1) {
        [self notificationTitle:-(_tableView.contentInset.top + kNavigationBarShadeHeight)];
    }
    [_tableView reloadData];

    if (_listDO && _listDO.items.count > 0 && !isRequestMore && _listType == FMListTypeSearch) {
        NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [_tableView scrollToRowAtIndexPath:topIndexPath
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:YES];
    }
    [self requestFinish:isRequestMore];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    FMItemDO *itemDO = [_listDO.items objectAtIndex:(NSUInteger )indexPath.row];
    CGFloat height = kListItemCellBaseHeight + [FMItemTitleView getHeight:itemDO];
    if ([itemDO.commentNum intValue] > 1) {
        height += kListItemCellMoreCommentHeight;
    }
    if (itemDO.itemCommentDOList.items.count > 0) {
        height += [FMCommentView cellHeight:[itemDO.itemCommentDOList.items objectAtIndex:0]];
    }
    return height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _listDO.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"listItemCell";
    FMListItemCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[FMListItemCell alloc]
                initWithStyle:UITableViewCellStyleDefault
              reuseIdentifier:cellIdentifier
                     listType:_listType];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [cell setData:[_listDO.items objectAtIndex:(NSUInteger )indexPath.row] serverTime:_listDO.serverTime];
    return cell;
}

- (void)scrollViewDidEndAnimation:(UITableView *)scrollView {
    [super scrollViewDidEndAnimation:scrollView];
    NSArray *cellArray = [self getVisibleRowsArray];
    for (NSIndexPath *indexPath in cellArray) {
        NSUInteger row = (NSUInteger )indexPath.row;
        FMItemDO *itemDO = [_listDO.items objectAtIndex:row];
        if (!itemDO.itemCommentDOList && [itemDO.commentNum intValue] > 1) {
            if (_requestCommentBlock) {
                _requestCommentBlock(itemDO.id, row);
            }
        }
    }
}

- (void)requestFinish:(BOOL)isMore {
    [super requestFinish:isMore];
    if (_listDO.items.count == 0) {
        if (_tableView.tableHeaderView) {
            self.noDataLabel.frame = CGRectMake(0, _tableView.tableHeaderView.frame.size.height,
                    _tableView.frame.size.width, 40);
        }
        self.noDataLabel.hidden = NO;
        _tableView.tableFooterView = nil;
    } else {
        self.noDataLabel.hidden = YES;
    }
}

- (BOOL)hasNextPage {
    return _listDO.nextPage;
}

- (void)requestMore {
    if (_requestItemBlock) {
        _requestItemBlock(self, YES);
    }
}

- (void)refreshData {
    if (_requestItemBlock) {
        _requestItemBlock(self, NO);
    }
}

- (void)dealloc {
    FMLog(@"%@ dealloc", NSStringFromClass([self class]));
}

@end