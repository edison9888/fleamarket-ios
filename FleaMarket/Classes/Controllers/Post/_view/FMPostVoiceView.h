// 
// Created by henson on 6/25/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>

@class FMItemDO;

typedef NS_ENUM(NSUInteger, kPostVoiceStatus) {
    kPostVoiceStatusNormal,
    kPostVoiceStatusDone,
};

@interface FMPostVoiceView : UIView

@property(nonatomic, strong) FMItemDO *itemDO;
@property(nonatomic, assign) kPostVoiceStatus status;

- (id)initWithFrame:(CGRect)frame itemDO:(FMItemDO *)itemDO;

@end