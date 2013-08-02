// 
// Created by henson on 7/10/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>
#import "FMAnimationTableViewCell.h"

@class FMHomeItemDO;
@class FMHomeRowDO;

@interface FMHomeThreeItemsCell : FMAnimationTableViewCell

- (void)setData:(FMHomeRowDO *)rowDO;

- (void)setTouchAction:(void (^)(FMHomeItemDO *homeItemDO))block;

@end