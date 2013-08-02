// 
// Created by henson on 7/8/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>

@interface FMCameraThumbPreviewView : UIView

-(void)setLabel:(NSString*)label;
-(void)setImage:(UIImage *)image;
@end

@interface FMCameraTakeToolbar : UIView

// array of asset URL
@property (nonatomic,retain) NSMutableArray *selectedAssets;

@property (nonatomic,retain)FMCameraThumbPreviewView *previewView;

-(void)setCloseAction:(void (^)(void))block;

-(void)setTakePictureAction:(void (^)(void))block;

-(void)setShowAlbum:(void (^)(void))block;

-(void)refreshPreview:(UIImage*)lastAsset;

-(void)enableTakeButton;

-(void)removeCloseBtn;

-(id)initWithFrame:(CGRect)frame withPreviewSize:(int)previewSize;

@end
