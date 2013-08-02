// 
// Created by henson on 6/27/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>
#import "FMBaseViewController.h"
#import "FMDeliveryDO.h"

@interface FMDeliveryAddressViewController : FMBaseViewController <FMNeedClosePanWithSidePanel>

- (void)setSelectAction:(void (^)(FMDeliveryDO *))block;

@end