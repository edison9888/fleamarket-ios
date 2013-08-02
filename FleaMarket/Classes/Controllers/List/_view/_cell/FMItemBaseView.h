//
// Created by yuanxiao on 13-7-11.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, kFMItemBaseViewFrom) {
    kFMItemBaseViewFromList,
    kFMItemBaseViewFromDetail
};

@class FMItemDO;

@interface FMItemBaseView : UIView

@property(nonatomic, assign) kFMItemBaseViewFrom from;

- (void)setItemDO:(FMItemDO *)itemDO serverTime:(NSString *)serverTime;

@end