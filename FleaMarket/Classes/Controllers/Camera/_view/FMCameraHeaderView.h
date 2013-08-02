// 
// Created by henson on 7/24/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, kFMCameraDevicePositionType) {
    kFMCameraDevicePositionFront,
    kFMCameraDevicePositionBack,
};

@interface FMCameraHeaderView : UIView

@property(nonatomic, assign) BOOL isOpenFlash;
@property(nonatomic, assign) kFMCameraDevicePositionType positionType;

- (void)setFlashTouch:(void (^)(void))block;

- (void)setDevicePositionTouch:(void (^)(void))block;
@end