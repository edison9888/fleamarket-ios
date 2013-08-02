// 
// Created by henson on 7/31/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>

@class FMTaoBaoTradeOrder;
@class FMTaoBaoTrade;

@interface FMResellCellBackgroundView : UIView

- (void)setBottomLineHidden:(BOOL)hidden;
@end

@interface FMResellCell : UITableViewCell

- (void)setOrder:(FMTaoBaoTradeOrder *)order endTime:(NSString *)endTime;

@end