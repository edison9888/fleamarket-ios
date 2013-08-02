// 
// Created by henson on 6/6/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>
#import "FMBaseListViewController.h"

@interface FMAccountInfo : NSObject
@property(nonatomic, assign) NSUInteger boughtCount;
@property(nonatomic, assign) NSUInteger sellingCount;
@property(nonatomic, assign) NSUInteger soldCount;
@property(nonatomic, assign) NSUInteger messageUnreadCount;
@property(nonatomic, assign) NSUInteger collectCount;
@property(nonatomic, assign) NSUInteger postQueueCount;
@property(nonatomic, assign) BOOL loginDone;

@end

@interface FMAccountViewController : FMBaseListViewController <FMNeedLoginProtocol>

@property (nonatomic, strong) FMAccountInfo *accountInfo;

@end