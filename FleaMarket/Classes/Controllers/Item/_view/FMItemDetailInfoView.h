// 
// Created by henson on 6/16/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>

@class FMItemDO;
@class FMItemStarShareView;

@interface FMItemDetailInfoView : UIView

- (void)setDescriptionTouchAction:(void (^)(void))block;

- (void)setBoughtTouchAction:(void (^)(void))block;

+ (float)viewHeight:(FMItemDO *)itemDO;

- (void)setItemDO:(FMItemDO *)itemDO serverTime:(NSString *)serverTime;

- (UIImage *)getFirstImage;

@end