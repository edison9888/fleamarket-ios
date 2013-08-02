// 
// Created by henson on 7/8/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <BlocksKit/UIView+BlocksKit.h>
#import "FMCameraTakeToolbar.h"
#import "FMAsset.h"
#import "FMCommon.h"

@implementation FMCameraThumbPreviewView {
    UILabel *_countLabel;
    UIImageView *_imageView;
}

- (id)initWithFrame:(CGRect)frame previewSize:(NSInteger)previewSize {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];

        CGRect imageRect = {{2.5, 2.5}, {50, 50}};
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageRect];
        [self addSubview:imageView];
        _imageView = imageView;

        CGRect countRect = {{2.5, frame.size.height - 20 - 2.5}, {frame.size.width - 5, 20}};
        UILabel *countLabel = [[UILabel alloc] initWithFrame:countRect];
        countLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        countLabel.textAlignment = NSTextAlignmentCenter;
        countLabel.font = FMFont(NO, 12.f);
        countLabel.textColor = [UIColor whiteColor];
        countLabel.text = [NSString stringWithFormat:@"已选0/%d",previewSize];
        [self addSubview:countLabel];
        _countLabel = countLabel;

        [self setupBgImageView];
    }

    return self;
}

- (void)setImage:(UIImage *)image {
    _imageView.image = image;
}

-(void)setLabel:(NSString *)label{
    _countLabel.text = label;
}

- (void)setupBgImageView {
    UIImage *bgImage = [UIImage imageNamed:@"camera_thumb_preview_bg.png"];
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:bgImage];
    bgImageView.backgroundColor = [UIColor clearColor];
    bgImageView.frame = self.bounds;
    [self addSubview:bgImageView];
}

@end

@interface FMCameraTakeToolbar() 

@end

@implementation FMCameraTakeToolbar {
    UIButton *_closeButton;
    UIButton *_takeButton;
    int _previewSize;

    void (^_closeActionBlock)(void);
    void (^_takePictureBlock)(void);
    void (^_showAlbumBlock)(void);
    int selectedCount0;
}
    @synthesize selectedAssets = _selectedAssets;
    @synthesize previewView = _previewView;
    
-(id)initWithFrame:(CGRect)frame withPreviewSize:(int)previewSize{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupBgImageView];
        __weak FMCameraTakeToolbar *selfWeak = self;
        _previewSize=previewSize;
        
        CGRect closeRect = {{10, 22.5}, {45, 45}};
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton setImage:[UIImage imageNamed:@"camera_toolbar_close.png"]
                     forState:UIControlStateNormal];
        [closeButton addTarget:self
                        action:@selector(closeAction)
              forControlEvents:UIControlEventTouchUpInside];
        closeButton.frame = closeRect;
        [self addSubview:closeButton];
        _closeButton = closeButton;
        
        UIImage *takeImage = [UIImage imageNamed:@"camera_take_icon.png"];
        CGRect takeRect = {{(frame.size.width - takeImage.size.width) / 2.f, (frame.size.height - 2 - takeImage.size.height) / 2.f}, takeImage.size};
        UIButton *takeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [takeButton setBackgroundImage:[UIImage imageNamed:@"camera_take_icon.png"]
                              forState:UIControlStateNormal];
        [takeButton addTarget:self
                       action:@selector(takeAction)
             forControlEvents:UIControlEventTouchUpInside];
        takeButton.frame = takeRect;
        [self addSubview:takeButton];
        _takeButton = takeButton;
        
        CGRect previewRect = {{frame.size.width - 53 - 15,(frame.size.height - 2 - 53)/2.f}, {53,53}};
        FMCameraThumbPreviewView *previewView = [[FMCameraThumbPreviewView alloc] initWithFrame:previewRect previewSize:previewSize];
        previewView.onTouchUpBlock = ^(NSSet *set, UIEvent *event) {
            [selfWeak showAlbum];
        };
        [self addSubview:previewView];
        _previewView = previewView;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pushToCTSelected:) name:@"pushToCTSelectedNotification" object:nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"pullToCTSelectedAssetsNotification" object:self];
        _selectedAssets = [[NSMutableArray alloc]initWithCapacity:previewSize];
    }
    
    return self;
}

-(void)pushToCTSelected:(NSNotification*)notification{
        NSMutableArray *selectedAssets = [[notification userInfo]objectForKey:@"selectedAssets"];
        selectedCount0 = selectedAssets.count;
        [_previewView setImage:[(FMAsset*)[selectedAssets objectAtIndex:selectedAssets.count-1] thumbnail]];
        [_previewView setLabel:[NSString stringWithFormat:@"已选%d/%d",selectedAssets.count,_previewSize]];
}

-(void)refreshPreview:(UIImage*)lastAsset{
    [_previewView setImage:lastAsset];
    [_previewView setLabel:[NSString stringWithFormat:@"已选%d/%d",selectedCount0+_selectedAssets.count,_previewSize]];
    [self enableTakeButton];
}

-(void)enableTakeButton{
    _takeButton.enabled = YES;
}
    
-(void)removeCloseBtn{
    [_closeButton removeFromSuperview];
}
    
- (void)closeAction {
    if (_closeActionBlock) {
        _closeActionBlock();
    }
}

- (void)takeAction {
    _takeButton.enabled = NO;
    if(_selectedAssets.count+selectedCount0<_previewSize){
        if (_takePictureBlock) {
            _takePictureBlock();
        }
    }else{
        [FMCommon showToast:[self superview] text:@"亲，宝贝图片超出数量了哦～"];
        _takeButton.enabled = YES;
    }
}

- (void)showAlbum {
    if (_showAlbumBlock) {
        _showAlbumBlock();
    }
}

- (void)setCloseAction:(void (^)(void))block {
    _closeActionBlock = block;
}

- (void)setTakePictureAction:(void (^)(void))block {
    _takePictureBlock = block;
}

- (void)setShowAlbum:(void (^)(void))block {
    _showAlbumBlock = block;
}

- (void)setupBgImageView {
    UIImage *bgImage = [[UIImage imageNamed:@"camera_toolbar_bg.png"]
            resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:bgImage];
    imageView.frame = self.bounds;
    [self addSubview:imageView];
}
    
- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end