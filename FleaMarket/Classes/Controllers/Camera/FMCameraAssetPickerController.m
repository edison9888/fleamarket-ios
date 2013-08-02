// 
// Created by henson on 6/4/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <MBMvc/TBMBGlobalFacade.h>
#import "FMCameraAssetPickerController.h"
#import "FMAssetCell.h"
#import "NSArray+Helper.h"
#import "FMCameraTakeController.h"
#import "NSArray-Blocks.h"
#import "FMCameraAlbumViewController.h"

@interface FMCameraAssetPickerController ()

@property (nonatomic, assign) NSUInteger columns;
@end

@implementation FMCameraAssetPickerController {
    UITableView *_tableView;
    int _previewSize;
    void (^_selectedAssetsDidFinishBlock)(NSArray *);
@private
    NSString *_navigationTitle;
    NSArray *_takenUrls;
}

@synthesize navigationTitle = _navigationTitle;
@synthesize previewView = _previewView;
    -(id)init{
        self=[super init];
        if (self) {
            _previewSize = previewSize;
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(selectFail:) name:@"selectFailNotificaion" object:nil];
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deletePreview:) name:@"deletePreviewNotification" object:nil];
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pushToAPSelected:) name:@"pushToAPSelectedNotification" object:nil];
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadAssets:) name:@"reloadAssetsNotification" object:nil];
        }
        return self;
}
    
-(id)initWithPreviewSize:(int)__previewSize{
        self=[self init];
        if (self) {
            _previewSize = __previewSize;
        }
        return self;
}

- (void)initNavigationBar {
    [self setLeftBarButtonTitle:@"相册"
                     buttonType:LeftButtonWithWhite
                      iconImage:nil];
    [self setRightButtonTitle:@"确定"];
}
    
-(void)setTakenUrls:(NSArray*)takenUrls{
        _takenUrls = takenUrls;
}

- (void)selectedAssetsDidFinish:(void (^)( NSArray *))block {
    _selectedAssetsDidFinishBlock = block;
}

- (void)loadView {
    [super loadView];
    [self initNavigationBar];

    CGRect tableRect = {{0, kNavigationBarHeight}, {FM_SCREEN_WIDTH, FM_SCREEN_HEIGHT - kNavigationBarHeight - 106}};
    UITableView *tableView = [[UITableView alloc] initWithFrame:tableRect
                                                          style:UITableViewStylePlain];
    tableView.backgroundView = nil;
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    _tableView = tableView;

    [self.view sendSubviewToBack:_tableView];
}

- (void)viewDidLoad {
    [self setupNavigationTitle];
    [self performSelectorInBackground:@selector(preparePhotos) withObject:nil];
}

- (void)initAssets {
    self.assets = nil;
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    self.assets = tempArray;
}

- (void)addCameraAsset {
    FMAsset *cameraAsset = [[FMAsset alloc] initWithAsset:nil];
    cameraAsset.type = FMAssetTypeCamera;
    [self.assets addObject:cameraAsset];
    return;
}

- (void)setupNavigationTitle {
    if (self.navigationTitle) {
        [self setTitle:self.navigationTitle];
        return;
    }
    [self.navigationItem setTitle:@"相机胶卷"];
    return;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.columns = (NSUInteger) (self.view.bounds.size.width / 80);
}

- (void)dealloc {
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    FMLog(@"dealloc %@", [self description]);
}

- (void)preparePhotos {
    if (!self.assetGroup) {
        FMLOG(@"asset group is null!",nil);
    }
    [self showAssets];
    return;
}

-(void)deletePreview:(NSNotification*)notification{
    FMAsset* asset = [[notification userInfo]objectForKey:@"asset"];
    asset.selected = NO;
    [_tableView reloadData];
}

-(void)selectFail:(NSNotification*)notification {
    FMAsset* asset = [[notification userInfo]objectForKey:@"asset"];
    asset.selected = NO;
    [_tableView reloadData];
}

-(void)reloadAssetsWithSelected:(NSArray*)assets{
    if ((NSUInteger) [[_assetGroup valueForProperty:ALAssetsGroupPropertyType] intValue] == ALAssetsGroupSavedPhotos) {
        _takenUrls = assets;
        [self performSelectorInBackground:@selector(showAssets) withObject:nil];
    } else {
        if (_savedPhotoGroup) {
            @autoreleasepool {
                NSMutableArray *added = [[NSMutableArray alloc] init];
                [_savedPhotoGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    if (result == nil) {
                        return;
                    }
                    if ([assets containsObject:result.defaultRepresentation.url]) {
                        FMAsset *fmAsset = [[FMAsset alloc] initWithAsset:result];
                        [added addObject:fmAsset];
                    }
                }];
                [_previewView captureToAddAssets:added];
//                [[NSNotificationCenter defaultCenter]postNotificationName:@"captureToAddNotification" object:self userInfo:[NSDictionary dictionaryWithObject:added forKey:@"assets"]];
            }
        }
    }
}

