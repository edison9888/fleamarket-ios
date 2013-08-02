//
//  FMScrollView.m
//  FleaMarket
//
//  Created by yuanxiao on 12-9-21.
//  Copyright (c) 2012年 taobao.com. All rights reserved.
//

#import "FMImageScrollView.h"
#import "FMImageView.h"

@implementation FMImageScrollView {
@private
    FMImageView    *_imageView;
    NSString        *_imageUrl;
    BOOL            _isLoad;
}

@synthesize imageUrl = _imageUrl;

@synthesize imageView = _imageView;

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
        self.delegate = self;
		self.minimumZoomScale = 1.0;
		self.maximumZoomScale = 3.0;
		self.showsVerticalScrollIndicator = NO;
		self.showsHorizontalScrollIndicator = NO;

        _imageView  = [[FMImageView alloc] initWithFrame:CGRectMake(0, 0,
                self.frame.size.width, self.frame.size.height)];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
		[self addSubview:_imageView];
        _isLoad = NO;
    }
       return self;
}

- (void)downLoad
{
    if (_isLoad) {
        return;
    }
    _isLoad = YES;
    [_imageView setWebPImageWithURL:_imageUrl
                     imageScaleType:FMImageScale960x960
                   placeholderImage:FMPlaceholderImage
                         isProgress:YES];
}

#pragma mark === UIScrollView Delegate ===
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{	
	return _imageView;
}

@end
