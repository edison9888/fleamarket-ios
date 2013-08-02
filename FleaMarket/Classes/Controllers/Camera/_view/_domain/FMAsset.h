// 
// Created by henson on 6/4/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef NS_ENUM(NSUInteger, FMAssetType) {
    FMAssetTypeNormal,
    FMAssetTypeCamera,
};

@interface FMAsset : NSObject

@property(nonatomic, strong) ALAsset *asset;
@property(nonatomic, assign) FMAssetType type;
@property(nonatomic, assign) BOOL selected;
@property(nonatomic, retain) UIImage *thumbnail;

- (id)initWithAsset:(ALAsset *)asset;

@end