//
// Created by yuanxiao on 13-6-14.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <QuartzCore/QuartzCore.h>
#import <MBMvc/TBMBSimpleInstanceCommand+TBMBProxy.h>
#import "FMVoiceButton.h"
#import "UIImage+Helper.h"
#import "FMVoiceService.h"
#import "FMVoicePlayer.h"
#import "FMUserTrack.h"


@implementation FMVoiceButton {

@private
    NSData *_voiceData;
    NSString *_voiceUrl;

    Boolean _isStart;

    UIView *_progressView;
    UIImageView *_voiceImageView;
    UIView *_progressViewBG;

    FMVoiceButtonType _buttonType;
}

@synthesize voiceData = _voiceData;
@synthesize voiceUrl = _voiceUrl;
@synthesize progress = _progress;

- (id)initWithFrame:(CGRect)frame withType:(FMVoiceButtonType)buttonType {
    _buttonType = buttonType;
    return [self initWithFrame:frame];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        UIImage *buttonImage;
        if (_buttonType == FMVoiceButtonTypeSmall) {
            buttonImage = [UIImage imageWithFileName:@"btn_voice_small.png"];
        } else {
            buttonImage = [UIImage imageWithFileName:@"btn_voice_big.png"];
        }
        [self setBackgroundImage:[buttonImage
                resizableImageWithCapInsets:UIEdgeInsetsMake(0, buttonImage.size.height / 2 - 0.5, 0, buttonImage.size.height / 2 - 0.5)]
                        forState:UIControlStateNormal];
        [self setImage:[UIImage imageWithFileName:@"voice_icon3.png"]
              forState:UIControlStateNormal];
        self.backgroundColor = [UIColor clearColor];
        [self addTarget:self
                 action:@selector(clickButton:)
       forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    UIImage *buttonImage;
    if (_buttonType == FMVoiceButtonTypeSmall) {
        buttonImage = [UIImage imageWithFileName:@"btn_voice_small.png"];
    } else {
        buttonImage = [UIImage imageWithFileName:@"btn_voice_big.png"];
    }
    frame.size.height = buttonImage.size.height;
    super.frame = frame;
}

- (void)clickButton:(id)sender {
    if (!_progressViewBG) {
        [self initProgressView];
    }
    if (_isStart) {
        [[FMVoiceService proxyObject] stopPlayVoice];
        [self removeProgress];
        return;
    }

    [FMUserTrack ctrlClicked:@"FM_VOICE_PLAY"];

    _isStart = YES;
    __weak FMVoiceButton *weakSelf = self;
    [[FMVoiceService proxyObject]
            createVoicePlayer:self.voiceUrl
                 onCreateDone:^(FMVoicePlayer *player) {
                     player.progress = ^(NSTimeInterval currentTime, NSTimeInterval duration,
                             FMVoicePlayer *_player, NSString *url) {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [weakSelf refreshProgress:currentTime / duration
                                                finish:NO
                                                   url:url];
                         }
                         );
                     };

                     player.finish = ^(FMVoicePlayer *_player, NSString *url) {
                         [weakSelf refreshProgress:1
                                            finish:YES
                                               url:url];
                     };
                     [player play];
                 }

    ];
}

- (void)initProgressView {
    CGFloat shadow = 2;
    _progressViewBG = [[UIImageView alloc]
            initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - shadow)];
    _progressViewBG.backgroundColor = [UIColor clearColor];
    [self addSubview:_progressViewBG];

    _progressView = [[UIView alloc] init];
    _progressView.backgroundColor = FMColorWithRed(60, 161, 88);
    _progressView.userInteractionEnabled = NO;
    [_progressViewBG addSubview:_progressView];
    _progressViewBG.clipsToBounds = YES;
    _progressViewBG.layer.cornerRadius = _progressViewBG.frame.size.height / 2;

    UIImage *image1 = [UIImage imageWithFileName:@"voice_icon1.png"];
    UIImage *image2 = [UIImage imageWithFileName:@"voice_icon2.png"];
    UIImage *image3 = [UIImage imageWithFileName:@"voice_icon3.png"];
    _voiceImageView = [[UIImageView alloc]
                                    initWithFrame:CGRectMake(
                                            (self.frame.size.width - image3.size.width) / 2,
                                            (self.frame.size.height - image3.size.height) / 2,
                                            image3.size.width,
                                            image3.size.height
                                    )];
    _voiceImageView.animationImages = @[image1, image2, image3];
    _voiceImageView.animationDuration = 0.6;
    [_voiceImageView startAnimating];
    [_progressViewBG addSubview:_voiceImageView];
}

- (void)refreshProgress:(double)per finish:(BOOL)finish url:(NSString *)url{
    if ([_voiceUrl isEqualToString:url]) {
        _progressViewBG.hidden = NO;
        if (![_voiceImageView isAnimating]) {
            [_voiceImageView startAnimating];
        }

        CGRect rect = CGRectMake(0, 0, _progressViewBG.frame.size.width, _progressViewBG.frame.size.height);
        rect.size.width *= per;
        _progressView.frame = rect;

        if (finish) {
            [self removeProgress];
        }
    } else {
        _progressViewBG.hidden = YES;
        [_voiceImageView stopAnimating];
    }
}

- (void)removeProgress {
    [_voiceImageView stopAnimating];
    [_voiceImageView removeFromSuperview];
    _voiceImageView = nil;

    _isStart = NO;
    [_progressViewBG removeFromSuperview];
    _progressViewBG = nil;
    _progressView = nil;
}

- (void)dealloc {
    if (_isStart)
        [[FMVoiceService proxyObject] stopPlayVoice];
}

@end

