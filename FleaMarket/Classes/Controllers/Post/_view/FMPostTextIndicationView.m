// 
// Created by henson on 6/25/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import "FMPostTextIndicationView.h"

@implementation FMPostTextIndicationView {
    UILabel *_textLabel;
    UIImageView *_arrowImageView;
    FMPostIndicationType _type;
}

- (id)init {
    self = [super init];
    if (self) {
        _type = FMPostIndicationTypeUp;
    }

    return self;
}

- (id)initWithFrame:(CGRect)frame type:(FMPostIndicationType)type {
    self = [super initWithFrame:frame];
    if (self) {
        _type = type;

        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.font = FMFont(NO, 13.f);
        textLabel.textColor = FMColorWithRed(178, 177, 179);
        textLabel.textAlignment = NSTextAlignmentCenter;
        if (_type == FMPostIndicationTypeUp) {
            textLabel.text = @"向上滑动查看选填项信息";
        } else {
            textLabel.text = @"向下滑动查看必填项信息";
        }
        [self addSubview:textLabel];
        _textLabel = textLabel;

        UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[self arrowImage]];
        arrowImageView.backgroundColor = [UIColor clearColor];
        arrowImageView.center = CGPointMake(frame.size.width / 2.f, (frame.size.height + 20) / 2.f);
        [self addSubview:arrowImageView];
        _arrowImageView = arrowImageView;
    }

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (_type == FMPostIndicationTypeUp) {
        CGRect textRect = {self.bounds.origin, {self.frame.size.width, 20}};
        _textLabel.frame = textRect;
        _arrowImageView.center = CGPointMake(self.frame.size.width / 2.f, (self.frame.size.height + 20) / 2.f);
        return;
    }

    CGRect textRect = {{0, 20}, {self.frame.size.width, 20}};
    _textLabel.frame = textRect;
    _arrowImageView.center = CGPointMake(self.frame.size.width / 2.f, (self.frame.size.height - 20) / 2.f);
    return;
}

- (void)setState:(FMPostIndicationState)state {
    if (_type == FMPostIndicationTypeUp) {
        if (state == FMPostIndicationStateNormal) {
            _textLabel.text = @"向上滑动查看选填项信息";
            _arrowImageView.image = [UIImage imageNamed:@"post_arrow_up_icon.png"];
        } else if (state == FMPostIndicationStateDone) {
            _textLabel.text = @"松开即可查看选填项信息";
            _arrowImageView.image = [UIImage imageNamed:@"post_arrow_down_icon.png"];
        }
        return;
    }

    if (state == FMPostIndicationStateNormal) {
        _textLabel.text = @"向下滑动查看必填项信息";
        _arrowImageView.image = [UIImage imageNamed:@"post_arrow_down_icon.png"];
    } else if (state == FMPostIndicationStateDone) {
        _textLabel.text = @"松开即可查看必填项信息";
        _arrowImageView.image = [UIImage imageNamed:@"post_arrow_up_icon.png"];
    }
}

- (UIImage *)arrowImage {
    if (_type == FMPostIndicationTypeUp) {
        return [UIImage imageNamed:@"post_arrow_up_icon.png"];
    }
    return [UIImage imageNamed:@"post_arrow_down_icon.png"];
}

@end