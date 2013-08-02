// 
// Created by henson on 6/14/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>

@class FMItemDO;

@interface FMItemDetailImageView : UIView <UIScrollViewDelegate>

- (void)setItemDO:(FMItemDO *)itemDO;

- (UIImage *)getFirstImage;

+ (float)viewHeight:(FMItemDO *)itemDO;

@end