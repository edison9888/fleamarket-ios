// 
// Created by henson on 7/21/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>
#import "FMImageView.h"

@interface FMPostImageItemView : FMImageView

@property(nonatomic, assign) BOOL isPrimaryImage;

- (void)setProgress:(float)progress;

@end