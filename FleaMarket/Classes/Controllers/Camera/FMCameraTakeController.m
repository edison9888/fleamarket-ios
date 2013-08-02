// 
// Created by henson on 7/8/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <AVFoundation/AVFoundation.h>
#import "FMCameraTakeController.h"
#import "FMCameraFocusLayer.h"
#import "FMCameraTakeToolbar.h"
#import "FMCameraPreviewToolbar.h"
#import "UIImage+Helper.h"
#import "FMCameraAlbumViewController.h"
#import "TBMBGlobalFacade.h"
#import "FMCommon.h"
#import "FMCameraHeaderView.h"

#define squareImageWidth 305 //需要配合mask尺寸来做，并，目前是屏幕scale倍数，后期如果支持用户放大图片截图的，需用对应的scale //当前按1080P的截到的尺寸是1030
#define squareOriginX 8 
#define squareOriginY 62
#define squareOriginYIphone5 87

NSString* const FMCameraOrientationChanged = @"FMCameraOrientationChanged";

@implementation FMCameraTakeController {
    AVCaptureSession *_captureSession;
    AVCaptureDeviceInput *_deviceInput;
    AVCaptureDevice *_device;
    UIView *_videoPreviewView;
    UIView *_cameraView;
    AVCaptureVideoPreviewLayer *_videoPreviewLayer;
    AVCaptureStillImageOutput *_stillImageOutput;
    AVCaptureVideoOrientation _videoOrientation;
    UIDeviceOrientation _deviceOrientation;
    id <UIAccelerometerDelegate> _previousAccelerometeDelegate;
    
    FMCameraFocusLayer *_focusLayer;
    int _tapToAutoFocusNow;

    FMCameraHeaderView *_headerView;
    FMCameraTakeToolbar *_toolbar;
    int _previewSize;
    FMCameraPreviewToolbar *_preview;
    UIImageView *previewImgView;
    CGRect previewImgViewRect;
    UIDeviceOrientation imageOriginOrientation;
    
    // 返回FMAsset
    void (^_selectedAssetsDidFinishBlock)(NSArray *);
}

- (id)init {
    self = [super init];
    if (self) {
        _videoOrientation = AVCaptureVideoOrientationPortrait;
        _focusLayer = [[FMCameraFocusLayer alloc] init];
        _tapToAutoFocusNow = 0;
        self.from = FMCameraFromPost;
        _previewSize = previewSize;
    }

    return self;
}

- (id)initWithSelectedCount:(int)selectedCount {
    self = [self init];
    if (self) {
        _previewSize = previewSize-selectedCount;
    }
    
    return self;
}

- (id)initWithPreviewSize:(int)__previewSize {
    self = [self init];
    if (self) {
        _previewSize = __previewSize;
    }
    
    return self;
}

- (void)selectedAssetsDidFinish:(void (^)( NSArray *))block {
    _selectedAssetsDidFinishBlock = block;
}

