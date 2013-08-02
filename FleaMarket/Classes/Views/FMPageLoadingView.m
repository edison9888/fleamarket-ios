// 
// Created by henson on 1/26/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import "FMPageLoadingView.h"
#import "NSString+Helper.h"
#import "UIImage+Helper.h"

@implementation FMPageLoadingView {
    UIActivityIndicatorView *_indicatorView;
    UIImageView *_logoImageView;
    UILabel *_textLabel;
    void (^_touchAction)(void);
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *logoImage = [UIImage imageWithFileName:@"loading_logo.png"];
        _logoImageView = [[UIImageView alloc] initWithImage:logoImage];
        _logoImageView.backgroundColor = [UIColor clearColor];
        _logoImageView.center = CGPointMake(frame.size.width /2.f, frame.size.height/2.f - 30);
        [self addSubview:_logoImageView];

        _indicatorView = [[UIActivityIndicatorView alloc]
                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicatorView.backgroundColor = [UIColor clearColor];
        _indicatorView.center = CGPointMake(frame.size.width / 2.f, frame.size.height/2.f + 10);
        [self addSubview:_indicatorView];

        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 45, FM_SCREEN_WIDTH, 20)];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.center = CGPointMake(frame.size.width / 2.f, frame.size.height/2.f + 15);
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.textColor = FMColorWithRGB0X(0xd7d7d7);
        _textLabel.font = FMFont(NO, 16.0f);
        _textLabel.hidden = YES;
        [self addSubview:_textLabel];

        [_indicatorView startAnimating];
    }

    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if (_touchAction && ![_indicatorView isAnimating]) {
        _textLabel.text = @"";
        _textLabel.hidden = YES;
        [_indicatorView startAnimating];
        _touchAction();
    }
}

- (void)showRefreshText:(void (^)(void))block {
    _touchAction = block;
    _textLabel.text = @"点击屏幕，重新加载";
    [_indicatorView stopAnimating];
    _textLabel.hidden = NO;
}

- (void)showMessageText:(NSString *)text {
    if (text || [text isNotBlank]) {
        _textLabel.text = text;
    }
    [_indicatorView stopAnimating];
    _textLabel.hidden = NO;
}

- (void)dealloc {
    FMLOG(@"FMPageLoadingView dealloc");
    [_indicatorView stopAnimating];
    _indicatorView = nil;
}

@end