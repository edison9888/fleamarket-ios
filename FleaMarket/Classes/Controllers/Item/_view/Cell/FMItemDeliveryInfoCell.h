// 
// Created by henson on 6/27/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>
#import "FMBaseTableViewCell.h"

@class FMDeliveryDO;

@interface FMItemDeliveryInfoCell : FMBaseTableViewCell

+ (float)cellHeight:(FMDeliveryDO *)deliveryDO;

- (void)setDeliveryDO:(FMDeliveryDO *)deliveryDO;

@end