- (void)loadView {
    [super loadView];
    __weak FMCameraTakeController *selfWeak = self;
    AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
    [captureSession setSessionPreset:AVCaptureSessionPresetHigh];//AVCaptureSessionPresetPhoto
    _captureSession = captureSession;

    [self setupOutputDevice];
    [self setupInputDevice:AVCaptureDevicePositionBack];

    CGRect cameraRect = {{0,0},{FM_SCREEN_WIDTH, FM_SCREEN_HEIGHT}};
    _cameraView = [[UIView alloc] initWithFrame:cameraRect];
    [self.view addSubview:_cameraView];

    CGRect previewRect = {{0,0}, {FM_SCREEN_WIDTH, FM_SCREEN_HEIGHT- 89.5}};
    _videoPreviewView = [[UIView alloc] initWithFrame:previewRect];
    [_cameraView addSubview:_videoPreviewView];
    [self setupPresentLayer];

    UIImage *layoutImage;
    if (IS_IPHONE_5) {
        layoutImage = [[UIImage imageNamed:@"camera_preview_layout_iphone5"] resizableImageWithCapInsets:UIEdgeInsetsMake(squareOriginYIphone5, 8, 88, 8)];
    }else{
        layoutImage = [[UIImage imageNamed:@"camera_preview_layout.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(squareOriginY, 8, 25, 8)];
    }
    UIImageView *layoutImageView = [[UIImageView alloc] initWithImage:layoutImage];
    layoutImageView.frame = CGRectMake(0, 0, FM_SCREEN_WIDTH, FM_SCREEN_HEIGHT - 89.5);
    [_cameraView addSubview:layoutImageView];

    CGRect headerViewRect = {{0,10}, {FM_SCREEN_WIDTH, 50}};
    FMCameraHeaderView *cameraHeaderView = [[FMCameraHeaderView alloc] initWithFrame:headerViewRect];
    cameraHeaderView.backgroundColor = [UIColor clearColor];
    [cameraHeaderView setFlashTouch:^{
        [selfWeak cameraFlashTouchAction];
    }];
    [cameraHeaderView setDevicePositionTouch:^{
        [selfWeak cameraDevicePositionTouchAction];
    }];
    [_cameraView addSubview:cameraHeaderView];
    _headerView = cameraHeaderView;

    CGRect toolbarRect = {{0, FM_SCREEN_HEIGHT - 89.5}, {FM_SCREEN_WIDTH, 89.5}};
    FMCameraTakeToolbar *toolbar = [[FMCameraTakeToolbar alloc] initWithFrame:toolbarRect withPreviewSize:_previewSize];
    toolbar.backgroundColor = [UIColor clearColor];
    [toolbar setCloseAction:^{
        [selfWeak closeAction];
    }];
    [toolbar setTakePictureAction:^{
        [selfWeak takePicture];
    }];
    [toolbar setShowAlbum:^{
        [selfWeak showAlbum];
    }];
    [self.view addSubview:toolbar];
    _toolbar = toolbar;
    
    if (self.from==FMCameraFromAlbum) {
        [_toolbar removeCloseBtn];
    }
    
    FMCameraPreviewToolbar *preview = [[FMCameraPreviewToolbar alloc] initWithFrame:toolbarRect];
    preview.backgroundColor = [UIColor clearColor];
    [preview setRetakePictureAction:^{
        [selfWeak retakePictureAction];
    }];
    _preview = preview;
 
    previewImgViewRect = _cameraView.frame;
    previewImgView = [[UIImageView alloc]initWithFrame:previewImgViewRect];
    
    [_captureSession startRunning];
    [self defaultConfigure];
    [self setupFocusAndOrientation];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationNone];
    _previousAccelerometeDelegate = [UIAccelerometer sharedAccelerometer].delegate;
    [[UIAccelerometer sharedAccelerometer] setDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationNone];
}


#pragma mark - loadview setups

- (void)setupFocusAndOrientation {
    _focusLayer = [FMCameraFocusLayer layer];
    _focusLayer.opaque = NO;
    _focusLayer.backgroundColor = [UIColor clearColor].CGColor;
    _focusLayer.hidden = YES;
    [_videoPreviewView.layer insertSublayer:_focusLayer above:_videoPreviewLayer];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]
                                         initWithTarget:self action:@selector(tapToAutoFocus:)];
    [singleTap setNumberOfTapsRequired:1];
    [_videoPreviewView addGestureRecognizer:singleTap];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(startFocusCallback:)
                   name:@"Recorder_DidStartFocusOperation"
                 object:nil];
    
    [center addObserver:self
               selector:@selector(cameraOrientationChangedCallback:)
                   name:FMCameraOrientationChanged
                 object:nil];
}

- (void)setupOutputDevice {
    AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [stillImageOutput setOutputSettings:outputSettings];
    _stillImageOutput = stillImageOutput;
    if ([_captureSession canAddOutput:_stillImageOutput]) {
        [_captureSession addOutput:_stillImageOutput];
    }
}

- (void)setupInputDevice:(AVCaptureDevicePosition)position {
    _deviceInput = nil;
    AVCaptureDevice *device = [FMCameraTakeController cameraWithPosition:position];
    _device = device;
    AVCaptureDeviceInput *videoDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:nil];
    _deviceInput = videoDeviceInput;
    
    if ([_captureSession canAddInput:_deviceInput]) {
        [_captureSession addInput:_deviceInput];
    }
}

