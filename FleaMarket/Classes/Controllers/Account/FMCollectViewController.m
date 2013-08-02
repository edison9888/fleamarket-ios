//
// Created by yuanxiao on 13-7-3.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <MBMvc/TBMBDefaultRootViewController+TBMBProxy.h>
#import <MBMvc/TBMBSimpleStaticCommand+TBMBProxy.h>
#import "FMCollectViewController.h"
#import "FMSubscribeService.h"
#import "FMItemDO.h"


@implementation FMCollectViewController {
    NSUInteger _pageNum;
}


- (void)loadView {
    [super loadView];
}


- (void)requestItem:(BOOL)isRequestMore {
    if (isRequestMore) {
        _pageNum++;
    } else {
        _pageNum = 1;
    }
    id selfProxy = self.proxyObject;
    [[FMSubscribeService proxyObject]
            getSubscribeList:_pageNum
                      result:^(BOOL isSuccess, FMItemDOList *itemDOList) {
                          [selfProxy requestItemFinish:itemDOList
                                         isRequestMore:isRequestMore
                                             isSuccess:isSuccess
                                              errorMsg:nil];
                      }
    ];
}

- (void)requestItemFinish:(FMItemDOList *)itemDOList
            isRequestMore:(BOOL)isRequestMore
                isSuccess:(BOOL)isSuccess
                 errorMsg:(NSString *)errorMsg {
    for (FMItemDO *itemDO in itemDOList.items) {
        itemDO.subscribed = YES;
    }
    [super requestItemFinish:itemDOList
               isRequestMore:isRequestMore
                   isSuccess:isSuccess
                    errorMsg:errorMsg];
}

@end