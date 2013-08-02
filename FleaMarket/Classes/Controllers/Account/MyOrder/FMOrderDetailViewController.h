// 
// Created by henson on 5/8/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>
#import "FMBaseViewController.h"

@interface FMOrderDetailViewController : FMBaseViewController <UITableViewDelegate, UITableViewDataSource>

- (id)initWithTid:(long long int)tid itemId:(NSString *)itemId;
@end