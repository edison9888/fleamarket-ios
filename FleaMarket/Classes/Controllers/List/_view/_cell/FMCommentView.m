//
// Created by yuanxiao on 13-6-28.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "FMCommentView.h"
#import "FMItemCommentDO.h"


#import <SDWebImage/UIImageView+WebCache.h>
#import "RTLabel.h"
#import "FMAvatarImageView.h"
#import "FMCommon.h"
#import "NSString+Helper.h"
#import "FMVoiceButton.h"
#import "FMItemDO.h"
#import "UIImage+Helper.h"

@implementation FMCommentView {
    __weak UIView *_bgView;
    __weak FMAvatarImageView *_avatarImageView;
    __weak UIButton *_postTimeView;
    __weak FMVoiceButton *_voiceButton;
    __weak RTLabel *_commentLabel;
    __weak UILabel *_voiceReplyLabel;
}

- (id)init {
    if (self = [super init]) {
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 80)];
        bgView.backgroundColor = FMColorWithRed(240, 240, 240);
        [self addSubview:bgView];
        _bgView = bgView;

        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 1)];
        lineView.backgroundColor = FMColorWithRed(236, 233, 227);
        [self addSubview:lineView];

        CGRect avatarImageRect = {{25, 10}, {30, 30}};
        FMAvatarImageView *avatarImageView = [[FMAvatarImageView alloc] initWithFrame:avatarImageRect];
        avatarImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:avatarImageView];
        _avatarImageView = avatarImageView;

        CGRect commentRect = {{25 + 30 + 10, 10}, {220, 30}};
        RTLabel *commentLabel = [[RTLabel alloc] initWithFrame:commentRect];
        commentLabel.backgroundColor = [UIColor clearColor];
        commentLabel.font = FMFont(NO, 14);
        commentLabel.textColor = FMColorWithRed(61, 62, 60);
        commentLabel.lineBreakMode = RTTextLineBreakModeWordWrapping;
        [self addSubview:commentLabel];
        _commentLabel = commentLabel;

        FMVoiceButton *voiceButton = [[FMVoiceButton alloc] initWithFrame:CGRectZero];
        voiceButton.backgroundColor = [UIColor clearColor];
        voiceButton.hidden = YES;
        [self addSubview:voiceButton];
        _voiceButton = voiceButton;

        UILabel *voiceReplyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        voiceReplyLabel.backgroundColor = [UIColor clearColor];
        voiceReplyLabel.textColor = FMColorWithRed(176, 176, 173);
        voiceReplyLabel.font = FMFont(NO, 10);
        voiceReplyLabel.hidden = YES;
        [self addSubview:voiceReplyLabel];
        _voiceReplyLabel = voiceReplyLabel;

        UIButton *postTimeView = [UIButton buttonWithType:UIButtonTypeCustom];
        [postTimeView setImage:[self _postTimeImage] forState:UIControlStateNormal];
        [postTimeView setImage:[self _postTimeImage] forState:UIControlStateHighlighted];
        [postTimeView setTitleColor:FMColorWithRed(176, 176, 173) forState:UIControlStateNormal];
        postTimeView.titleLabel.font = FMFont(NO, 10);
        postTimeView.titleLabel.textAlignment = NSTextAlignmentRight;
        postTimeView.frame = CGRectZero;
        [postTimeView setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
        [postTimeView setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 2)];
        [self addSubview:postTimeView];
        _postTimeView = postTimeView;
    }
    return self;
}

- (void)setAvatarItemDO:(FMItemCommentDO *)commentDO {
    FMItemDO *itemDO = [[FMItemDO alloc] init];
    itemDO.userId = [NSString stringWithFormat:@"%lld",  commentDO.reporterId];
    itemDO.userNick = commentDO.reporterNick;
    itemDO.id = [NSString stringWithFormat:@"%lld", commentDO.itemId];
    _avatarImageView.itemDO = itemDO;
}

