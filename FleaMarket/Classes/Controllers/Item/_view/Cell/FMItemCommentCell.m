// 
// Created by henson on 6/13/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <SDWebImage/UIImageView+WebCache.h>
#import "FMItemCommentCell.h"
#import "RTLabel.h"
#import "FMItemCommentDO.h"
#import "FMAvatarImageView.h"
#import "FMCommon.h"
#import "FMItemDO.h"
#import "FMVoiceButton.h"
#import "NSString+Helper.h"

#define kFMItemCommentCellTextWidth (240)

@implementation FMItemCommentCell {
    __weak FMAvatarImageView *_avatarImageView;
    __weak UIButton *_postTimeView;
    __weak FMVoiceButton *_voiceButton;
    __weak RTLabel *_commentLabel;
    __weak UIView *_lineView;

    __weak UIView *_leftLineView;
    __weak UIView *_rightLineView;
    __weak UIView *_verticalLineView;
    __weak UILabel *_voiceReplyLabel;

    FMItemCommentDO *_itemCommentDO;

    FMCommentCellType _commentCellType;
    CGFloat _startX;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
    commentCellType:(FMCommentCellType)commentCellType {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _commentCellType = commentCellType;

        if (_commentCellType == FMCommentCellTypeDetail) {
            _startX = 20;
        } else if (_commentCellType == FMCommentCellTypeMessage) {
            _startX = 0;
        }

        UIView *verticalLineView = [[UIView alloc] initWithFrame:CGRectZero];
        verticalLineView.backgroundColor = FMColorWithRed(222, 222, 222);
        verticalLineView.hidden = _commentCellType == FMCommentCellTypeDetail ? NO : YES;
        [self.contentView addSubview:verticalLineView];
        _verticalLineView = verticalLineView;

        CGRect avatarImageRect = {{10 + _startX, 10}, {30, 30}};
        FMAvatarImageView *avatarImageView = [[FMAvatarImageView alloc] initWithFrame:avatarImageRect];
        avatarImageView.userInteractionEnabled = YES;
        avatarImageView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:avatarImageView];
        _avatarImageView = avatarImageView;

        CGRect commentRect = {{10 + _startX + 30 + 10, 10}, {kFMItemCommentCellTextWidth, 30}};
        RTLabel *commentLabel = [[RTLabel alloc] initWithFrame:commentRect];
        commentLabel.backgroundColor = [UIColor clearColor];
        commentLabel.font = FMFont(NO, 14);
        commentLabel.textColor = FMColorWithRed(61, 62, 60);
        commentLabel.lineBreakMode = RTTextLineBreakModeWordWrapping;
        [self.contentView addSubview:commentLabel];
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
        [self.contentView addSubview:voiceReplyLabel];
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
        postTimeView.enabled = NO;
        [self.contentView addSubview:postTimeView];
        _postTimeView = postTimeView;

        UIView *lineView = [[UIView alloc] initWithFrame:CGRectZero];
        lineView.backgroundColor = FMColorWithRed(235, 235, 235);
        lineView.hidden = _commentCellType == FMCommentCellTypeMessage ? NO : YES;
        [self.contentView addSubview:lineView];
        _lineView = lineView;

        UIView *leftLineView = [[UIView alloc] initWithFrame:CGRectZero];
        leftLineView.backgroundColor = FMColorWithRed(235, 235, 235);
        leftLineView.hidden = _commentCellType == FMCommentCellTypeDetail ? NO : YES;
        [self.contentView addSubview:leftLineView];
        _leftLineView = leftLineView;

        UIView *rightLineView = [[UIView alloc] initWithFrame:CGRectZero];
        rightLineView.backgroundColor = FMColorWithRed(235, 235, 235);
        rightLineView.hidden = _commentCellType == FMCommentCellTypeDetail ? NO : YES;
        [self.contentView addSubview:rightLineView];
        _rightLineView = rightLineView;
    }

    return self;
}

- (void)setAvatarItemDO:(FMItemCommentDO *)commentDO {
    FMItemDO *itemDO = [[FMItemDO alloc] init];
    itemDO.userId = [NSString stringWithFormat:@"%lld", commentDO.reporterId];
    itemDO.userNick = commentDO.reporterNick;
    itemDO.id = [NSString stringWithFormat:@"%lld", commentDO.itemId];
    _avatarImageView.itemDO = itemDO;
}

