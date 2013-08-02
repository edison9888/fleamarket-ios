// 
// Created by henson on 6/4/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "FMAsset.h"
#import "FMBaseViewController.h"
#import "FMCameraAlbumPreviewView.h"

@interface FMCameraAssetPickerController : FMBaseViewController <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) ALAssetsGroup *assetGroup;
@property(nonatomic, strong) ALAssetsGroup *savedPhotoGroup;
@property(nonatomic, strong) NSMutableArray *assets;
@property(nonatomic, copy) NSString *navigationTitle;
@property(nonatomic,weak)FMCameraAlbumPreviewView *previewView;

-(id)initWithPreviewSize:(int)__previewSize;

-(void)setTakenUrls:(NSArray*)takenUrls;

-(void)selectedAssetsDidFinish:(void (^)(NSArray *))block;

-(void)reloadAssetsWithSelected:(NSArray*)assets;

@end