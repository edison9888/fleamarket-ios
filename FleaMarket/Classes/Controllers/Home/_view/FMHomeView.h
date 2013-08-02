//
// Created by yuanxiao on 13-6-8.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "FMBaseScrollView.h"

@interface FMHomeViewDO : NSObject
@property(nonatomic, strong) NSMutableArray *items;
@property(nonatomic, assign) NSUInteger pageNo;
@property(nonatomic, copy) NSString *errorMsg;
@property(nonatomic, assign) BOOL more;
@end


@interface FMHomeView : FMBaseScrollView
@property(nonatomic, strong) FMHomeViewDO *viewDO;

@property(nonatomic, strong) id delegate;


@end