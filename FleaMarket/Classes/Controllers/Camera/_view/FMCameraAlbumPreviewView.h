// 
// Created by henson on 7/7/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>

//#define previewSize 5

@interface FMCameraAlbumPreviewView : UIView

-(id)initWithFrame:(CGRect)frame withPreviewSize:(int)__previewSize;

-(NSArray*)getSelectedAssets;
- (void)captureToAddAssets:(NSArray*)assets;

@end