//
// Created by yuanxiao on 13-6-24.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "FMSidePanelBaseViewController.h"


@interface FMMySoldTradeViewController : FMSidePanelBaseViewController

@property (nonatomic, copy) NSString *orderId;

- (void)refreshData;

@end