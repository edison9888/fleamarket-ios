//
// Created by yuanxiao on 13-7-8.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "FMImageView.h"


@interface FMHomeScrollImageView : UIView

- (void)setData:(NSArray *)array
       isSquare:(BOOL)isSquare
 imageScaleType:(FMImageScaleType)imageScaleType;

- (void)setData:(NSArray *)array
       isBanner:(BOOL)isBanner
 imageScaleType:(FMImageScaleType)imageScaleType;


@end