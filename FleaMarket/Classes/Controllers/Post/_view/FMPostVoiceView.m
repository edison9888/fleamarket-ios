// 
// Created by henson on 6/25/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <MBMvc/TBMBGlobalFacade.h>
#import <MBMvc/TBMBUtil.h>
#import <MBMvc/TBMBBind.h>
#import "FMPostVoiceView.h"
#import "FMButton.h"
#import "FMVoiceButton.h"
#import "FMItemDO.h"
#import "NSString+Helper.h"

@implementation FMPostVoiceView {
    FMButton *_recordButton;
    FMVoiceButton *_voiceButton;
    UIButton *_deleteButton;
    UIImageView *_buttonBgView;
@private
    kPostVoiceStatus _status;
    FMItemDO *_itemDO;
}

@synthesize status = _status;
@synthesize itemDO = _itemDO;

- (id)initWithFrame:(CGRect)frame itemDO:(FMItemDO *)itemDO {
    self = [super initWithFrame:frame];
    if (self) {
        _itemDO = itemDO;
        __weak FMPostVoiceView *selfWeak = self;

        UIImage *voiceBgImage = [self voiceButtonBgImage];
        CGRect recordRect = {{(frame.size.width - voiceBgImage.size.width)/2.f, 0}, voiceBgImage.size};
        FMButton *recordButton = [FMButton buttonWithType:UIButtonTypeCustom];
        recordButton.frame = recordRect;
        [recordButton setBackgroundImage:voiceBgImage
                                forState:UIControlStateNormal];
        [recordButton setBackgroundImage:[self voiceButtonBgHighlightImage]
                                forState:UIControlStateHighlighted];
        [recordButton addTarget:self
                         action:@selector(touchUp)
               forControlEvents:UIControlEventTouchUpInside];
        [recordButton addTarget:self
                         action:@selector(touchDown)
               forControlEvents:UIControlEventTouchDown];
        [recordButton addTarget:self
                         action:@selector(touchDragExit)
               forControlEvents:UIControlEventTouchDragExit];
        [recordButton addTarget:self
                         action:@selector(touchDragEnter)
               forControlEvents:UIControlEventTouchDragEnter];
        [recordButton setTouchEndAction:^(NSSet *set, UIEvent *event) {
            [selfWeak touchEnd];
        }];
        [self addSubview:recordButton];
        _recordButton = recordButton;

        CGRect textRect = {{0, recordRect.origin.y + recordRect.size.height + 10}, {frame.size.width, 20}};
        UILabel *textLabel = [[UILabel alloc] initWithFrame:textRect];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.textColor = FMColorWithRed(178, 177, 179);
        textLabel.font = FMFont(NO, 15.f);
        textLabel.text = @"我的宝贝有话说";
        [self addSubview:textLabel];

        UIImage *bgImage = [[UIImage imageNamed:@"post_voice_view_bg.png"]
                resizableImageWithCapInsets:UIEdgeInsetsMake(0, 25, 0, 25)];
        CGRect voiceButtonBgRect = {{(frame.size.width - 130) / 2.f, 6}, {130, 55}};
        UIImageView *buttonBgView = [[UIImageView alloc] initWithImage:bgImage];
        buttonBgView.frame = voiceButtonBgRect;
        buttonBgView.hidden = YES;
        [self addSubview:buttonBgView];
        _buttonBgView = buttonBgView;

        CGRect voiceRect = {{(frame.size.width - 122) / 2.f, 10}, {122, 49}};
        FMVoiceButton *voiceButton = [[FMVoiceButton alloc] initWithFrame:voiceRect
                                                                 withType:FMVoiceButtonTypeBig];
        voiceButton.backgroundColor = [UIColor clearColor];
        voiceButton.hidden = YES;
        [self addSubview:voiceButton];
        _voiceButton = voiceButton;

        CGRect deleteRect = {{voiceRect.origin.x + voiceRect.size.width - 15, voiceRect.origin.y}, {40, 47.5}};
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteButton setImage:[UIImage imageNamed:@"post_voice_delete_icon.png"]
                      forState:UIControlStateNormal];
        deleteButton.frame = deleteRect;
        [deleteButton addTarget:self
                         action:@selector(deleteVoice)
               forControlEvents:UIControlEventTouchUpInside];
        deleteButton.hidden = YES;
        [self addSubview:deleteButton];
        _deleteButton = deleteButton;

        [self setStatus:kPostVoiceStatusNormal];
        TBMBAutoBindingKeyPath(self);
    }

    return self;
}

TBMBWhenThisKeyPathChange(itemDO, voiceUrl) {
    if (!_itemDO.voiceUrl || [_itemDO.voiceUrl isBlank]) {
        [self setStatus:kPostVoiceStatusNormal];
        return;
    }
    [self setStatus:kPostVoiceStatusDone];
    [_voiceButton setVoiceUrl:_itemDO.voiceUrl];
}

- (void)setStatus:(kPostVoiceStatus)status {
    _status = status;

    if (status == kPostVoiceStatusDone) {
        _voiceButton.hidden = NO;
        _buttonBgView.hidden = NO;
        _recordButton.hidden = YES;
        _deleteButton.hidden = NO;
        return;
    }
    _voiceButton.hidden = YES;
    _buttonBgView.hidden = YES;
    _recordButton.hidden = NO;
    _deleteButton.hidden = YES;
    return;
}

- (void)touchUp {
    TBMBGlobalSendNotificationForSEL(@selector($$postVoiceTouchUpNotification:));
}

- (void)touchDown {
    TBMBGlobalSendNotificationForSEL(@selector($$postVoiceTouchDownNotification:));
}

- (void)touchDragExit {
    TBMBGlobalSendNotificationForSEL(@selector($$postVoiceTouchDragExitNotification:));
}

- (void)touchDragEnter {
    TBMBGlobalSendNotificationForSEL(@selector($$postVoiceTouchDragEnterNotification:));
}

- (void)touchEnd {
    TBMBGlobalSendNotificationForSEL(@selector($$postVoiceTouchEndNotification:));
}

- (void)deleteVoice {
    TBMBGlobalSendNotificationForSEL(@selector($$postDeleteVoiceNotification:));
}

- (UIImage *)voiceButtonBgImage {
    return [UIImage imageNamed:@"post_voice_btn_bg.png"];
}

- (UIImage *)voiceButtonBgHighlightImage {
    return [UIImage imageNamed:@"post_voice_btn_bg_highlight.png"];
}

@end