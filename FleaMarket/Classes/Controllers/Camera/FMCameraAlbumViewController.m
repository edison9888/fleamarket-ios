// 
// Created by henson on 7/5/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <MBMvc/TBMBGlobalFacade.h>
#import "FMCameraAlbumViewController.h"
#import "FMCameraAlbumPreviewView.h"
#import "FMCameraAssetPickerController.h"

@implementation FMCameraAlbumViewController {
    FMCameraAlbumPreviewView *_cameraSelectedImagesView;
    ALAssetsLibrary *library;
    int _previewSize;
    NSArray *_takenUrls;
    void (^_selectedAssetsDidFinishBlock)(NSArray *);
}

-(id)init{
    self = [super init];
    if(self){
        _previewSize = previewSize;
    }
    return self;
}

-(id)initWithSelectedCount:(int)selectedCount{
    self = [super init];
    if(self){
        _previewSize = previewSize-selectedCount;
    }
    return self;
}

-(id)initWithPrevieSize:(int)__previewSize{
    self = [super init];
    if(self){
        _previewSize = __previewSize;
    }
    return self;
}


-(void)setTakenUrls:(NSArray*)takenUrls{
    _takenUrls = takenUrls;
}

- (void)selectedAssetsDidFinish:(void (^)(NSArray *))block {
    _selectedAssetsDidFinishBlock = block;
}

- (void)loadView {
    [super loadView];

    CGRect selectedImageRect = {{0, FM_SCREEN_HEIGHT - 106}, {FM_SCREEN_WIDTH, 106}};
    FMCameraAlbumPreviewView *cameraSelectedImagesView = [[FMCameraAlbumPreviewView alloc] initWithFrame:selectedImageRect withPreviewSize:_previewSize];
    cameraSelectedImagesView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:cameraSelectedImagesView];
    _cameraSelectedImagesView = cameraSelectedImagesView;

    FMCameraAlbumPickerController *albumPickerController = [[FMCameraAlbumPickerController alloc] initWithPreviewSize:_previewSize];
    albumPickerController.previewView = _cameraSelectedImagesView;
    [albumPickerController selectedAssetsDidFinish:_selectedAssetsDidFinishBlock];
    UINavigationController *albumNavigationController = [[UINavigationController alloc]
            initWithRootViewController:albumPickerController];

    FMCameraAssetPickerController *assetPickerController = [[FMCameraAssetPickerController alloc] initWithPreviewSize:_previewSize];
    [assetPickerController setTakenUrls:_takenUrls];
    assetPickerController.previewView = _cameraSelectedImagesView;
    [assetPickerController selectedAssetsDidFinish:_selectedAssetsDidFinishBlock];
    [self setAssetGroupAndPush:assetPickerController navigation:albumNavigationController];

    [self addChildViewController:albumNavigationController];
    albumNavigationController.view.frame = CGRectMake(0, 0, FM_SCREEN_WIDTH, FM_SCREEN_HEIGHT - 106);
    [self.view addSubview:albumNavigationController.view];
}

-(void)setAssetGroupAndPush:(FMCameraAssetPickerController*)assetPickerController navigation:(UINavigationController*)albumNavigationController{
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    library = assetLibrary;
    @autoreleasepool {
        void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) {
            if (group == nil) {
                return;
            }
            NSUInteger nType = (NSUInteger) [[group valueForProperty:ALAssetsGroupPropertyType] intValue];
            if (nType == ALAssetsGroupSavedPhotos) {
                assetPickerController.assetGroup = group;
                assetPickerController.savedPhotoGroup = group;
                assetPickerController.navigationTitle = (NSString *) [group valueForProperty:ALAssetsGroupPropertyName];
                [albumNavigationController pushViewController:assetPickerController animated:NO];
            }
        };
        [library enumerateGroupsWithTypes:ALAssetsGroupAll
                                    usingBlock:assetGroupEnumerator
                                  failureBlock:nil];
    }
}

-(void)viewDidLoad{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationNone];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationNone];
}

@end