- (void)setupPresentLayer {
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    CALayer *previewLayer = [_videoPreviewView layer];
    [previewLayer setMasksToBounds:YES];
    
    //    CGRect bounds = [_videoPreviewView bounds];
    CGRect bounds = CGRectMake(0, 0, FM_SCREEN_WIDTH, FM_SCREEN_HEIGHT);//[_cameraView bounds];
    [captureVideoPreviewLayer setFrame:bounds];
    
    //    if ([captureVideoPreviewLayer isOrientationSupported]) {
    //        [captureVideoPreviewLayer setOrientation:_videoOrientation];
    //    }
    
    [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];//AVLayerVideoGravityResize, AVLayerVideoGravityResizeAspect AVLayerVideoGravityResizeAspectFill
    [previewLayer insertSublayer:captureVideoPreviewLayer
                           below:[[previewLayer sublayers] objectAtIndex:0]];
    
    _videoPreviewLayer = captureVideoPreviewLayer;
}

- (void)defaultConfigure {
    AVCaptureDevice *device = [_deviceInput device];
    NSError *error;
    if ([device lockForConfiguration:&error]) {
        if ([device hasFlash] && [device flashMode] != AVCaptureFlashModeOff) {
            [device setFlashMode:AVCaptureFlashModeOff];
        }
        
        if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus] && [device focusMode] != AVCaptureFocusModeContinuousAutoFocus) {
            [device setFocusPointOfInterest:CGPointMake(0.5, 0.5)];
            [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
        
        [device unlockForConfiguration];
    }
}

#pragma mark - Focus function

- (void)startFocusCallback:(NSNotification *)notification {
    if (_tapToAutoFocusNow) {
        _tapToAutoFocusNow = 0;
    }
    else {
        //AVCaptureDevice* device = [myDeviceInput device];
        //if ([device isAdjustingFocus])
        {
            [self showFocusRectAt:_videoPreviewView.center forLockFocus:YES];
        }
    }
}

- (void)tapToFocusAtPoint:(CGPoint)point {
    AVCaptureDevice *device = [_deviceInput device];
    if ([device isFocusPointOfInterestSupported]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            [device setFocusPointOfInterest:point];
            [device setFocusMode:AVCaptureFocusModeAutoFocus];
            if ([device respondsToSelector:@selector(setSubjectAreaChangeMonitoringEnabled:)]) {
                [device setSubjectAreaChangeMonitoringEnabled:YES];
            }
            [device unlockForConfiguration];
            _tapToAutoFocusNow = 1;
        }
    }
}

- (void)tapToAutoFocus:(UIGestureRecognizer *)gestureRecognizer {
    AVCaptureDevice *device = [_deviceInput device];
    if ([device isAdjustingFocus]) {
        return;
    }
    CGPoint tapPoint = [gestureRecognizer locationInView:_videoPreviewView];
    CGPoint convertedFocusPoint = [self convertToPointOfInterestFromViewCoordinates:tapPoint];
    [self tapToFocusAtPoint:convertedFocusPoint];
    [self showFocusRectAt:tapPoint forLockFocus:NO];
}

