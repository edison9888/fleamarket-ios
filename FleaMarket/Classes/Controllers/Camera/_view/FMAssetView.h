// 
// Created by henson on 7/9/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>

@class FMAsset;

@interface FMAssetView : UIView

@property(nonatomic, strong) FMAsset *asset;
@property(nonatomic, assign) BOOL selected;

@end