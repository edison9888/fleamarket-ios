// 
// Created by henson on 4/10/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import "FMBaseViewController.h"

@class FMLogisticsCompanyDO;

@interface FMLogisticsCompaniesViewController : FMBaseViewController <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, copy) void (^selectedAction)(FMLogisticsCompanyDO *);

@end