- (void)showFocusRectAt:(CGPoint)center forLockFocus:(BOOL)y {
    CGFloat wh1 = y ? 240.f : 120.f;
    CGFloat wh2 = y ? 180.f : 90.f;
    CGFloat wh3 = y ? 120.f : 60.f;
    _focusLayer.frame = CGRectMake(center.x - wh1 / 2, center.y - wh1 / 2, wh1, wh1);
    _focusLayer.hidden = NO;
    [_focusLayer setNeedsDisplay];
    
    CAKeyframeAnimation *animation1 = [CAKeyframeAnimation animationWithKeyPath:@"bounds"];
    NSMutableArray *values1 = [NSMutableArray array];
    [values1 addObject:[NSValue valueWithCGRect:CGRectMake(0, 0, wh2, wh2)]];
    [values1 addObject:[NSValue valueWithCGRect:CGRectMake(0, 0, wh3, wh3)]];
    
    animation1.values = values1;
    animation1.duration = 0.1f;
    animation1.fillMode = kCAFillModeForwards;
    animation1.removedOnCompletion = NO;
    
    //----
    CAKeyframeAnimation *animation2 = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    NSMutableArray *values2 = [NSMutableArray array];
    [values2 addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1, 1.1, 1.1)]];
    [values2 addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 0.9)]];
    [values2 addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    
    animation2.values = values2;
    animation2.duration = 1.0;
    animation2.removedOnCompletion = NO;
    animation2.fillMode = kCAFillModeForwards;
    animation2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
    animGroup.animations = [NSArray arrayWithObjects:animation1, animation2, nil];
    animGroup.duration = 1.2f;
    animGroup.delegate = self;
    animGroup.fillMode = kCAFillModeForwards;
    animGroup.removedOnCompletion = NO;
    animGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    [_focusLayer removeAllAnimations];
    [_focusLayer addAnimation:animGroup forKey:@"startFocus"];
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag {
    [_focusLayer removeAllAnimations];
    _focusLayer.hidden = YES;
}

- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates {
    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
    CGSize frameSize = _videoPreviewView.frame.size;
    
    if ([_videoPreviewLayer isMirrored])
        viewCoordinates.x = frameSize.width - viewCoordinates.x;
    
    if ([[_videoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResize]) {
        // Scale, switch x and y, and reverse x
        pointOfInterest = CGPointMake(viewCoordinates.y / frameSize.height, 1.f - (viewCoordinates.x / frameSize.width));
    }
    else {
        CGRect cleanAperture;
        for (AVCaptureInputPort *port in [_deviceInput ports]) {
            if ([port mediaType] == AVMediaTypeVideo) {
                cleanAperture = CMVideoFormatDescriptionGetCleanAperture([port formatDescription], YES);
                CGSize apertureSize = cleanAperture.size;
                CGPoint point = viewCoordinates;
                
                CGFloat apertureRatio = apertureSize.height / apertureSize.width;
                CGFloat viewRatio = frameSize.width / frameSize.height;
                CGFloat xc = .5f;
                CGFloat yc = .5f;
                NSString *G = [_videoPreviewLayer videoGravity];
                
                if ([G isEqualToString:AVLayerVideoGravityResizeAspect]) {
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = frameSize.height;
                        CGFloat x2 = frameSize.height * apertureRatio;
                        CGFloat x1 = frameSize.width;
                        CGFloat blackBar = (x1 - x2) / 2;
                        
                        // If point is inside letterboxed area, do coordinate conversion; otherwise, don't change the default value returned (.5,.5)
                        if (point.x >= blackBar && point.x <= blackBar + x2) {
                            // Scale (accounting for the letterboxing on the left and right of the video preview), switch x and y, and reverse x
                            xc = point.y / y2;
                            yc = 1.f - ((point.x - blackBar) / x2);
                        }
                    }
                    else {
                        CGFloat y2 = frameSize.width / apertureRatio;
                        CGFloat y1 = frameSize.height;
                        CGFloat x2 = frameSize.width;
                        CGFloat blackBar = (y1 - y2) / 2;
                        // If point is inside letterboxed area, do coordinate conversion. Otherwise, don't change the default value returned (.5,.5)
                        if (point.y >= blackBar && point.y <= blackBar + y2) {
                            // Scale (accounting for the letterboxing on the top and bottom of the video preview), switch x and y, and reverse x
                            xc = ((point.y - blackBar) / y2);
                            yc = 1.f - (point.x / x2);
                        }
                    }
                }
                else if ([G isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
                    // Scale, switch x and y, and reverse x
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = apertureSize.width * (frameSize.width / apertureSize.height);
                        xc = (point.y + ((y2 - frameSize.height) / 2.f)) / y2; // Account for cropped height
                        yc = (frameSize.width - point.x) / frameSize.width;
                    }
                    else {
                        CGFloat x2 = apertureSize.height * (frameSize.height / apertureSize.width);
                        yc = 1.f - ((point.x + ((x2 - frameSize.width) / 2)) / x2); // Account for cropped width
                        xc = point.y / frameSize.height;
                    }
                }
                
                pointOfInterest = CGPointMake(xc, yc);
                break;
            }
        }
    }
    
    return pointOfInterest;
}

#pragma mark - orientation changed

- (void)cameraOrientationChangedCallback:(NSNotification *)notification {
        CGAffineTransform t = CGAffineTransformIdentity;
        switch (_deviceOrientation) {
            case UIDeviceOrientationPortrait:
                [_toolbar.previewView setTransform:t];
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                [_toolbar.previewView setTransform:CGAffineTransformRotate(t, (CGFloat) M_PI)];
                break;
                
            case UIDeviceOrientationLandscapeRight:
                [_toolbar.previewView setTransform:CGAffineTransformRotate(t, (CGFloat) M_PI_2)];
                break;
                
            case UIDeviceOrientationLandscapeLeft:
                [_toolbar.previewView setTransform:CGAffineTransformRotate(t, (CGFloat) -M_PI_2)];
                break;
            default:
                break;
        }
}

- (void)setPreviewImgViewOrientation{
    CGSize sz = previewImgViewRect.size;
    CGAffineTransform t = CGAffineTransformIdentity;
    imageOriginOrientation = _deviceOrientation;
    switch (_deviceOrientation) {
        case UIDeviceOrientationPortrait:
            previewImgView.bounds = CGRectMake(0, 0, sz.width, sz.height);
            previewImgView.center = CGPointMake(FM_SCREEN_WIDTH / 2, FM_SCREEN_HEIGHT/ 2);
            [previewImgView setTransform:t];
            if ([_headerView positionType]==kFMCameraDevicePositionFront) {
                previewImgView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
            }
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            previewImgView.bounds = CGRectMake(0, 0, sz.width, sz.height);
            previewImgView.center = CGPointMake(FM_SCREEN_WIDTH/ 2, FM_SCREEN_HEIGHT/ 2);
            [previewImgView setTransform:CGAffineTransformRotate(t, (CGFloat) M_PI)];
            if ([_headerView positionType]==kFMCameraDevicePositionFront) {
                previewImgView.transform = CGAffineTransformConcat(previewImgView.transform,CGAffineTransformMakeScale(-1.0, 1.0));
            }
            break;
        case UIDeviceOrientationLandscapeRight:
            previewImgView.bounds = CGRectMake(0, 0, sz.height, sz.width);
            previewImgView.center = CGPointMake(FM_SCREEN_WIDTH/ 2, FM_SCREEN_HEIGHT / 2);
            [previewImgView setTransform:CGAffineTransformRotate(CGAffineTransformIdentity, (CGFloat) M_PI_2)];
            if ([_headerView positionType]==kFMCameraDevicePositionFront) {
                previewImgView.transform = CGAffineTransformConcat(previewImgView.transform,CGAffineTransformMakeScale(1.0, -1.0));
            }
            break;
        case UIDeviceOrientationLandscapeLeft:
            previewImgView.bounds = CGRectMake(0, 0, sz.height, sz.width);
            previewImgView.center = CGPointMake(FM_SCREEN_WIDTH/ 2, FM_SCREEN_HEIGHT / 2);
            [previewImgView setTransform:CGAffineTransformRotate(CGAffineTransformIdentity, (CGFloat) -M_PI_2)];
            if ([_headerView positionType]==kFMCameraDevicePositionFront) {
                previewImgView.transform = CGAffineTransformConcat(previewImgView.transform,CGAffineTransformMakeScale(1.0, -1.0));
            }
            break;
        default:
            break;
    }
}



#pragma mark - actions

- (void)retakePictureAction {
    _videoPreviewView.hidden = NO;
    _headerView.hidden = NO;
    [previewImgView removeFromSuperview];
    [_toolbar enableTakeButton];
//    [self unfreezePreview];
}

- (void)closeAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showAlbum {
    __weak FMCameraTakeController *selfWeak = self;
    if (self.from == FMCameraFromPost) {
        FMCameraAlbumViewController *cameraAlbumViewController = [[FMCameraAlbumViewController alloc] initWithPrevieSize:_previewSize];
        [cameraAlbumViewController setTakenUrls:_toolbar.selectedAssets];
        [cameraAlbumViewController selectedAssetsDidFinish:_selectedAssetsDidFinishBlock];
        [self.navigationController dismissViewControllerAnimated:NO completion:^{
            if (selfWeak.delegate) {
                [selfWeak.delegate presentViewController:cameraAlbumViewController animated:YES completion:nil];
            }
        }];
        return;
    }else if(self.from == FMCameraFromAlbum){
        [selfWeak dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter]postNotificationName:@"reloadAssetsNotification" object:self userInfo:[NSDictionary dictionaryWithObject:_toolbar.selectedAssets forKey:@"assets"]];
        }];
        return;
    }
    [selfWeak dismissViewControllerAnimated:YES completion:nil];
    return;
}


