// 
// Created by henson on 6/21/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <MBMvc/TBMBGlobalFacade.h>
#import "FMPostToolbarView.h"
#import "UIImage+Helper.h"

@implementation FMPostToolbarView {

}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        self.image = [self _getBottomBgImage];

        CGRect closeRect = {{0, 3}, {44,44}};
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton setImage:[UIImage imageNamed:@"close_icon.png"] forState:UIControlStateNormal];
        closeButton.frame = closeRect;
        [closeButton addTarget:self
                        action:@selector(closeAction)
              forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];

        CGRect postRect = {{FM_SCREEN_WIDTH - [self _getPostButtonBgImage].size.width,3}, [self _getPostButtonBgImage].size};
        UIButton *postButton = [UIButton buttonWithType:UIButtonTypeCustom];
        postButton.frame = postRect;
        [postButton setBackgroundImage:[self _getPostButtonBgImage] forState:UIControlStateNormal];
        [postButton setTitle:@"立即发布" forState:UIControlStateNormal];
        postButton.titleLabel.font = FMFont(YES, 15);
        [postButton addTarget:self
                       action:@selector(postAction)
             forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:postButton];
    }

    return self;
}

- (void)postAction {
    TBMBGlobalSendNotificationForSEL(@selector($$postToolbarPostNotification:));
}

- (void)closeAction {
    TBMBGlobalSendNotificationForSEL(@selector($$postToolbarCloseNotification:));
}

- (UIImage *)_getBottomBgImage {
    return [UIImage imageWithFileName:@"item_detail_bottom_bar.png"];
}

- (UIImage *)_getPostButtonBgImage {
    return [UIImage imageNamed:@"item_detail_buy_bg.png"];
}

@end