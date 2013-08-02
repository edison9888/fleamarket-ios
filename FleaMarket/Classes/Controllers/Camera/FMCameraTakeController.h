// 
// Created by henson on 7/8/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef NS_ENUM(NSUInteger, FMCameraFrom) {
    FMCameraFromPost,
    FMCameraFromAlbum,
};

@interface FMCameraTakeController : UIViewController<UIAccelerometerDelegate>

@property(nonatomic, assign) FMCameraFrom from;
@property(nonatomic, weak) id delegate;
// UIImage
@property(nonatomic,retain) NSArray *aleadySelectedImgs;

- (id)initWithPreviewSize:(int)__previewSize;

- (id)initWithSelectedCount:(int)selectedCount;

-(void)selectedAssetsDidFinish:(void (^)(NSArray *))block;

@end