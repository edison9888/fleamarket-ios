// 
// Created by henson on 7/7/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import "FMCameraAlbumPreviewView.h"
#import "FMCameraSelectedImageView.h"
#import "FMAsset.h"
#import "NSArray-Blocks.h"
#import "FMCommon.h"

@interface FMCameraAlbumPreviewView ()

@end

@implementation FMCameraAlbumPreviewView {
    UILabel *_countLabel;
    UIScrollView *_scrollView;
    NSMutableArray *_selectedAssets;
    int _previewSize;
}

- (id)initWithFrame:(CGRect)frame withPreviewSize:(int)__previewSize{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupBgImageView];
        _previewSize = __previewSize;

        CGRect countRect = {{0,3},{frame.size.width,20}};
        UILabel *countLabel = [[UILabel alloc] initWithFrame:countRect];
        countLabel.backgroundColor = [UIColor clearColor];
        countLabel.textAlignment = NSTextAlignmentCenter;
        countLabel.font = FMFont(NO, 15);
        countLabel.textColor = FMColorWithRed(148, 148, 148);
        countLabel.text = [NSString stringWithFormat:@"已选0/%d",_previewSize];
        [self addSubview:countLabel];
        _countLabel = countLabel;

        CGRect scrollRect = {{0, 28}, {FM_SCREEN_WIDTH, 78}};
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:scrollRect];
        scrollView.backgroundColor = [UIColor clearColor];
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:scrollView];
        _scrollView = scrollView;
        
        _selectedAssets = [[NSMutableArray alloc]init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectToAdd:) name:@"selectToAddNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deselectToDel:) name:@"deselectToDelNotification" object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(captureToAdd:) name:@"captureToAddNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pullToAPSelectedAssets:) name:@"pullToAPSelectedAssetsNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pullToCTSelectedAssets:) name:@"pullToCTSelectedAssetsNotification" object:nil];
        
    }

    return self;
}

-(NSArray*)getSelectedAssets{
    return [NSArray arrayWithArray:_selectedAssets];
}
    
//- (void)captureToAdd:(NSNotification*)notification{
//        NSArray* assets = [[notification userInfo]objectForKey:@"assets"];
//        [assets each:^(id asset) {
//            if(![_selectedAssets containsObject:asset]){
//                CGRect rect = {{_selectedAssets.count*70,0},{70,78}};
//                FMCameraSelectedImageView *imageView = [[FMCameraSelectedImageView alloc] initWithFrame:rect];
//                imageView.image = [(FMAsset*)asset thumbnail];
//                [_selectedAssets addObject:asset];
//                [_scrollView addSubview:imageView];
//            }
//        }];
//        _countLabel.text = [NSString stringWithFormat:@"已选%d/%d",_selectedAssets.count,_previewSize];
//        _scrollView.contentSize = CGSizeMake([_selectedAssets count] * 70 + 10, 78);
//}

- (void)captureToAddAssets:(NSArray*)assets{
    [assets each:^(id asset) {
        if(![_selectedAssets containsObject:asset]){
            CGRect rect = {{_selectedAssets.count*70,0},{70,78}};
            FMCameraSelectedImageView *imageView = [[FMCameraSelectedImageView alloc] initWithFrame:rect];
            imageView.image = [(FMAsset*)asset thumbnail];
            [_selectedAssets addObject:asset];
            [_scrollView addSubview:imageView];
        }
    }];
    _countLabel.text = [NSString stringWithFormat:@"已选%d/%d",_selectedAssets.count,_previewSize];
    _scrollView.contentSize = CGSizeMake([_selectedAssets count] * 70 + 10, 78);
}

- (void)selectToAdd:(NSNotification *)notification {
    FMAsset *asset = (FMAsset*)[[notification userInfo]objectForKey:@"asset"];
        if(_selectedAssets.count<_previewSize){
            CGRect rect = {{_selectedAssets.count*70,0},{70,78}};
            FMCameraSelectedImageView *imageView = [[FMCameraSelectedImageView alloc] initWithFrame:rect];
            imageView.image = asset.thumbnail;
            [_selectedAssets addObject:asset];
            [_scrollView addSubview:imageView];
            _countLabel.text = [NSString stringWithFormat:@"已选%d/%d",_selectedAssets.count,_previewSize];
            _scrollView.contentSize = CGSizeMake([_selectedAssets count] * 70 + 10, 78);
        }else{
            [[NSNotificationCenter defaultCenter]postNotificationName:@"selectFailNotificaion" object:self userInfo:[NSDictionary dictionaryWithObject:asset forKey:@"asset"]];
            [FMCommon showToast:[self superview] text:@"亲，宝贝图片超出数量了哦～"];
        }
}
    