- (void)setCommentDO:(FMItemCommentDO *)commentDO serverTime:(NSString *)serverTime {
    _bgView.frame = CGRectMake(0, 0, 300, [FMCommentView cellHeight:commentDO]);

    [self setAvatarItemDO:commentDO];

    NSString *commentContent = [FMCommentView replaceCommentContent:commentDO.contentWithEmoji];
    if (commentDO.voiceUrl && [commentDO.voiceUrl isNotBlank]) {
        _voiceButton.hidden = NO;
        [_voiceButton setVoiceUrl:commentDO.voiceUrl];
        _commentLabel.text = [NSString stringWithFormat:[FMCommentView replyUsername:commentDO.content],
                        commentDO.reporterNick, @""];
    } else {
        _voiceButton.hidden = YES;
        _commentLabel.text = [NSString stringWithFormat:[FMCommentView replyUsername:commentDO.content],
                        commentDO.reporterNick, commentContent];
    }
    _commentLabel.frame = CGRectMake(25 + 30 + 10, 10, 220, [self commentTextSize].height);
    _voiceButton.frame = CGRectMake(_commentLabel.frame.origin.x + [self commentTextSize].width + 5, 6, 68, 36);

    if ([FMCommentView hasReply:commentDO.contentWithEmoji]) {
        _voiceReplyLabel.hidden = NO;
        if (![commentDO voiceIsEmpty]) {
            _voiceReplyLabel.text = [FMCommentView replaceVoiceCommentContent:commentDO.contentWithEmoji];
            _voiceReplyLabel.frame = CGRectMake(_commentLabel.frame.origin.x, _commentLabel.frame.origin.y + [self commentTextSize].height + 12, 180, 15);
        } else {
            _voiceReplyLabel.text = [FMCommentView pickUpCommentReplyContent:commentDO.contentWithEmoji];
            _voiceReplyLabel.frame = CGRectMake(_commentLabel.frame.origin.x, _commentLabel.frame.origin.y + [self commentTextSize].height + 4, 180, 15);
        }
    } else {
        _voiceReplyLabel.hidden = YES;
    }

    [_postTimeView setTitle:[FMCommon relativeTime:commentDO.reportTime serverTime:serverTime]
                   forState:UIControlStateNormal];
    _postTimeView.frame = CGRectMake(300 - ([self postTimeTextSize].width + 14) - 15, 10 + _commentLabel.frame.size.height + 5,
            [self postTimeTextSize].width + 9 + 5, 20);
    CGRect rect = self.frame;
    rect.size.height = _bgView.frame.size.height;
    self.frame = rect;
}

- (CGSize)commentTextSize {
    return [_commentLabel optimumSize];
}

+ (NSString *)replyUsername:(NSString *)content {
    return @"<b>%@: </b>%@";
}

+ (NSString *)pickUpCommentReplyContent:(NSString *)content {
    NSString *replyRegex = @"回复@(\\w+)\\((.+),(.+)\\):(.+)";
    NSError *error = [NSError new];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:replyRegex
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSString *replacedString = [regex stringByReplacingMatchesInString:content
                                                               options:0
                                                                 range:NSMakeRange(0, [content length])
                                                          withTemplate:@"回复 $1"];/*回复<b>$1</b>: */
    return replacedString;
}

+ (NSString *)replaceVoiceCommentContent:(NSString *)content {
    NSString *replyRegex = @"回复@(\\w+)\\((.+),(.+)\\):\\[语音\\]";
    NSError *error = [NSError new];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:replyRegex
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSString *replacedString = [regex stringByReplacingMatchesInString:content
                                                               options:0
                                                                 range:NSMakeRange(0, [content length])
                                                          withTemplate:@"回复 $1"];
    return replacedString;
}

+ (float)cellHeight:(FMItemCommentDO *)commentDO {
    if (commentDO.voiceUrl && [commentDO.voiceUrl isNotBlank]) {
        return 55;
    }
    RTLabel *label = [[RTLabel alloc] initWithFrame:CGRectMake(25 + 30 + 10, 10, 220, 30)];
    label.font = FMFont(NO, 14.f);
    label.lineBreakMode = RTTextLineBreakModeWordWrapping;
    NSString *content = [FMCommentView replaceCommentContent:commentDO.contentWithEmoji];
    NSString *username = [FMCommentView replyUsername:content];
    label.text = [NSString stringWithFormat:username, commentDO.reporterNick, content];
    return 10 + [label optimumSize].height + 5 + 20 + 5;
}

//TODO 开始处，只match一次
+ (NSString *)replaceCommentContent:(NSString *)content {
    NSString *replyRegex = @"回复@(\\w+)\\((.+),(.+)\\):";
    NSError *error = [NSError new];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:replyRegex
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error ];
    NSString *replacedString = [regex stringByReplacingMatchesInString:content
                                                               options:0
                                                                 range:NSMakeRange(0, [content length])
                                                          withTemplate:@""];
    return replacedString;
}

+ (BOOL)hasReply:(NSString *)content {
    NSString *replyRegex = @"回复@(\\w+)\\((.+),(.+)\\):";
    NSError *error = [NSError new];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:replyRegex
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error ];

    NSUInteger count =[regex numberOfMatchesInString:content
                                             options:NSMatchingReportProgress
                                               range:NSMakeRange(0, [content length])];
    if(count > 0){
        return  YES;
    }

    return NO;
}

- (CGSize)postTimeTextSize {
    return [[_postTimeView titleForState:UIControlStateNormal]
            sizeWithFont:_postTimeView.titleLabel.font];
}

- (UIImage *)_postTimeImage {
    return [UIImage imageWithFileName:@"post_time_icon.png"];
}

- (UIImage *)_commentImage {
    return [UIImage imageWithFileName:@"comment_icon.png"];
}

@end