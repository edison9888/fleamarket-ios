//
// Created by yuanxiao on 13-6-24.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class FMOrderList;

typedef enum {
    FMItemResellCellBuyTrade = 0,
    FMItemResellCellSoldTrade,
} FMItemResellCellType;


@interface FMItemResellCell : UITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style;

- (void)setData:(FMOrderList *)orderList type:(FMItemResellCellType)type;

@end