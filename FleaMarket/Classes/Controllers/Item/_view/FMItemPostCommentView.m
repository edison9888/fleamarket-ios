// 
// Created by henson on 6/19/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <BlocksKit/UIControl+BlocksKit.h>
#import <BlocksKit/UIView+BlocksKit.h>
#import "FMItemPostCommentView.h"
#import "UIImage+Helper.h"
#import "HPTextViewInternal.h"
#import "FMButton.h"

@implementation FMItemPostCommentView {
    UIButton *_backButton;
    HPGrowingTextView *_commentTextField;
    UIButton *_keyboardButton;
    UIButton *_voiceButton;
    FMButton *_recordVoiceButton;
    UIImageView *_entryImageView;

    CGRect _rect;

    void (^_touchDownBlock)(void);

    void (^_touchUpBlock)(void);

    void (^_touchDragExitBlock)(void);

    //touchEnd
    void (^_touchEndBlock)(void);

    //touchDragEnter
    void (^_touchDragEnterBlock)(void);
}

@synthesize backButton = _backButton;
@synthesize commentTextField = _commentTextField;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.image = [self _getBottomBgImage];
        self.userInteractionEnabled = YES;

        __weak FMItemPostCommentView *weakSelf = self;
        CGRect backRect = {{0, 3}, {44, 44}};
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setImage:[UIImage imageNamed:@"voice_back_icon.png"] forState:UIControlStateNormal];
        backButton.frame = backRect;
        [self addSubview:backButton];
        _backButton = backButton;

        CGRect commentRect = {{backRect.origin.x + backRect.size.width, 7}, {230, 34}};
        HPGrowingTextView *commentTextField = [[HPGrowingTextView alloc] initWithFrame:commentRect];
        commentTextField.internalTextView.placeholder = @"输入文字信息";
        commentTextField.maxNumberOfLines = 5;
        commentTextField.minNumberOfLines = 1;
        commentTextField.font = FMFont(NO, 14);
        commentTextField.returnKeyType = UIReturnKeySend;
        commentTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        commentTextField.contentInset = UIEdgeInsetsMake(0, 7, 0, 3);
        commentTextField.backgroundColor = [UIColor whiteColor];
        [self addSubview:commentTextField];
        _commentTextField = commentTextField;

        CGRect entryBgRect = {{backRect.origin.x + backRect.size.width, 3}, {232, 44}};
        UIImage *rawEntryBackground = [[UIImage imageNamed:@"item_comment_textview_bg.png"]
                resizeImageWithCapInsets:UIEdgeInsetsMake(23, 20, 21, 20)];
        UIImageView *entryImageView = [[UIImageView alloc] initWithImage:rawEntryBackground];
        entryImageView.frame = entryBgRect;
        entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:entryImageView];
        _entryImageView = entryImageView;

        CGRect voiceRect = {{entryBgRect.origin.x + entryBgRect.size.width, 3}, {44, 44}};
        UIButton *voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [voiceButton setImage:[UIImage imageNamed:@"record_voice_icon.png"] forState:UIControlStateNormal];
        voiceButton.frame = voiceRect;
        [voiceButton addEventHandler:^(id sender) {
            [weakSelf switchVoice];
        }           forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:voiceButton];
        _voiceButton = voiceButton;

        CGRect keyboardRect = {{entryBgRect.origin.x + entryBgRect.size.width, 3}, {44, 44}};
        UIButton *keyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [keyboardButton setImage:[UIImage imageNamed:@"keyboard_icon.png"] forState:UIControlStateNormal];
        keyboardButton.frame = keyboardRect;
        keyboardButton.hidden = YES;
        [keyboardButton addEventHandler:^(id sender) {
            [weakSelf switchKeyboard];
        }              forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:keyboardButton];
        _keyboardButton = keyboardButton;

        CGRect recordRect = {{entryBgRect.origin.x, 6}, {232, 34}};
        FMButton *recordVoiceButton = [FMButton buttonWithType:UIButtonTypeCustom];
        [recordVoiceButton setBackgroundImage:[[UIImage imageNamed:@"record_voice_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(16, 18, 16, 18)]
                                     forState:UIControlStateNormal];
        [recordVoiceButton setBackgroundImage:[[UIImage imageNamed:@"record_voice_bg_highlight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(16, 18, 16, 18)]
                                     forState:UIControlStateHighlighted];
        [recordVoiceButton setTitle:@"长按留言" forState:UIControlStateNormal];
        [recordVoiceButton setTitle:@"松开结束" forState:UIControlStateHighlighted];
        recordVoiceButton.titleLabel.font = FMFont(NO, 14.f);
        recordVoiceButton.frame = recordRect;
        recordVoiceButton.hidden = YES;

        [recordVoiceButton addTarget:self
                              action:@selector(touchDragExit)
                    forControlEvents:UIControlEventTouchDragExit];
        [recordVoiceButton addTarget:self
                              action:@selector(touchDragEnter)
                    forControlEvents:UIControlEventTouchDragEnter];
        [recordVoiceButton addTarget:self
                              action:@selector(touchDown)
                    forControlEvents:UIControlEventTouchDown];
        [recordVoiceButton addTarget:self
                              action:@selector(touchUp)
                    forControlEvents:UIControlEventTouchUpInside];

        [recordVoiceButton setTouchEndAction:^(NSSet *set, UIEvent *event) {
            [weakSelf touchEnd];
        }];
        [self addSubview:recordVoiceButton];
        _recordVoiceButton = recordVoiceButton;
    }

    return self;
}

- (void)touchEnd {
    FMLog(@"touchEnd");
    if (_touchEndBlock) {
        _touchEndBlock();
    }
}

- (void)touchDragEnter {
    FMLog(@"touchDragEnter");
    if (_touchDragEnterBlock) {
        _touchDragEnterBlock();
    }
}

- (void)touchDragExit {
    FMLog(@"touchDragExit");
    if (_touchDragExitBlock) {
        _touchDragExitBlock();
    }
}

- (void)touchDown {
    FMLog(@"touchDown");
    if (_touchDownBlock) {
        _touchDownBlock();
    }
}

- (void)touchUp {
    FMLog(@"touchUp");
    if (_touchUpBlock) {
        _touchUpBlock();
    }
}

- (void)setTouchEndAction:(void (^)(void))block {
    _touchEndBlock = block;
}

- (void)setTouchDragEnterAction:(void (^)(void))block {
    _touchDragEnterBlock = block;
}

- (void)setTouchDragExitAction:(void (^)(void))block {
    _touchDragExitBlock = block;
}

- (void)setTouchDownAction:(void (^)(void))block {
    _touchDownBlock = block;
}

- (void)setTouchUpAction:(void (^)(void))block {
    _touchUpBlock = block;
}

- (void)setDelegate:(id)delegate {
    _delegate = delegate;
    _commentTextField.delegate = delegate;
}

- (void)switchVoice {
    _commentTextField.hidden = YES;
    _recordVoiceButton.hidden = NO;
    _entryImageView.hidden = YES;
    [_commentTextField resignFirstResponder];
    _keyboardButton.hidden = NO;
    _voiceButton.hidden = YES;

    CGRect selfRect = self.frame;
    _rect = self.frame;
    selfRect.origin.y = FM_SCREEN_HEIGHT - kStatusBarHeight - kTabBarHeight;
    selfRect.size.height = 44;
    self.frame = selfRect;
}

- (void)switchKeyboard {
    self.frame = _rect;
    [self showTextView];
}

- (void)setTextViewPlaceholder:(NSString *)placeholder {
    _commentTextField.placeholder = placeholder;
    [_commentTextField.internalTextView setNeedsDisplay];
}

- (void)showTextView {
    _commentTextField.hidden = NO;
    _recordVoiceButton.hidden = YES;
    _entryImageView.hidden = NO;

    [_commentTextField becomeFirstResponder];
    _keyboardButton.hidden = YES;
    _voiceButton.hidden = NO;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (UIImage *)_getBottomBgImage {
    return [[UIImage imageNamed:@"item_detail_bottom_bar.png"] resizeImageWithCapInsets:UIEdgeInsetsMake(20, 0, 20, 0)];
}

- (void)dealloc {
    _commentTextField.delegate = nil;
}

@end