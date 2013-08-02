// 
// Created by henson on 6/4/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <BlocksKit/UIControl+BlocksKit.h>
#import "FMAssetCell.h"
#import "FMAsset.h"
#import "FMAssetView.h"

@implementation FMAssetCell {
    NSArray *_rowAssets;
    void (^_showCameraActionBlock)(void);
}

- (id)initWithAssets:(NSArray *)assets reuseIdentifier:(NSString *)identifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    if (self) {
        [self setAssets:assets];
    }
    return self;
}

- (void)setAssets:(NSArray *)assets {
    _rowAssets = assets;

    for (UIView *view in [self subviews]) {
        [view removeFromSuperview];
    }

    CGFloat startX = 4;
    CGRect frame = CGRectMake(startX, 2, 75, 75);
    for (NSUInteger i = 0; i < [_rowAssets count]; ++i) {
        FMAsset *asset = [_rowAssets objectAtIndex:i];
        if (asset.type == FMAssetTypeCamera) {
            UIImage *addCameraImage = [UIImage imageNamed:@"camera_take_camera.png"];
            UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [addButton setImage:addCameraImage forState:UIControlStateNormal];
            [addButton setBackgroundColor:FMColorWithRed(236, 236, 236)];
            [addButton addEventHandler:^(id sender) {
                [self showCameraAction];
            } forControlEvents:UIControlEventTouchUpInside];
            addButton.frame = frame;
            [self addSubview:addButton];
        } else {
            FMAssetView *assetView = [[FMAssetView alloc] initWithFrame:frame];
            assetView.asset = asset;
            [self addSubview:assetView];
        }
        frame.origin.x = frame.origin.x + frame.size.width + 4;
    }
}

- (void)showCameraAction {
    if (_showCameraActionBlock) {
        _showCameraActionBlock();
    }
}

- (void)setShowCameraAction:(void (^)(void))block {
    _showCameraActionBlock = block;
}

@end