- (void)setCommentDO:(FMItemCommentDO *)commentDO serverTime:(NSString *)serverTime {
    if (commentDO == _itemCommentDO) {
        return;
    }
    _itemCommentDO = commentDO;
    [self setAvatarItemDO:commentDO];

    NSString *commentContent = [FMItemCommentCell replaceCommentContent:commentDO.contentWithEmoji];
    if (![commentDO voiceIsEmpty]) {
        _voiceButton.hidden = NO;
        [_voiceButton setVoiceUrl:commentDO.voiceUrl];
        _commentLabel.text = [NSString stringWithFormat:[self replyUsername], commentDO.reporterNick, @""];
    } else {
        _voiceButton.hidden = YES;
        _commentLabel.text = [NSString stringWithFormat:[self replyUsername], commentDO.reporterNick, commentContent];
    }
    _commentLabel.frame = CGRectMake(10 + _startX + 30 + 10, 15, kFMItemCommentCellTextWidth, [self commentTextSize].height);
    _voiceButton.frame = CGRectMake(_commentLabel.frame.origin.x + [self commentTextSize].width + 5, 6, 68, 36);

    if ([FMItemCommentCell hasReply:commentDO.contentWithEmoji]) {
        _voiceReplyLabel.hidden = NO;
        if (![commentDO voiceIsEmpty]) {
            _voiceReplyLabel.text = [FMItemCommentCell replaceVoiceCommentContent:commentDO.contentWithEmoji];
            _voiceReplyLabel.frame = CGRectMake(_commentLabel.frame.origin.x, _commentLabel.frame.origin.y + [self commentTextSize].height + 12, 180, 15);
        } else {
            _voiceReplyLabel.text = [FMItemCommentCell pickUpCommentReplyContent:commentDO.contentWithEmoji];
            _voiceReplyLabel.frame = CGRectMake(_commentLabel.frame.origin.x, _commentLabel.frame.origin.y + [self commentTextSize].height + 4, 180, 15);
        }
    } else {
        _voiceReplyLabel.hidden = YES;
    }
    NSString *postTime = [FMCommon relativeTime:commentDO.reportTime serverTime:serverTime];
    [_postTimeView setTitle:postTime
                   forState:UIControlStateNormal];

    CGSize postTimeSize = [postTime sizeWithFont:_postTimeView.titleLabel.font
                               constrainedToSize:CGSizeMake(1000, 15)
                                   lineBreakMode:NSLineBreakByWordWrapping];

    float postTimeGap = _commentCellType == FMCommentCellTypeDetail ? 10.f : 28.f;
    float lineOriginY;
    if (commentDO.voiceUrl && [commentDO.voiceUrl isNotBlank]) {
        lineOriginY = 64;
    } else {
        lineOriginY = _commentLabel.frame.origin.y + [self commentTextSize].height + 25;
    }

    CGRect postTimeRect = {{self.frame.size.width - postTimeSize.width - 15 - postTimeGap, lineOriginY - 23}, {[self postTimeTextSize].width + 9 + 5, 20}};
    _postTimeView.frame = postTimeRect;

    CGRect lineRect = {{0, lineOriginY}, {self.frame.size.width, 1}};
    _lineView.frame = lineRect;

    CGRect leftLineRect = {{0, lineOriginY}, {44.5, 1}};
    _leftLineView.frame = leftLineRect;

    CGRect rightLineRect = {{leftLineRect.size.width + 3, lineOriginY}, {self.frame.size.width - leftLineRect.size.width - 3, 1}};
    _rightLineView.frame = rightLineRect;

    _verticalLineView.frame = CGRectMake(44.5, 0, 3, lineOriginY + 1);
}

- (CGSize)commentTextSize {
    return [_commentLabel optimumSize];
}

- (NSString *)replyUsername {
    if ([FMItemCommentCell hasReply:_itemCommentDO.content]) {
        return @"<b>%@: </b>%@";
    }
    return @"<b>%@: </b>%@";
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        self.backgroundColor = FMColorWithRGB0X(0xe9e9e9);
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
}

+ (float)cellHeight:(FMItemCommentDO *)commentDO {
    if (commentDO.voiceUrl && [commentDO.voiceUrl isNotBlank]) {
        return 55 + 10;
    }
    RTLabel *label = [[RTLabel alloc] initWithFrame:CGRectMake(30 + 30 + 10, 15, kFMItemCommentCellTextWidth, 30)];
    label.font = FMFont(NO, 14.f);
    label.lineBreakMode = RTTextLineBreakModeWordWrapping;

    NSString *content = [FMItemCommentCell replaceCommentContent:commentDO.contentWithEmoji];
    NSString *username = [FMItemCommentCell hasReply:commentDO.content] ? @"<b>%@</b>%@" : @"<b>%@: </b>%@";
    label.text = [NSString stringWithFormat:username, commentDO.reporterNick, content];
    CGFloat height = 15 + [label optimumSize].height + 25;
    return height;
}

+ (NSString *)replaceCommentContent:(NSString *)content {
    NSString *replyRegex = @"回复@(\\w+)\\((.+),(.+)\\):";
    NSError *error = [NSError new];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:replyRegex
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSString *replacedString = [regex stringByReplacingMatchesInString:content
                                                               options:0
                                                                 range:NSMakeRange(0, [content length])
                                                          withTemplate:@""];/*回复<b>$1</b>: */
    return replacedString;
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

+ (BOOL)hasReply:(NSString *)content {
    NSString *replyRegex = @"回复@(\\w+)\\((.+),(.+)\\):";
    NSError *error = [NSError new];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:replyRegex
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];

    NSUInteger count = [regex numberOfMatchesInString:content
                                              options:NSMatchingReportProgress
                                                range:NSMakeRange(0, [content length])];
    if (count > 0) {
        return YES;
    }

    return NO;
}

- (CGSize)postTimeTextSize {
    return [[_postTimeView titleForState:UIControlStateNormal]
            sizeWithFont:_postTimeView.titleLabel.font];
}

- (UIImage *)_postTimeImage {
    return [UIImage imageNamed:@"post_time_icon.png"];
}

- (UIImage *)_commentImage {
    return [UIImage imageNamed:@"comment_icon.png"];
}

@end