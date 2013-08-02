// 
// Created by henson on 6/8/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import "FMSidePanelBaseViewController.h"
#import "TBSocialShareToBase.h"

@class FMItemDO;

@interface FMItemDetailViewController : FMSidePanelBaseViewController <UITableViewDelegate, UITableViewDataSource,
        TBSocialShareResultProtocol>

@property(nonatomic, strong) FMItemDO *itemDO;
@property(nonatomic, assign) BOOL isScrollToComment;
@property(nonatomic, assign) BOOL isFromTheme;

- (id)initWithItemDO:(FMItemDO *)itemDO;

- (id)initWithItemId:(NSString *)itemId;

+ (id)controllerWithItemDO:(FMItemDO *)itemDO;

@end