- (void)takePicture {
    __weak FMCameraTakeController *selfWeak = self;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];

    AVCaptureConnection *stillImageConnection = [FMCameraTakeController
            connectionWithMediaType:AVMediaTypeVideo
                    fromConnections:[_stillImageOutput connections]];
    if ([stillImageConnection isVideoOrientationSupported]) {
        [stillImageConnection setVideoOrientation:_videoOrientation];
    }

    void (^MyBlock)(CMSampleBufferRef, NSError *) = ^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer != NULL) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *previewImg = [[UIImage alloc] initWithData:imageData];
            //适用_videoPreviewLayer videoGravity＝AVLayerVideoGravityResizeAspectFill
            float scaleX = MIN(previewImg.size.width, previewImg.size.height)/FM_SCREEN_WIDTH,scaleY = MAX(previewImg.size.width, previewImg.size.height)/FM_SCREEN_HEIGHT;
            if (scaleX>scaleY) {
                float width = FM_SCREEN_WIDTH*scaleX/scaleY;
                previewImgViewRect = CGRectMake((FM_SCREEN_WIDTH-width)/2, 0, width, FM_SCREEN_HEIGHT);
            }else{
                float height = FM_SCREEN_HEIGHT*scaleY/scaleX;
                previewImgViewRect = CGRectMake(0, (FM_SCREEN_HEIGHT-height)/2, FM_SCREEN_WIDTH, height);
            }
            previewImgView.frame = previewImgViewRect;

            previewImgView.image = previewImg;
            [self setPreviewImgViewOrientation];
            [_cameraView addSubview:previewImgView];
            [_cameraView sendSubviewToBack:previewImgView];
            _videoPreviewView.hidden = YES;
            _headerView.hidden = YES;
