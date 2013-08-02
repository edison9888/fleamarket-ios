// 
// Created by henson on 7/7/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>
#import "FMBaseViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "FMCameraAlbumPreviewView.h"
@class FMCameraAssetPickerController;

@interface FMCameraAlbumPickerController : FMBaseViewController <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) NSMutableArray *assetGroups;
@property(nonatomic,weak)FMCameraAlbumPreviewView *previewView;

- (id)initWithPreviewSize:(int)__previewSize;

-(void)selectedAssetsDidFinish:(void (^)(NSArray *))block;

@end