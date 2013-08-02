// 
// Created by henson on 6/7/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>
#import "FMAnimationTableViewCell.h"

typedef NS_ENUM(NSInteger, FMHomeItemCellLayoutType)
{
    FMHomeItemCellLeft = 0,
    FMHomeItemCellRight,
};
@class FMHomeRowDO;
@class FMHomeItemDO;

@interface FMHomeItemCell : FMAnimationTableViewCell

- (void)setTouchAction:(void (^)(FMHomeItemDO * homeItemDO))block;

- (void)setData:(FMHomeRowDO *)rowDO;

@end