-(void)deselectToDel:(NSNotification *)notification {
    [self doDeleteAsset:[[notification userInfo] objectForKey:@"asset"]];
}
    
-(void)deselectToDelAsset:(FMAsset*)asset{
    [self doDeleteAsset:asset];
}
    
-(void)doDeleteAsset:(FMAsset*)asset{
    NSUInteger idx = [_selectedAssets indexOfObject:asset];
    if(idx!=NSNotFound){
        [[[_scrollView subviews]objectAtIndex:idx]removeFromSuperview];
        if(idx<_selectedAssets.count){
            for(NSUInteger i=idx;i<_selectedAssets.count-1;i++){
                [UIView animateWithDuration:0.3 animations:^{
                    [[[_scrollView subviews]objectAtIndex:i] setFrame:CGRectMake(i*70, 0, 70, 78)];
                }];
            }
        }
        [_selectedAssets removeObject:asset];
        _countLabel.text = [NSString stringWithFormat:@"已选%d/%d",_selectedAssets.count,_previewSize];
        _scrollView.contentSize = CGSizeMake([_selectedAssets count] * 70 + 10, 78);
    }
}
    
-(void)deleteAsset:(id)sender{
    if([[sender superview] isKindOfClass:[FMCameraSelectedImageView class]]){
        NSUInteger selectedIdx = [[[[sender superview] superview] subviews]indexOfObject:[sender superview]];
        if(selectedIdx<_selectedAssets.count){
            FMAsset *asset = [_selectedAssets objectAtIndex:selectedIdx];
            if(asset){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"deletePreviewNotification" object:self userInfo:[NSDictionary dictionaryWithObject:asset forKey:@"asset"]];
                [self doDeleteAsset:asset];
            }
        }else{
            FMLOG(@"delete asset fail with error:asset not found in previewView!", nil);
        }
    }
}

-(void)pullToAPSelectedAssets:(NSNotification*)notification{
    NSArray* allAssects = [[notification userInfo]objectForKey:@"allAssects"];
    if(_selectedAssets.count>0){
        NSArray *selectedAssetsURLs = [_selectedAssets collect:^id(id obj1) {
            return [NSString stringWithFormat:@"%@",((FMAsset*)obj1).asset];
        }];
        NSArray *selected = [allAssects findAll:^BOOL(id obj) {
            return [selectedAssetsURLs containsObject:[NSString stringWithFormat:@"%@",((FMAsset*)obj).asset]];
        }];
        if(selected.count>0){
            [selected each:^(id obj) {
                [(FMAsset*)obj setSelected:YES];
                [_selectedAssets replaceObjectAtIndex:[_selectedAssets indexOfObject:[_selectedAssets find:^BOOL(id obj1) {
                    return [[NSString stringWithFormat:@"%@",((FMAsset*)obj1).asset] isEqual:[NSString stringWithFormat:@"%@",((FMAsset*)obj).asset]];
                }]] withObject:obj];
            }];
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:@"pushToAPSelectedNotification" object:self userInfo:[NSDictionary dictionaryWithObject:_selectedAssets forKey:@"assets"]];
    }
}

-(void)pullToCTSelectedAssets:(NSNotification*)notification{
    if(_selectedAssets.count>0){
        [[NSNotificationCenter defaultCenter]postNotificationName:@"pushToCTSelectedNotification" object:self userInfo:[NSDictionary dictionaryWithObject:_selectedAssets forKey:@"selectedAssets"]];
    }
}

- (void)setupBgImageView {
    UIImage *bgImage = [[UIImage imageNamed:@"camera_selected_img_bg.png"]
            resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:bgImage];
    imageView.frame = self.bounds;
    [self addSubview:imageView];
    return;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end