// 
// Created by henson on 6/19/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import "FMBaseViewController.h"
#import "FMItemDO.h"

@interface FMItemBuyViewController : FMBaseViewController <UITableViewDelegate,
        UITableViewDataSource,
        UITextFieldDelegate,
        FMNeedLoginProtocol,
FMNeedClosePanWithSidePanel>

@property(nonatomic, assign) BOOL isFromTheme;

- (id)initWithItemDO:(FMItemDO *)itemDO;

+ (id)controllerWithItemDO:(FMItemDO *)itemDO;

@end