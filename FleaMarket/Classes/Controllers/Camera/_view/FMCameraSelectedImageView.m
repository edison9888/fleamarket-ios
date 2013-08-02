// 
// Created by henson on 7/8/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import "FMCameraSelectedImageView.h"

@implementation FMCameraSelectedImageView {
    UIImageView *_imageView;
    UIButton *_closeButton;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGRect imageRect = {{10, 10}, {60, 60}};
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageRect];
        [self addSubview:imageView];
        _imageView = imageView;

        UIImage *closeImage = [UIImage imageNamed:@"post_voice_delete_icon"];
        CGRect closeRect = {{5, 5}, {40,40}};
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton setImage:closeImage
                     forState:UIControlStateNormal];
        closeButton.frame = closeRect;
        [closeButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 20, 20)];
        [closeButton addTarget:self.superview action:@selector(deleteAsset:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        _closeButton = closeButton;
    }

    return self;
}

- (void)setImage:(UIImage *)image {
    _image = image;

    _imageView.image = image;
}

@end