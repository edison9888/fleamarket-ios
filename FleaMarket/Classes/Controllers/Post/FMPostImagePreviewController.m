// 
// Created by henson on 7/21/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <BlocksKit/UIAlertView+BlocksKit.h>
#import "FMPostImagePreviewController.h"
#import "FMPostImageDO.h"
#import "FMImageView.h"

#define kBottomBarView   90

@implementation FMPostImagePreviewController {
@private
    FMImageView *_imageView;
    __weak UIButton *_masterButton;
    __weak UIButton *_deleteImageButton;

    void (^_selfDismissBlock)(void);
    void (^_selfDeleteDismissBlock)(NSUInteger);
}

- (void)loadView {
    [super loadView];
    self.view.backgroundColor = [UIColor blackColor];
    self.titleView.hidden = YES;

    FMImageView *imageView = [[FMImageView alloc] initWithFrame:CGRectMake(0, 0, FM_SCREEN_WIDTH, (FM_SCREEN_HEIGHT - kBottomBarView))];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.center = CGPointMake(FM_SCREEN_WIDTH / 2.f, (FM_SCREEN_HEIGHT - kBottomBarView)/2.f);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    _imageView = imageView;

    [self initBottomBarView];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    FMPostImageDO *postImageDO = [_imageInfos objectAtIndex:_index];
    if (postImageDO.image) {
        _imageView.image = postImageDO.image;
    } else if (postImageDO.imageURL) {
        [_imageView setWebPImageWithURL:[postImageDO.imageURL absoluteString]
                         imageScaleType:FMImageScale960x960
                       placeholderImage:FMPlaceholderImage
                             isProgress:YES];
    }
    [self setMasterButton];
}

- (void)initBottomBarView {
    UIImageView *imageView  = [[UIImageView alloc] initWithFrame:
            CGRectMake(0, FM_SCREEN_HEIGHT - kBottomBarView, FM_SCREEN_WIDTH, kBottomBarView)];
    imageView.image = [UIImage imageWithFileName:@"bg_bottom_image_preview.png"];
    imageView.userInteractionEnabled = YES;
    [self.view addSubview:imageView];

    UIButton *masterButton = [[UIButton alloc] initWithFrame:
            CGRectMake((FM_SCREEN_WIDTH - 100) / 2, (kBottomBarView - 41) / 2, 100, 41)];
    masterButton.backgroundColor = [UIColor clearColor];
    [masterButton setBackgroundImage:[UIImage imageWithFileName:@"btn_master_image_preview.png"]
                            forState:UIControlStateNormal];
    [masterButton setTitle:@"设为主图" forState:UIControlStateNormal];
    [masterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [masterButton addTarget:self
                     action:@selector(touchMasterButton:)
           forControlEvents:UIControlEventTouchUpInside];
    [imageView addSubview:masterButton];
    _masterButton = masterButton;
    [self setMasterButton];

    UIButton *deleteImageButton = [[UIButton alloc] initWithFrame:
            CGRectMake(270, 25, 40, 40)];
    [deleteImageButton setImage:[UIImage imageWithFileName:@"btn_delete_image_preview.png"]
                       forState:UIControlStateNormal];
    deleteImageButton.backgroundColor = [UIColor clearColor];
    [deleteImageButton addTarget:self
                          action:@selector(touchDeleteButton:)
                forControlEvents:UIControlEventTouchUpInside];
    [imageView addSubview:deleteImageButton];
    _deleteImageButton = deleteImageButton;

    CGRect closeRect = {{5,23}, {44,44}};
    UIButton *closeButton = [[UIButton alloc] initWithFrame:closeRect];
    closeButton.backgroundColor = [UIColor clearColor];
    [closeButton setImage:[UIImage imageNamed:@"post_preview_close_icon.png"]
                       forState:UIControlStateNormal];
    [closeButton addTarget:self
                    action:@selector(closeAction)
          forControlEvents:UIControlEventTouchUpInside];
    [imageView addSubview:closeButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

- (void)dismissController {
    [self dismissViewControllerAnimated:YES completion:^{
        if (_selfDismissBlock) {
            _selfDismissBlock();
        }
    }];
}

- (void)setPostImagePreviewDismiss:(void(^)())block {
    _selfDismissBlock = block;
}

- (void)setDeleteDismiss:(void(^)(NSUInteger))block {
    _selfDeleteDismissBlock = block;
}

- (void)closeAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)touchMasterButton:(id)sender {
    for (NSUInteger i = 0; i < _imageInfos.count; i++) {
        FMPostImageDO *postImageDO = [_imageInfos objectAtIndex:i];
        if (_index == i) {
            postImageDO.isMasterImage = YES;
        } else {
            postImageDO.isMasterImage = NO;
        }
    }
    [self dismissController];
}

- (void)touchDeleteButton:(id)sender {
    __weak FMPostImagePreviewController *weakSelf = self;
    [UIAlertView showAlertViewWithTitle:nil
                                message:@"亲，你确定要删除该宝贝图片？"
                      cancelButtonTitle:@"取消"
                      otherButtonTitles:@[@"确定"]
                                handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                    if (buttonIndex == 0) {
                                        [weakSelf deleteHelp];
                                    }
                                }];
}

- (void)deleteHelp {
    [self dismissViewControllerAnimated:YES completion:^{
        if (_selfDeleteDismissBlock) {
            _selfDeleteDismissBlock(_index);
        }
    }];
}

- (void)setMasterButton {
    if (_imageInfos.count == 0) {
        _deleteImageButton.hidden = YES;
        _masterButton.hidden = YES;
    } else {
        FMPostImageDO *postImageDO = [_imageInfos objectAtIndex:_index];
        _masterButton.hidden = postImageDO.isMasterImage;
    }
}

- (void)dealloc {
    FMLog(@"%@ dealloc", NSStringFromClass([self class]));
}

@end