//            [self freezePreview];
            [_preview setUsePictureAction:^{
                [selfWeak saveAndUseImage:previewImg];
            }];
            [self.view addSubview:_preview];
            
        }
    };

    [_stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection completionHandler:MyBlock];
}

- (void)cameraFlashTouchAction {
    AVCaptureDevice *device = [_deviceInput device];
    NSError *error;
    if ([device hasFlash] && [device lockForConfiguration:&error]) {
        [device setFlashMode:_headerView.isOpenFlash ? AVCaptureFlashModeOn : AVCaptureFlashModeOff];
        [device unlockForConfiguration];
    }
}

- (void)cameraDevicePositionTouchAction {
    AVCaptureSession *oldSession = _captureSession;
    AVCaptureDevice *newCamera = nil;

    NSArray *inputs = _captureSession.inputs;

    for (AVCaptureDeviceInput *input in inputs) {
        AVCaptureDevice *device = input.device;
        if ([device hasMediaType:AVMediaTypeVideo]) {
            AVCaptureDevicePosition position = device.position;
            if (position == AVCaptureDevicePositionFront)
                newCamera = [FMCameraTakeController cameraWithPosition:AVCaptureDevicePositionBack];
            else
                newCamera = [FMCameraTakeController cameraWithPosition:AVCaptureDevicePositionFront];
            break;
        }
    }

    AVCaptureSession *newSession = [[AVCaptureSession alloc] init];
    [newSession setSessionPreset:AVCaptureSessionPresetHigh];// AVCaptureSessionPresetPhoto

    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
    [newSession addInput:input];

    AVCaptureStillImageOutput *newOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [_stillImageOutput setOutputSettings:outputSettings];
    [newSession addOutput:newOutput];

    UIView *newMonitorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, FM_SCREEN_WIDTH, FM_SCREEN_HEIGHT)];
    newMonitorView.backgroundColor = [UIColor grayColor];
    AVCaptureVideoPreviewLayer *newMonitorLayer = [AVCaptureVideoPreviewLayer layerWithSession:newSession];
    newMonitorLayer.frame = newMonitorView.bounds;
    newMonitorLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [newMonitorView.layer addSublayer:newMonitorLayer];

    //动画开始
    [UIView beginAnimations:@"Flip" context:nil];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView transitionWithView:_cameraView
                      duration:1.0f
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
        [_videoPreviewView removeFromSuperview];

        [_cameraView addSubview:newMonitorView];
        [_cameraView sendSubviewToBack:newMonitorView];

        _videoPreviewView = nil;
        _videoPreviewView = newMonitorView;

        _videoPreviewLayer = nil;
        _videoPreviewLayer = newMonitorLayer;

        _device = nil;
        _device = newCamera;
         
        _captureSession = nil;
        _captureSession = newSession;

        _stillImageOutput = newOutput;
        [_captureSession startRunning];
    } completion:^(BOOL r) {
        [oldSession stopRunning];
        [self setupFocusAndOrientation];
    }];
    [UIView commitAnimations];
}

