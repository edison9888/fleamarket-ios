//
// Created by yuanxiao on 13-7-3.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "FMSidePanelBaseViewController.h"
#import "FMListView.h"

@class FMItemDOList;
@class FMListView;


@interface FMBaseListViewController : FMSidePanelBaseViewController

@property (nonatomic, weak) FMListView *listView;
@property (nonatomic, strong) FMItemDOList *listDO;
@property (nonatomic) FMListType listType;
@property(nonatomic, assign) BOOL isFromTheme;

- (void)requestItem:(BOOL)isRequestMore;

- (void)requestItemFinish:(FMItemDOList *)itemDOList
            isRequestMore:(BOOL)isRequestMore
                isSuccess:(BOOL)isSuccess
                 errorMsg:(NSString *)errorMsg;

@end