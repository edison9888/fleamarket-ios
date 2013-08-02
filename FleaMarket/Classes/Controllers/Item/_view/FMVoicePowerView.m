// 
// Created by henson on 7/16/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <QuartzCore/QuartzCore.h>
#import "FMVoicePowerView.h"

@implementation FMVoicePowerView {
    UIImageView *_powerImageView;
    UIImageView *_cancelImageView;
    UILabel *_textLabel;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        UIImage *powerImage = [UIImage imageNamed:@"voice_power_0.png"];
        UIImageView *powerImageView = [[UIImageView alloc] initWithImage:powerImage];
        powerImageView.center = CGPointMake(frame.size.width / 2.f, frame.size.height / 2.f - 10);
        [self addSubview:powerImageView];
        _powerImageView = powerImageView;

        UIImage *cancelImage = [UIImage imageNamed:@"voice_cancal_icon.png"];
        UIImageView *cancelImageView = [[UIImageView alloc] initWithImage:cancelImage];
        cancelImageView.hidden = YES;
        cancelImageView.center = CGPointMake(frame.size.width / 2.f, frame.size.height / 2.f - 10);
        [self addSubview:cancelImageView];
        _cancelImageView = cancelImageView;

        CGRect textRect = {{0, frame.size.height - 25}, {frame.size.width, 25}};
        UILabel *textLabel = [[UILabel alloc] initWithFrame:textRect];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.text = @"手指上滑，取消发送";
        textLabel.textColor = [UIColor whiteColor];
        textLabel.font = FMFont(NO, 14);
        textLabel.layer.cornerRadius = 5;
        [self addSubview:textLabel];
        _textLabel = textLabel;
    }

    return self;
}

- (void)setPowerStatus:(kVoicePowerStatus)powerStatus {
    _powerStatus = powerStatus;

    if (powerStatus == kVoicePowerStatusCancel) {
        _cancelImageView.hidden = NO;
        _powerImageView.hidden = YES;
        _textLabel.text = @"松开手指，取消发送";
        _textLabel.backgroundColor = FMColorWithRedAlpha(255.f, 0, 0, 0.7);
        return;
    }

    _cancelImageView.hidden = YES;
    _powerImageView.hidden = NO;
    _textLabel.text = @"手指上滑，取消发送";
    _textLabel.backgroundColor = [UIColor clearColor];
    return;
}

- (void)setPower:(float)averagePower peakPower:(float)peakPower {
    if (_powerImageView.hidden) {
        return;
    }

    NSInteger i = (NSInteger) (averagePower / -4);
    if (i > 9) {
        i = 9;
    }
    NSString *imageName = [NSString stringWithFormat:@"voice_power_%d.png", (9-i)];
    [_powerImageView setImage:[UIImage imageNamed:imageName]];
}

@end