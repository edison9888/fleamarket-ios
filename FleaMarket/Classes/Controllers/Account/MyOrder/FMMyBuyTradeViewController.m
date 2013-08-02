//
// Created by yuanxiao on 13-6-30.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "FMMyBuyTradeViewController.h"
#import "FMTradeView.h"
#import "FMTradesService.h"
#import "TBMBSimpleStaticCommand+TBMBProxy.h"
#import "TBMBDefaultRootViewController+TBMBProxy.h"
#import "FMWebviewController.h"
#import "FMTradeDO.h"


@implementation FMMyBuyTradeViewController {

@private
    FMTradeView *_tradeView;
    BOOL _isFirstLoad;
}

- (void)initNavigationBar {
    [self setTitle:@"已买到"];
    self.leftBarButton.hidden = NO;
}

- (void)loadView {
    [super loadView];
    [self initNavigationBar];

    __weak FMMyBuyTradeViewController *weakSelf = self;
    FMTradeView *tradeView = [[FMTradeView alloc] initWithFrame:CGRectMake(0, 0, FM_SCREEN_WIDTH, FM_SCREEN_HEIGHT - 20)
                                                   withCellType:FMItemResellCellBuyTrade];
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
            getTradeBought:pageNum
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

- (void)$$pushOrderDetail:(id <TBMBNotification>)notification  orderDetail:(FMOrderDetail *)orderDetail  {
    if (!self.showing) {
        return;
    }
    FMWebViewController *webView = [[FMWebViewController alloc] init];
    webView.webViewType = FMWebViewTypeRequest;
    webView.url = [FMTradesService getTradeDetail:orderDetail.oid];
    webView.clearCookie = YES;
    webView.title = @"订单详情";
    [self.navigationController pushViewController:webView animated:YES];
}

@end