- (void)reloadAssets:(NSNotification*)notification{
    NSArray *assets = [[notification userInfo]objectForKey:@"assets"];
    if ((NSUInteger) [[_assetGroup valueForProperty:ALAssetsGroupPropertyType] intValue] == ALAssetsGroupSavedPhotos) {
        _takenUrls = assets;
        [self performSelectorInBackground:@selector(showAssets) withObject:nil];
    } else {
        if (_savedPhotoGroup) {
            @autoreleasepool {
                NSMutableArray *added = [[NSMutableArray alloc] init];
                [_savedPhotoGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    if (result == nil) {
                        return;
                    }
                    if ([assets containsObject:result.defaultRepresentation.url]) {
                        FMAsset *fmAsset = [[FMAsset alloc] initWithAsset:result];
                        [added addObject:fmAsset];
                    }
                }];
                [_previewView captureToAddAssets:added];
//                [[NSNotificationCenter defaultCenter]postNotificationName:@"captureToAddNotification" object:self userInfo:[NSDictionary dictionaryWithObject:added forKey:@"assets"]];
            }
        }
        
    }
}

- (void)showAssets {
    @autoreleasepool {
        [self initAssets];
        [self.assetGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result == nil) {
                return;
            }
            FMAsset *fmAsset = [[FMAsset alloc] initWithAsset:result];
            [self.assets addObject:fmAsset];
        }];
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.assets = [[self.assets reverse] mutableCopy];
            FMAsset *cameraAsset = [[FMAsset alloc] initWithAsset:nil];
            cameraAsset.type = FMAssetTypeCamera;
            [self.assets insertObject:cameraAsset atIndex:0];
            if(_takenUrls&&_takenUrls.count>0){
            [[self.assets findAll:^BOOL(id obj) {
                return [_takenUrls containsObject:((FMAsset*)obj).asset.defaultRepresentation.url];
            }] each:^(id obj) {
                [(FMAsset*)obj setSelected:YES];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"selectToAddNotification" object:self userInfo:[NSDictionary dictionaryWithObject:obj forKey:@"asset"]];
            }];
            }
            [_tableView reloadData];
        });
        [[NSNotificationCenter defaultCenter]postNotificationName:@"pullToAPSelectedAssetsNotification" object:self userInfo:[NSDictionary dictionaryWithObject:_assets forKey:@"allAssects"]];
    }
}

-(void)pushToAPSelected:(NSNotification*)notification{
    NSArray* assets = [[notification userInfo]objectForKey:@"assets"];
    NSArray *selected = [_assets findAll:^BOOL(id obj) {
        return [assets containsObject:obj];
    }];
    [selected each:^(id obj) {
        ((FMAsset*)obj).selected = YES;
    }];
    [_tableView reloadData];
}

-(void)leftAction:(id)sender{
    [super leftAction:sender];
}
    
- (void)rightAction:(id)sender {
    if (_selectedAssetsDidFinishBlock) {
        if (_previewView) {
            _selectedAssetsDidFinishBlock([[_previewView getSelectedAssets] findAll:^BOOL(id obj) {
                return [(FMAsset*)obj selected];
            }]);
        }else{
            FMLOG(@"previewView 未初始化！", nil);
        }
    }else{
        FMLOG(@"_selectedAssetsDidFinishBlock未初始化！", nil);
    }
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

#pragma mark - table view delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (NSInteger) ceil(([self.assets count]) / (float) self.columns);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"FMAssetTableViewPickerCell";
    __weak FMCameraAssetPickerController *selfWeak = self;
    FMAssetCell * cell = (FMAssetCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[FMAssetCell alloc] initWithAssets:[self assetsForIndexPath:indexPath] reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        [cell setAssets:[self assetsForIndexPath:indexPath]];
    }
    [cell setShowCameraAction:^{
        [selfWeak showCameraController];
    }];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 79;
}

- (NSArray *)assetsForIndexPath:(NSIndexPath *)path {
    int index = path.row * self.columns;
    int length = MIN(self.columns, [self.assets count] - index);
    return [self.assets subarrayWithRange:NSMakeRange((NSUInteger) index, (NSUInteger) length)];
}

- (void)showCameraController {
    FMCameraTakeController *takeController = [[FMCameraTakeController alloc] initWithPreviewSize:_previewSize];
    takeController.from = FMCameraFromAlbum;
    [self.navigationController presentViewController:takeController animated:YES completion:nil];
}

@end