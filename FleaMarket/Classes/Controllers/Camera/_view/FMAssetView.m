// 
// Created by henson on 7/9/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

//#import "TBMBGlobalFacade.h"
#import "FMAssetView.h"
#import "FMAsset.h"

@implementation FMAssetView {
    UIImageView *_imageView;
    UIImageView *_overlayImageView;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.selected = NO;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:imageView];
        _imageView = imageView;

        UIImage *overlayImage = [UIImage imageNamed:@"image_picker_overlay.png"];
        UIImageView *overlayImageView = [[UIImageView alloc] initWithImage:overlayImage];
        overlayImageView.frame = self.bounds;
        overlayImageView.hidden = YES;
        [self addSubview:overlayImageView];
        _overlayImageView = overlayImageView;
    }

    return self;
}

- (void)setAsset:(FMAsset *)asset {
    _asset = asset;
    _imageView.image = _asset.thumbnail;
    if (_asset.selected) {
        [self setSelected:YES];
    }
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    _asset.selected = selected;
    _overlayImageView.hidden = !_selected;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    self.selected = !self.selected;
    _asset.selected = self.selected;
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:_asset,@"asset", nil];
    if (self.selected) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"selectToAddNotification" object:self userInfo:dic];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"deselectToDelNotification" object:self userInfo:dic];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
}

@end