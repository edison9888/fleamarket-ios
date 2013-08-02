// 
// Created by henson on 7/7/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import "FMCameraAlbumPickerController.h"
#import "FMCameraAssetPickerController.h"
#import "FMCameraAlbumViewController.h"
#import <MBMvc/TBMBGlobalFacade.h>

@interface FMCameraAlbumPickerController ()

@property(nonatomic, strong) ALAssetsLibrary *library;

@end

@implementation FMCameraAlbumPickerController {
    UITableView *_tableView;
    int _previewSize;
    void (^_selectedAssetsDidFinishBlock)( NSArray *);
}
@synthesize previewView = _previewView;
-(id)init{
    self = [super init];
    if(self){
        _previewSize = previewSize;
    }
    return self;
}

-(id)initWithPreviewSize:(int)__previewSize{
    self = [super init];
    if(self){
        _previewSize = __previewSize;
    }
    return self;
}

- (void)selectedAssetsDidFinish:(void (^)(NSArray *))block {
    _selectedAssetsDidFinishBlock = block;
}

- (void)initNavigationBar {
    [self setTitle:@"相机胶卷"];
    [self setLeftBarButtonTitle:nil
                     buttonType:LeftButtonWithBack
                      iconImage:nil];
    [self setRightButtonTitle:@"确定"];
}

- (void)loadView {
    [super loadView];

    self.navigationController.navigationBar.hidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    [self initNavigationBar];

    CGRect tableRect = {{0, kNavigationBarHeight}, {FM_SCREEN_WIDTH, FM_SCREEN_HEIGHT - kNavigationBarHeight - 106}};
    UITableView *tableView = [[UITableView alloc] initWithFrame:tableRect
                                                          style:UITableViewStylePlain];
    tableView.backgroundView = nil;
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    _tableView = tableView;
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    self.assetGroups = tempArray;
    
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    self.library = assetLibrary;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) {
                if (group == nil) {
                    return;
                }
                
                NSUInteger nType = (NSUInteger) [[group valueForProperty:ALAssetsGroupPropertyType] intValue];
                if (nType == ALAssetsGroupSavedPhotos) {
                    [self.assetGroups insertObject:group atIndex:0];
                } else {
                    [self.assetGroups addObject:group];
                }
                
                [self performSelectorOnMainThread:@selector(reloadTableView)
                                       withObject:nil
                                    waitUntilDone:YES];
            };
            
            void (^assetGroupEnumeratorFailure)(NSError *) = ^(NSError *error) {
                FMLog(@"A problem occured: %@", [error description]);
            };
            
            [self.library enumerateGroupsWithTypes:ALAssetsGroupAll
                                        usingBlock:assetGroupEnumerator
                                      failureBlock:assetGroupEnumeratorFailure];
            
        }
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)reloadTableView {
    [_tableView reloadData];
}

- (void)leftAction:(id)sender {
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)rightAction:(id)sender {
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)dealloc {
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
}

#pragma mark - TableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.assetGroups count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"FMAlbumPickerControllerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    ALAssetsGroup *g = (ALAssetsGroup *) [self.assetGroups objectAtIndex:(NSUInteger) indexPath.row];
    [g setAssetsFilter:[ALAssetsFilter allPhotos]];
    NSInteger gCount = [g numberOfAssets];

    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%d)", [g valueForProperty:ALAssetsGroupPropertyName], gCount];
    [cell.imageView setImage:[UIImage imageWithCGImage:[(ALAssetsGroup *) [self.assetGroups objectAtIndex:(NSUInteger) indexPath.row] posterImage]]];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];

    return cell;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    ALAssetsGroup *group = [self.assetGroups objectAtIndex:(NSUInteger) indexPath.row];
    NSString *groupName = (NSString *) [group valueForProperty:ALAssetsGroupPropertyName];

    FMCameraAssetPickerController *picker = [[FMCameraAssetPickerController alloc] initWithPreviewSize:_previewSize];
    picker.navigationTitle = groupName;
    picker.assetGroup = group;
    picker.savedPhotoGroup = [self.assetGroups objectAtIndex:0];
    [picker.assetGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
    picker.previewView = _previewView;
    [picker selectedAssetsDidFinish:_selectedAssetsDidFinishBlock];
//    [picker selectedAssetsDidFinish:^(FMCameraAssetPickerController *assetTableViewPicker, NSArray *array) {
//        //TODO caiyu @明浩 其他相册asset picker需要指定返回处理
//        TBMBGlobalSendNotificationForSELWithBody(@selector($$postImagePickerDidFinishedNotification:images:),array);
//    }];
    [self.navigationController pushViewController:picker animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 57;
}
@end