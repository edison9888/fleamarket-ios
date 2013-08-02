//
// Created by yuanxiao on 13-7-1.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "FMBaseViewController.h"

typedef enum {
    FMMessageViewTypeSystem,
    FMMessageViewTypeReceive,
    FMMessageViewTypeSend
} FMMessageViewType;

@interface FMMessageViewInfo : NSObject

@property(nonatomic, assign) NSInteger systemCount;
@property(nonatomic, assign) NSInteger receiveCount;
@property(nonatomic, assign) NSInteger sendCount;

@end

@interface FMMessageViewController : FMBaseViewController

@property (nonatomic, strong) FMMessageViewInfo *messageInfo;
@property (nonatomic, assign) FMMessageViewType selectMessageType;

@end