// 
// Created by henson on 7/21/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import "FMPostImageItemView.h"

@implementation FMPostImageItemView {
    UILabel *_primaryLabel;
    UIView *_progressView;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
    }

    return self;
}

- (id)initWithImage:(UIImage *)image {
    self = [super initWithImage:image];
    if (self) {
        [self initViews];
    }

    return self;
}

- (void)initViews {
    self.userInteractionEnabled = YES;
    self.clipsToBounds = YES;

    CGRect progressRect = {{0, self.bounds.size.height}, self.bounds.size};
    UIView *progressView = [[UIView alloc] initWithFrame:progressRect];
    progressView.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.5];
    progressView.hidden = YES;
    [self addSubview:progressView];
    _progressView = progressView;

    UILabel *primaryLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    primaryLabel.textAlignment = NSTextAlignmentCenter;
    primaryLabel.font = FMFont(NO, 12.f);
    primaryLabel.textColor = [UIColor whiteColor];
    primaryLabel.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.7];
    primaryLabel.text = @"主图";
    primaryLabel.hidden = YES;
    [self addSubview:primaryLabel];
    _primaryLabel = primaryLabel;
}

- (void)setProgress:(float)progress {
    _progressView.hidden = NO;
    CGRect progressRect = {{0, self.bounds.size.height * progress},self.bounds.size};
    _progressView.frame = progressRect;
    return;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect primaryRect = {{0, self.frame.size.height / 2.f}, {self.frame.size.width, self.frame.size.height / 2.f}};
    _primaryLabel.frame = primaryRect;

    CGRect progressRect = {{0, self.bounds.size.height},self.bounds.size};
    _progressView.frame = progressRect;
}

- (void)setIsPrimaryImage:(BOOL)isPrimaryImage {
    _isPrimaryImage = isPrimaryImage;

    _primaryLabel.hidden = !isPrimaryImage;
    return;
}

@end