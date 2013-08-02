//
// Created by yuanxiao on 13-6-24.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <MBMvc/TBMBBind.h>
#import "FMTradeView.h"
#import "FMStyle.h"
#import "FMTradeDO.h"
#import "TBMBGlobalFacade.h"

#define FMMySoldTradeCellHeight  220

@implementation FMTradeView {
@private
    UITableView *_tableView;
    FMListResultDO *_listResultDO;

    NSUInteger _pageNum;

    void (^_requestItemBlock)(NSUInteger pageNum, BOOL isRequestMore);

    FMItemResellCellType _cellType;
}

- (id)initWithFrame:(CGRect)frame withCellType:(FMItemResellCellType)cellType {
    if (self = [super initWithFrame:frame]) {
        _pageNum = 1;
        _cellType = cellType;

        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)
                                                              style:UITableViewStylePlain];
        tableView.contentInset = UIEdgeInsetsMake(kFMBaseScrollTitleHeight, 0, 0, 0);
        tableView.backgroundColor = [FMColor instance].viewControllerBgColor;
        tableView.backgroundView = nil;
        TBMBAutoNilDelegate(UITableView *, tableView, delegate, self);
        TBMBAutoNilDelegate(UITableView *, tableView, dataSource, self);
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.showsVerticalScrollIndicator = NO;
        [self addSubview:tableView];
        _tableView = tableView;

        self.closeGangedTitle = YES;
        [self addMoreView:tableView];
        [self addEGORefresh:tableView];
        [self initNoDataLabel:tableView text:[self getNoDataText:cellType]];
    }
    return self;
}

- (NSString *)getNoDataText:(FMItemResellCellType)cellType {
    if (cellType == FMItemResellCellBuyTrade) {
        return @"亲，你还没有买到宝贝，快去逛逛吧~";
    } else if (cellType == FMItemResellCellSoldTrade) {
        return @"亲，你还没有售出宝贝哦~";
    }
    return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return FMMySoldTradeCellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _listResultDO.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"tradeItemCell";
    FMItemResellCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[FMItemResellCell alloc]
                initWithStyle:UITableViewCellStyleDefault
              reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [cell setData:[_listResultDO.data objectAtIndex:(NSUInteger )indexPath.row] type:_cellType];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FMOrderList *orderList = [_listResultDO.data objectAtIndex:(NSUInteger )indexPath.row];
    FMOrderDetail *orderDetail = [orderList.orders.order objectAtIndex:0];
    TBMBGlobalSendNotificationForSELWithBody(@selector($$pushOrderDetail:orderDetail:),
            orderDetail);
}

- (void)setRequestItemsBlock:(void (^)(NSUInteger pageNum, BOOL isRequestMore))block {
    _requestItemBlock = block;
}

- (void)setItemDOList:(FMListResultDO *)listResultDO isRequestMore:(BOOL)isRequestMore {
    if (!listResultDO) {
        [self requestFinish:isRequestMore];
        return;
    }
    if (!isRequestMore) {
        _listResultDO = listResultDO;
    } else {
        [_listResultDO.data addObjectsFromArray:listResultDO.data];
    }

    [self requestFinish:isRequestMore];
    [_tableView reloadData];
}

- (void)scrollToOrderIdItem:(NSString *)orderId {
    for (NSUInteger i = 0; i < _listResultDO.data.count; i++) {
        FMOrderList *orderList = [_listResultDO.data objectAtIndex:i];
        FMOrderDetail *orderDetail = [orderList.orders.order objectAtIndex:0];
        if ([orderDetail.oid isEqualToString:orderId]) {
            [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:NO];
            break;
        }
    }
}

- (void)requestFinish:(BOOL)isMore {
    [super requestFinish:isMore];
    if (_listResultDO.data.count == 0) {
        self.noDataLabel.hidden = NO;
    } else {
        self.noDataLabel.hidden = YES;
    }
}

- (BOOL)hasNextPage {
    return [_listResultDO isNext];
}

- (void)requestMore {
    if (_requestItemBlock) {
        _pageNum++;
        _requestItemBlock(_pageNum, YES);
    }
}

- (void)refreshData {
    if (_requestItemBlock) {
        _pageNum = 1;
        _requestItemBlock(_pageNum, NO);
    }
}

@end