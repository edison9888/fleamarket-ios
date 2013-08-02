//
// Created by yuanxiao on 13-7-4.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <MBMvc/TBMBBind.h>
#import "FMMessageTapView.h"
#import "FMBaseScrollView.h"

#define kMessageTapWidth  (FM_SCREEN_WIDTH - 2) / 3

@implementation FMMessageTapItemView {
@private
    UILabel *_titleLabel;
    UILabel *_countLabel;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(
                0,
                12,
                self.frame.size.width,
                (self.frame.size.height - 12 * 2)/2)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = FMFont(YES, 14);
        [self addSubview:_titleLabel];

        _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(
                0,
                12 + _titleLabel.frame.size.height + 3,
                self.frame.size.width,
                (self.frame.size.height - 12 * 2)/2)];
        _countLabel.backgroundColor = [UIColor clearColor];
        _countLabel.textAlignment = NSTextAlignmentCenter;
        _countLabel.font = FMFont(NO, 14);
        [self addSubview:_countLabel];
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _titleLabel.text = title;
}

- (void)setCount:(NSInteger)count {
    _countLabel.text = [NSString stringWithFormat:@"%d", count];
}

- (void)setSelect:(BOOL)select {
    if (select) {
        _titleLabel.textColor = FMColorWithRGB0X(0xf2614c);
        _countLabel.textColor = FMColorWithRGB0X(0xf2614c);
        [self setBackgroundImage:[UIImage imageWithFileName:@"btn_message_selected.png"]
                        forState:UIControlStateNormal];
    } else {
        _titleLabel.textColor = [UIColor blackColor];
        _countLabel.textColor = FMColorWithRed(135, 135, 135);
        [self setBackgroundImage:[UIImage imageWithFileName:@"btn_message.png"]
                        forState:UIControlStateNormal];
    }
}

@end

@implementation FMMessageTapView {
@private
    FMMessageViewInfo *_messageInfo;
    __weak FMMessageTapItemView *_systemMessage;
    __weak FMMessageTapItemView *_receiveMessage;
    __weak FMMessageTapItemView *_sendMessage;

    void(^_messageViewTypeBlock)(FMMessageViewType messageViewType);
}

@synthesize messageInfo = _messageInfo;

- (id)init {
    self = [super initWithFrame:CGRectMake(0, kNavigationBarHeight, FM_SCREEN_WIDTH, kMessageTapHeight)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self initView];

        UIImageView *line2 = [[UIImageView alloc] initWithFrame:
                CGRectMake(kMessageTapWidth * 2 + 1, 0, 1, self.frame.size.height)];
        line2.image = [UIImage imageWithFileName:@"line_message.png"];
        [self addSubview:line2];

        UIImageView *line1 = [[UIImageView alloc] initWithFrame:
                CGRectMake(kMessageTapWidth, 0, 1, self.frame.size.height)];
        line1.image = [UIImage imageWithFileName:@"line_message.png"];
        [self addSubview:line1];

        UIView *point1 = [[UIView alloc] initWithFrame:
                CGRectMake(kMessageTapWidth * 2 + 1, self.frame.size.height - 1, 1, 1)];
        point1.backgroundColor = FMColorWithRed(214, 210, 194);
        [self addSubview:point1];

        UIView *point2 = [[UIView alloc] initWithFrame:
                CGRectMake(kMessageTapWidth, self.frame.size.height - 1, 1, 1)];
        point2.backgroundColor = FMColorWithRed(214, 210, 194);
        [self addSubview:point2];
    }

    return self;
}

- (void)initView {
    CGRect rect = CGRectMake(0, 0, kMessageTapWidth, self.frame.size.height);
    FMMessageTapItemView *systemMessage = [[FMMessageTapItemView alloc] initWithFrame:rect];
    [systemMessage setTitle:@"系统消息"];
    TBMBBindObjectWeak(tbKeyPath(self, messageInfo.systemCount), systemMessage, ^(FMMessageTapItemView *host, id old, id new) {
        [host setCount:[new intValue]];
    }
    );
    [systemMessage addTarget:self action:@selector(touchButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:systemMessage];
    _systemMessage = systemMessage;

    rect = CGRectMake(kMessageTapWidth + 1, 0, kMessageTapWidth, self.frame.size.height);
    FMMessageTapItemView *receiveMessage = [[FMMessageTapItemView alloc] initWithFrame:rect];
    [receiveMessage setTitle:@"收到的留言"];
    TBMBBindObjectWeak(tbKeyPath(self, messageInfo.receiveCount), receiveMessage, ^(FMMessageTapItemView *host, id old, id new) {
        [host setCount:[new intValue]];
    }
    );
    [receiveMessage addTarget:self action:@selector(touchButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:receiveMessage];
    _receiveMessage = receiveMessage;

    rect = CGRectMake(kMessageTapWidth * 2 + 2, 0, kMessageTapWidth, self.frame.size.height);
    FMMessageTapItemView *sendMessage = [[FMMessageTapItemView alloc] initWithFrame:rect];
    [sendMessage setTitle:@"我的回复"];
    TBMBBindObjectWeak(tbKeyPath(self, messageInfo.sendCount), sendMessage, ^(FMMessageTapItemView *host, id old, id new) {
        [host setCount:[new intValue]];
    }
    );
    [sendMessage addTarget:self action:@selector(touchButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:sendMessage];
    _sendMessage = sendMessage;
}

- (void)touchButton:(FMMessageTapItemView *)button {
    [button setSelect:YES];
    if (button == _systemMessage) {
        [_sendMessage setSelect:NO];
        [_receiveMessage setSelect:NO];

        [self messageBlock:FMMessageViewTypeSystem];
    } else if (button == _receiveMessage) {
        [_sendMessage setSelect:NO];
        [_systemMessage setSelect:NO];

        [self messageBlock:FMMessageViewTypeReceive];
    } else if (button == _sendMessage) {
        [_systemMessage setSelect:NO];
        [_receiveMessage setSelect:NO];

        [self messageBlock:FMMessageViewTypeSend];
    }
}

- (void)messageBlock:(FMMessageViewType)messageType {
    if (_messageViewTypeBlock) {
        _messageViewTypeBlock(messageType);
    }
}

- (void)setTouchMessageTapItem:(void(^)(FMMessageViewType messageViewType))block {
    _messageViewTypeBlock = block;
}

- (void)selectMessageTap:(FMMessageViewType)messageViewType {
    if (messageViewType == FMMessageViewTypeSystem) {
        [self touchButton:_systemMessage];
    } else if (messageViewType == FMMessageViewTypeReceive) {
        [self touchButton:_receiveMessage];
    } else if (messageViewType == FMMessageViewTypeSend) {
        [self touchButton:_sendMessage];
    }
}

@end