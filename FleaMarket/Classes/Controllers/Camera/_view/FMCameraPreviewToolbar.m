//
//  FMCameraPreviewToolbar.m
//  FleaMarket
//
//  Created by Caiyu on 13-7-22.
//  Copyright (c) 2013年 taobao.com. All rights reserved.
//

#import "FMCameraPreviewToolbar.h"

@implementation FMCameraPreviewToolbar{

UIButton *_retakeButton;
UIButton *_useButton;

void (^_retakePictureBlock)(void);
void (^_usePictureBlock)(void);
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupBgImageView];

        UIImage *retakeImage = [UIImage imageNamed:@"preview_toolbar_retake"];
        CGRect retakeRect ={{14, (frame.size.height-retakeImage.size.height)/2.f},retakeImage.size};
        UIButton *retakeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [retakeButton setBackgroundImage:retakeImage forState:UIControlStateNormal];
        [retakeButton setTitle:@"重拍" forState:UIControlStateNormal];
        retakeButton.titleLabel.font = [UIFont boldSystemFontOfSize:retakeImage.size.height/2.5];
        [retakeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [retakeButton addTarget:self action:@selector(retakeAction) forControlEvents:UIControlEventTouchUpInside];
        retakeButton.frame = retakeRect;
        [self addSubview:retakeButton];
        _retakeButton = retakeButton;
        
        CGSize labelSize ={100,retakeImage.size.height};
        CGRect labelRect = {{(frame.size.width - labelSize.width) / 2.f, (frame.size.height-labelSize.height)/2.f}, labelSize};
        UILabel *label = [[UILabel alloc]initWithFrame:labelRect];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:retakeImage.size.height/2.5];
        label.textColor = [UIColor whiteColor];
        label.text = @"预览";
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];

        UIImage *useImage = [UIImage imageNamed:@"preview_toolbar_use"];
        CGRect useRect = {{frame.size.width - 14 - useImage.size.width,(frame.size.height - useImage.size.height)/2.f}, useImage.size};
        UIButton *useButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [useButton setBackgroundImage:useImage forState:UIControlStateNormal];
        [useButton setTitle:@"确认" forState:UIControlStateNormal];
        useButton.titleLabel.font = [UIFont boldSystemFontOfSize:useImage.size.height/2.5];
        [useButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [useButton addTarget:self
                         action:@selector(useAction)
               forControlEvents:UIControlEventTouchUpInside];
        useButton.frame = useRect;
        [self addSubview:useButton];
        _useButton = useButton;
    }
    
    return self;
    
}

-(void)retakeAction{
    [self removeFromSuperview];
    _retakePictureBlock();
}

- (void)setRetakePictureAction:(void (^)(void))block{
    _retakePictureBlock = block;
}

-(void)useAction{
    _useButton.enabled = NO;
    _usePictureBlock();
}

- (void)setUsePictureAction:(void (^)(void))block{
    _useButton.enabled = YES;
    _usePictureBlock = block;
}

- (void)setupBgImageView {
    UIImage *bgImage = [[UIImage imageNamed:@"camera_toolbar_bg.png"]
                        resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:bgImage];
    imageView.frame = self.bounds;
    [self addSubview:imageView];
}
@end
