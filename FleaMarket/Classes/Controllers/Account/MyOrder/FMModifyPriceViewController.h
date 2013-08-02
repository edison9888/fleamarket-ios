// 
// Created by henson on 4/23/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>
#import "FMBaseViewController.h"

@class FMOrderList;

@interface FMModifyPriceViewController : FMBaseViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property(nonatomic, strong) FMOrderList *orderList;

@end