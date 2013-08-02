//
// Created by yuanxiao on 13-6-24.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "FMBaseScrollView.h"
#import "FMItemResellCell.h"

@class FMListResultDO;


@interface FMTradeView : FMBaseScrollView

- (id)initWithFrame:(CGRect)frame withCellType:(FMItemResellCellType)cellType;

- (void)setRequestItemsBlock:(void (^)(NSUInteger pageNum, BOOL isRequestMore))block;

- (void)setItemDOList:(FMListResultDO *)listResultDO isRequestMore:(BOOL)isRequestMore;

- (void)scrollToOrderIdItem:(NSString *)orderId;

@end