#pragma mark - action take and use image

-(void)saveAndUseImage:(UIImage*)image{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    UIImage *squareImage  = [self crop2SquareImage:image];
    
    UIImageView *targetView = [[UIImageView alloc]initWithImage:squareImage];
    targetView.frame = CGRectMake(squareOriginX-0.5, (IS_IPHONE_5?squareOriginYIphone5:squareOriginY)-0.5, squareImageWidth, squareImageWidth);
    [self.view addSubview:targetView];
    float orgx=targetView.frame.size.width,orgy=targetView.frame.size.height;
    float scale = 48.0f/squareImageWidth;
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.calculationMode = kCAAnimationPaced;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.duration = 0.4;
    pathAnimation.repeatCount = 1;
    
    CGMutablePathRef curvedPath = CGPathCreateMutable();
    CGPathMoveToPoint(curvedPath, &CGAffineTransformIdentity, squareOriginX-0.5+orgx/2,(IS_IPHONE_5?squareOriginYIphone5:squareOriginY)-0.5+orgy/2);
    CGPathAddQuadCurveToPoint(curvedPath, &CGAffineTransformIdentity,squareImageWidth-100,(IS_IPHONE_5?squareOriginYIphone5:squareOriginY)+120, (FM_SCREEN_WIDTH-15-48/2-2.5),(FM_SCREEN_HEIGHT-45-24));
    pathAnimation.path = curvedPath;
    CGPathRelease(curvedPath);
    [targetView.layer addAnimation:pathAnimation forKey:@"moveTheSquare"];
    
    [UIView animateWithDuration:0.4 animations:^{
        targetView.transform = CGAffineTransformMakeScale(scale,scale);
    } completion:^(BOOL finished) {
        if (finished) {
            [targetView removeFromSuperview];
        }
    }];
    [_preview removeFromSuperview];
    [library writeImageToSavedPhotosAlbum:squareImage.CGImage
                                 metadata:nil
                          completionBlock:^(NSURL *assetURL, NSError *error) {
                              if (error) {
                                  FMLOG(@"library save image to album has error:%@", error);
                                  [FMCommon showToast:self.view text:@"图像保存出错了:("];
                              }else{
                                  [_toolbar.selectedAssets addObject:[assetURL copy]];
                                  [_toolbar refreshPreview:squareImage];
                                  [previewImgView removeFromSuperview];
                                  _videoPreviewView.hidden = NO;
                                  _headerView.hidden = NO;
                              }
                          }];

}


