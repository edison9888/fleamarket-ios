// 
// Created by henson on 6/4/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import "FMAsset.h"

@implementation FMAsset {

@private
    ALAsset *_asset;
}

@synthesize asset = _asset;

- (id)initWithAsset:(ALAsset *)asset {
    self = [super init];
    if (self) {
        self.asset = asset;
        self.type = FMAssetTypeNormal;
        self.thumbnail = [UIImage imageWithCGImage:asset.thumbnail];
    }

    return self;
}

@end