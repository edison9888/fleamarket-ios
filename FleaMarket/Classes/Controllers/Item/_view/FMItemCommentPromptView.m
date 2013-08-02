// 
// Created by henson on 7/28/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <RTLabel/RTLabel.h>
#import "FMItemCommentPromptView.h"
#import "UIImage+Helper.h"

@implementation FMItemCommentPromptView {
    UILabel *_textLabel;
    UIButton *_closeButton;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];

        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 25)];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.textColor = FMColorWithRed(103, 103, 103);
        textLabel.font = FMFont(NO, 12);
        [self addSubview:textLabel];
        _textLabel = textLabel;

        UIImage *closeImage = [UIImage imageWithFileName:@"item_comment_prompt_close.png"];
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton setImage:closeImage forState:UIControlStateNormal];
        closeButton.frame = CGRectMake(frame.size.width - 3*14, 0, 14 * 3, frame.size.height);
        [closeButton addTarget:self
                        action:@selector(closeAction)
              forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        _closeButton = closeButton;
    }

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _closeButton.frame = CGRectMake(self.frame.size.width - 3*14, 0, 14 * 3, self.frame.size.height);
}

- (void)setText:(NSString *)text {
    _textLabel.text = text;
}

- (CGSize)textSize:(NSString *)text {
    RTLabel *textLabel = [[RTLabel alloc] initWithFrame:CGRectZero];
    textLabel.text = text;
    return [textLabel optimumSize];
}

- (void)closeAction {
    self.hidden = YES;
    self.frame = CGRectMake(0, FM_SCREEN_HEIGHT, FM_SCREEN_WIDTH, 34);
}

@end