-(UIImage*)crop2SquareImage:(UIImage*)image{
    image = [image ajustOrientation:image];
    CGRect toRect;
    float scaleX = MIN(image.size.width, image.size.height)/previewImgView.frame.size.width,scaleY = MAX(image.size.width, image.size.height)/previewImgView.frame.size.height;
    float scale = MAX(scaleX, scaleY);
    float deltaX=0,deltaY=0;
    if (scaleX>scaleY) {
        deltaY =(scaleX*FM_SCREEN_HEIGHT-MAX(image.size.width, image.size.height))/2;
    }else{
        deltaX = (scaleY*FM_SCREEN_WIDTH-MIN(image.size.width, image.size.height))/2;
    }

    float squareOriginYReal = IS_IPHONE_5?squareOriginYIphone5:squareOriginY;
    if (imageOriginOrientation==UIDeviceOrientationPortrait) {
        toRect = CGRectMake(((squareOriginX-0.5))*scaleX-deltaX, ((squareOriginYReal-0.5))*scaleY-deltaY, squareImageWidth*scale, squareImageWidth*scale);
    }else if(imageOriginOrientation==UIDeviceOrientationPortraitUpsideDown){
        toRect = CGRectMake(((squareOriginX-0.5))*scaleX-deltaX, image.size.height-(((squareOriginYReal-0.5))*scaleY-deltaY)-squareImageWidth*scale, squareImageWidth*scale, squareImageWidth*scale);
    }else if(imageOriginOrientation == UIDeviceOrientationLandscapeRight){
        if ([_headerView positionType]==kFMCameraDevicePositionFront) {
            toRect = CGRectMake(image.size.width-((squareOriginYReal-0.5)*scaleY-deltaY)-squareImageWidth*scale, (squareOriginX-0.5)*scaleX-deltaX, squareImageWidth*scale, squareImageWidth*scale);
        }else{
            toRect = CGRectMake((squareOriginYReal-0.5)*scaleY-deltaY, (squareOriginX-0.5)*scaleX-deltaX, squareImageWidth*scale, squareImageWidth*scale);
        }
    }else{
        if ([_headerView positionType]==kFMCameraDevicePositionFront) {
            toRect = CGRectMake((squareOriginYReal-0.5)*scaleY-deltaY, (squareOriginX-0.5)*scaleX-deltaX, squareImageWidth*scale, squareImageWidth*scale);
        }else{
            toRect = CGRectMake(image.size.width-((squareOriginYReal-0.5)*scaleY-deltaY)-squareImageWidth*scale, (squareOriginX-0.5)*scaleX-deltaX, squareImageWidth*scale, squareImageWidth*scale);
        }
    }
    return [image cropImage:image to:toRect];
}

#pragma mark - accelerometer delegate

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration{
    // Get the current device angle
    float xx = (float) -[acceleration x];
    float yy = (float) [acceleration y];
    float angle = (float) atan2(yy, xx);
    
    if (angle >= -2.25 && angle <= -0.25) { // UIInterfaceOrientationPortrait
        if (fabsf(yy) < 0.1)
            return;
        
        if (_deviceOrientation != UIDeviceOrientationPortrait) {
            _videoOrientation = AVCaptureVideoOrientationPortrait;
            _deviceOrientation = UIDeviceOrientationPortrait;
            [[NSNotificationCenter defaultCenter] postNotificationName:FMCameraOrientationChanged
                                                                object:self];
        }
    } else if (angle >= -1.75 && angle <= 0.75) { //AVCaptureVideoOrientationLandscapeLeft
        if (fabsf(xx) < 0.1)
            return;
        
        if (_deviceOrientation != UIDeviceOrientationLandscapeRight) {
            _videoOrientation = AVCaptureVideoOrientationLandscapeRight;
            _deviceOrientation = UIDeviceOrientationLandscapeRight;
            [[NSNotificationCenter defaultCenter] postNotificationName:FMCameraOrientationChanged
                                                                object:self];
        }
    } else if (angle >= 0.75 && angle <= 2.25) { //UIInterfaceOrientationPortraitUpsideDown
        if (fabsf(yy) < 0.1)
            return;
        
        if (_deviceOrientation != UIDeviceOrientationPortraitUpsideDown) {
            _videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
            _deviceOrientation = UIDeviceOrientationPortraitUpsideDown;
            [[NSNotificationCenter defaultCenter] postNotificationName:FMCameraOrientationChanged
                                                                object:self];
        }
    } else if (angle <= -2.25 || angle >= 2.25) { //AVCaptureVideoOrientationLandscapeRight
        if (fabsf(xx) < 0.1)
            return;
        
        if (_deviceOrientation != UIDeviceOrientationLandscapeLeft) {
            _videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
            _deviceOrientation = UIDeviceOrientationLandscapeLeft;
            [[NSNotificationCenter defaultCenter] postNotificationName:FMCameraOrientationChanged
                                                                object:self];
        }
    }
}

#pragma mark - others

// 这种方式显示预览会有问题
//-(void)freezePreview{
//    _videoPreviewLayer.connection.enabled=NO;
//    
//}
//
//-(void)unfreezePreview{
//    _videoPreviewLayer.connection.enabled=YES;
//}

-(void)dealloc{
    [[UIAccelerometer sharedAccelerometer] setDelegate:_previousAccelerometeDelegate];
    [_captureSession stopRunning];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position)
            return device;
    }
    return nil;
}

+ (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType
                                 fromConnections:(NSArray *)connections {
    for (AVCaptureConnection *connection in connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:mediaType])
                return connection;
        }
    }
    return nil;
}

@end