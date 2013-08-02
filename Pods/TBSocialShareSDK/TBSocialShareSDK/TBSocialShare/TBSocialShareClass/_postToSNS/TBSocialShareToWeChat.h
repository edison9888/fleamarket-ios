//
// Created by yuanxiao on 13-5-27.
// Copyright (c) 2013 Taobao. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "TBSocialShareToBase.h"


@interface TBSocialShareToWeChat : TBSocialShareToBase

@property (nonatomic) enum WXScene wxScene;

+ (TBSocialShareToWeChat *)instance;


- (BOOL)isWXAppInstalled;

@end