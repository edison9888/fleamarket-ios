//
// Created by yuanxiao on 13-6-24.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <MBMvc/TBMBDefaultRootViewController+TBMBProxy.h>
#import "FMMySoldTradeViewController.h"
#import "FMTradeDO.h"
#import "FMTradesService.h"
#import "TBMBSimpleStaticCommand+TBMBProxy.h"
#import "FMTradeView.h"
#import "FMShipmentsViewController.h"
#import "FMModifyPriceViewController.h"
#import "FMCloseTradeViewController.h"
#import "FMOrderDetailViewController.h"


@implementation FMMySoldTradeViewController {
@private
    FMTradeView *_tradeView;
    BOOL _isFirstLoad;
}

- (void)initNavigationBar {
    [self setTitle:@"已售出"];
    self.leftBarButton.hidden = NO;
}

- (void)loadView {
    [super loadView];
    [self initNavigationBar];

    __weak FMMySoldTradeViewController *weakSelf = self;
    FMTradeView *tradeView = [[FMTradeView alloc] initWithFrame:CGRectMake(0, 0, FM_SCREEN_WIDTH, FM_SCREEN_HEIGHT - 20)
                                                   withCellType:FMItemResellCellSoldTrade];
    [self.view addSubview:tradeView];
    [tradeView setRequestItemsBlock:^(NSUInteger pageNum, BOOL isRequestMore) {
        [weakSelf requestData:pageNum isRequestMore:isRequestMore];
    }];

    _tradeView = tradeView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showPageLoadingView];
    [self requestData:1 isRequestMore:NO];
    _isFirstLoad = YES;
}

- (void)refreshData {
    [self requestData:1 isRequestMore:NO];
}

- (void)requestData:(NSUInteger )pageNum isRequestMore:(BOOL)isRequestMore {
    id selfProxy = self.proxyObject;
    [[FMTradesService proxyObject]
            getTradeSold:pageNum
              withResult:[^(FMListResultDO *resultDO) {
                  [selfProxy receiveIdleUserSold:resultDO
                                          isMore:isRequestMore];
              } copy]];
}

- (void)receiveIdleUserSold:(FMListResultDO *)result isMore:(BOOL)isMore {
    [_tradeView setItemDOList:result isRequestMore:isMore];
    if (_isFirstLoad && _orderId) {
        _isFirstLoad = NO;
        [_tradeView scrollToOrderIdItem:_orderId];
    }
    [self removePageLoadingView];
}

#pragma mark -- nav
- (void)$$pushShipmentsViewController:(id <TBMBNotification>)notification orderList:(FMOrderList *)orderList {
    if (!self.showing) {
        return;
    }
    FMShipmentsViewController *shipmentsViewController = [[FMShipmentsViewController alloc]
            initWithTid:[orderList.tid longLongValue] itemId:orderList.num_iid from:FMShipmentDefault];
    [self.navigationController pushViewController:shipmentsViewController animated:YES];
}

- (void)$$pushModifyPriceViewController:(id <TBMBNotification>)notification orderList:(FMOrderList *)orderList {
    if (!self.showing) {
        return;
    }
    FMModifyPriceViewController *modifyPriceViewController = [[FMModifyPriceViewController alloc] init];
    modifyPriceViewController.orderList = orderList;
    [self.navigationController pushViewController:modifyPriceViewController animated:YES];
}

- (void)$$pushCloseTradeViewController:(id <TBMBNotification>)notification orderList:(FMOrderList *)orderList {
    if (!self.showing) {
        return;
    }
    FMCloseTradeViewController *closeTradeViewController = [[FMCloseTradeViewController alloc] init];
    closeTradeViewController.orderList = orderList;
    [self.navigationController pushViewController:closeTradeViewController animated:YES];
}

- (void)$$pushOrderDetail:(id <TBMBNotification>)notification orderDetail:(FMOrderDetail *)orderDetail {
    if (!self.showing) {
        return;
    }
    FMOrderDetailViewController *orderDetailViewController = [[FMOrderDetailViewController alloc]
            initWithTid:[orderDetail.oid longLongValue] itemId:orderDetail.num_iid];
    [self.navigationController pushViewController:orderDetailViewController animated:YES];
}

@end