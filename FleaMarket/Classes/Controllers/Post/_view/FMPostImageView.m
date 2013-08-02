// 
// Created by henson on 6/21/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <QuartzCore/QuartzCore.h>
#import <MBMvc/TBMBGlobalFacade.h>
#import <BlocksKit/UIView+BlocksKit.h>
#import "FMPostImageView.h"
#import "FMPostImageItemView.h"
#import "FMPostImageDO.h"
#import "UIImage+Helper.h"

@implementation FMPostImageView {
    UIButton *_postImageButton;
    UILabel *_buttonTitleLabel;
    UIButton *_addButton;
    NSMutableArray *_imageItems;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imageItems = [NSMutableArray arrayWithCapacity:5];

        self.backgroundColor = [UIColor whiteColor];
        self.userInteractionEnabled = YES;
        self.layer.borderWidth = 1;
        self.layer.borderColor = [FMColorWithRed(213, 213, 213) CGColor];
        self.layer.cornerRadius = 3.5;

        CGRect postImageRect = {{0, 0}, {120, 100}};
        UIButton *postImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        postImageButton.frame = postImageRect;
        postImageButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 20, 0);
        [postImageButton setImage:[UIImage imageNamed:@"post_camera_icon.png"] forState:UIControlStateNormal];
        [postImageButton addTarget:self
                            action:@selector(takeImage)
                  forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:postImageButton];
        _postImageButton = postImageButton;

        UILabel *buttonTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, 120, 20)];
        buttonTitleLabel.backgroundColor = [UIColor clearColor];
        buttonTitleLabel.textAlignment = NSTextAlignmentCenter;
        buttonTitleLabel.font = FMFont(NO, 12.f);
        buttonTitleLabel.text = @"给宝贝拍个片片";
        buttonTitleLabel.textColor = FMColorWithRed(178, 178, 178);
        [_postImageButton addSubview:buttonTitleLabel];
        _buttonTitleLabel = buttonTitleLabel;

        UIImage *addCameraImage = [UIImage imageWithFileName:@"post_add_image_icon.png"];
        UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [addButton setBackgroundImage:addCameraImage forState:UIControlStateNormal];
        addButton.hidden = YES;
        [addButton addTarget:self action:@selector(takeImage) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:addButton];
        _addButton = addButton;
    }

    return self;
}

- (void)takeImage {
    TBMBGlobalSendNotificationForSEL(@selector($$postImageTakeImage:));
}

- (void)setProgress:(float)progress index:(NSUInteger)index {
    if ([_imageItems count] < 1) {
        return;
    }
    FMPostImageItemView *imageItemView = [_imageItems objectAtIndex:index];
    [imageItemView setProgress:progress];
    return;
}

- (void)setImages:(NSArray *)images {
    for (id obj in [self subviews]) {
        if ([obj isKindOfClass:[FMPostImageItemView class]]) {
            [obj removeFromSuperview];
        }
    }

    [_imageItems removeAllObjects];

    if (!images || [images count] < 1) {
        _addButton.hidden = YES;

        CGRect frame = self.frame;
        frame.size.width = 120;
        frame.origin.x = (FM_SCREEN_WIDTH - 120) / 2.f;
        self.frame = frame;
        _postImageButton.frame = CGRectMake(0, 0, 120, 100);
        _buttonTitleLabel.frame = CGRectMake(0, 70, 120, 20);
        return;
    }

    CGRect frame = self.frame;
    frame.size.width = 300;
    frame.origin.x = 10;
    self.frame = frame;

    _postImageButton.frame = CGRectMake(0, 0, 160, 100);
    CGRect textRect = _buttonTitleLabel.frame;
    textRect.size.width = _postImageButton.frame.size.width;
    _buttonTitleLabel.frame = textRect;

    CGRect imageRect = CGRectZero;
    for (NSUInteger i=0; i<[images count]; i++) {
        FMPostImageDO *postImageDO = [images objectAtIndex:i];
        FMPostImageItemView *imageView = nil;
        imageView = [[FMPostImageItemView alloc] initWithFrame:CGRectZero];
        if (postImageDO.thumbImage) {
            imageView.image = postImageDO.thumbImage;
        }else if (postImageDO.image) {
            imageView.image = postImageDO.image;
        } else {
            [imageView setFMImageWithURL:[postImageDO.imageURL absoluteString]
                          imageScaleType:FMImageScale80x80];
        }

        float x = 160 + (i % 3) * 46;
        float y = i > 2 ? 6 + 46 : 6;
        imageRect = CGRectMake(x, y, 42, 42);
        imageView.frame = imageRect;
        [imageView setIsPrimaryImage:postImageDO.isMasterImage];
        [self addSubview:imageView];
        [_imageItems addObject:imageView];
        imageView.onTouchUpBlock = ^(NSSet *set, UIEvent *event) {
            TBMBGlobalSendNotificationForSELWithBody(@selector($$postImageViewTouch:index:), [NSNumber numberWithInt:i]);
        };
    }

    if ([_imageItems count] > 4) {
        return;
    }

    imageRect.origin.x = [images count] == 3 ? 160 : imageRect.origin.x + 46;
    imageRect.origin.y = [images count] < 3 ? 6 : 46 + 6;
    _addButton.hidden = NO;
    _addButton.frame = imageRect;
}

- (void)dealloc {
    FMLog(@"FMPostImageView dealloc");
}

@end