// 
// Created by henson on 6/25/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger , FMPostIndicationState) {
    FMPostIndicationStateNormal,
    FMPostIndicationStateDone,
};

typedef NS_ENUM(NSUInteger , FMPostIndicationType) {
    FMPostIndicationTypeUp,
    FMPostIndicationTypeDown,
};

@interface FMPostTextIndicationView : UIView

- (id)initWithFrame:(CGRect)frame type:(FMPostIndicationType)type;

- (void)setState:(FMPostIndicationState)state;

@end