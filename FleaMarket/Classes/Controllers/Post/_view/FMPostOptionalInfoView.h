// 
// Created by henson on 6/25/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>

@class FMPostTextIndicationView;
@class FMItemDO;

@interface FMPostOptionalInfoView : UITableView <UITableViewDelegate, UITableViewDataSource,
        UITextFieldDelegate, TBMBMessageReceiver>

@property(nonatomic, strong) FMItemDO *itemDO;
@property(nonatomic, strong) FMPostTextIndicationView *textIndicationView;

- (id)initWithFrame:(CGRect)frame itemDO:(FMItemDO *)itemDO;

- (void)refreshView;

@end