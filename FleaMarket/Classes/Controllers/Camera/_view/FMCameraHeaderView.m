// 
// Created by henson on 7/24/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import "FMCameraHeaderView.h"
#import "UIImage+Helper.h"

@implementation FMCameraHeaderView {
    UIButton *_flashButton;
    UIButton *_positionButton;
    void (^_flashTouchAction)();
    void (^_devicePositionTouchAction)();
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGRect flashButtonRect = {{10,0}, {70, 35}};
        UIButton *flashButton = [[UIButton alloc] initWithFrame:flashButtonRect];
        flashButton.backgroundColor = [UIColor clearColor];
        [flashButton setBackgroundImage:[UIImage imageWithFileName:@"camera_flash.png"]
                                forState:UIControlStateNormal];
        flashButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        flashButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 11);
        flashButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [flashButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [flashButton setTitle:@"关闭" forState:UIControlStateNormal];
        [flashButton addTarget:self action:@selector(flashTouch)
               forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:flashButton];
        _flashButton = flashButton;

        CGRect positionButtonRect = {{FM_SCREEN_WIDTH - 70 - 10, 0}, {70, 35}};
        UIButton *positionButton = [[UIButton alloc] initWithFrame:positionButtonRect];
        positionButton.backgroundColor = [UIColor clearColor];
        [positionButton addTarget:self action:@selector(positionTouch)
              forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:positionButton];
        _positionButton = positionButton;
        [_positionButton setBackgroundImage:[UIImage imageWithFileName:@"camera_flip.png"]
                                   forState:UIControlStateNormal];

        self.isOpenFlash = NO;
        self.positionType = kFMCameraDevicePositionBack;
    }

    return self;
}

- (void)flashTouch {
    self.isOpenFlash = !self.isOpenFlash;

    if (_flashTouchAction) {
        _flashTouchAction();
    }
}

- (void)setFlashTouch:(void (^)(void))block {
    _flashTouchAction = block;
}

- (void)setDevicePositionTouch:(void (^)(void))block {
    _devicePositionTouchAction = block;
}

- (void)setIsOpenFlash:(BOOL)isOpenFlash {
    _isOpenFlash = isOpenFlash;
    [self setFlashImage];
}

- (void)setFlashImage {
    if (_isOpenFlash) {
        [_flashButton setTitle:@"打开" forState:UIControlStateNormal];
        return;
    }
    [_flashButton setTitle:@"关闭" forState:UIControlStateNormal];
    return;
}

- (void)positionTouch {
    if(self.positionType == kFMCameraDevicePositionBack) {
        self.positionType = kFMCameraDevicePositionFront;
        _flashButton.hidden = YES;
    } else {
        self.positionType = kFMCameraDevicePositionBack;
        _flashButton.hidden = NO;
    }
    
    if (_devicePositionTouchAction) {
        _devicePositionTouchAction();
    }
}

- (void)setPositionType:(kFMCameraDevicePositionType)positionType {
    _positionType = positionType;
}
@end