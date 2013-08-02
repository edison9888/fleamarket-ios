//
// Created by yuanxiao on 13-7-15.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "FMSystemMessageCell.h"
#import "FMMessageInfo.h"
#import "FMTradeMessageInfo.h"
#import "FMStyle.h"
#import "FMSystemMessageContent.h"
#import "FMCommon.h"

#define kSystemMessagePostHeight  10

@implementation FMSystemMessageCell {
@private
    UILabel *_descLabel;
    UIView *_lineView;

    UIButton *_postTimeView;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.backgroundColor = [UIColor clearColor];
        _descLabel.textColor = [FMColor instance].cellColor;
        _descLabel.font = [FMFontSize instance].cellLabelSize;
        _descLabel.numberOfLines = 0;
        [self.contentView addSubview:_descLabel];

        _postTimeView = [UIButton buttonWithType:UIButtonTypeCustom];
        [_postTimeView setImage:[UIImage imageNamed:@"post_time_icon.png"] forState:UIControlStateNormal];
        [_postTimeView setTitleColor:FMColorWithRed(176, 176, 173) forState:UIControlStateNormal];
        _postTimeView.titleLabel.font = FMFont(NO, 10);
        _postTimeView.titleLabel.textAlignment = NSTextAlignmentRight;
        _postTimeView.frame = CGRectZero;
        [_postTimeView setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
        [_postTimeView setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 2)];
        _postTimeView.enabled = NO;
        [self.contentView addSubview:_postTimeView];

        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = FMColorWithRed(236, 233, 227);
        [self.contentView addSubview:_lineView];
    }
    return self;
}

- (void)setCommentDO:(FMMessageInfo *)messageInfo {
    if (messageInfo.type == BUY || messageInfo.type == SOLD) {
        FMTradeMessageInfo *tradeMessageInfo = messageInfo.contentId;
        _descLabel.text = tradeMessageInfo.desc;
    } else {
        FMSystemMessageContent *systemMessageInfo = messageInfo.contentId;
        _descLabel.text = systemMessageInfo.desc;
    }
    CGSize size = [_descLabel.text sizeWithFont:_descLabel.font
                                constrainedToSize:CGSizeMake(280, 300)
                                    lineBreakMode:NSLineBreakByWordWrapping];
    if (size.height < 24) {
        size.height = 24;
    }
    _descLabel.frame = CGRectMake(10, 10, size.width, size.height);

    NSString *postTime = [FMCommon relativeTime:[FMCommon stringWithDate:messageInfo.lastTime]
                                     serverTime:nil];
    [_postTimeView setTitle:postTime
                   forState:UIControlStateNormal];

    CGSize postTimeSize = [postTime sizeWithFont:_postTimeView.titleLabel.font
                               constrainedToSize:CGSizeMake(1000, 15)
                                   lineBreakMode:NSLineBreakByWordWrapping];
    _postTimeView.frame = CGRectMake(300 - postTimeSize.width - 20, size.height + 10,
            postTimeSize.width + 20, kSystemMessagePostHeight);

    _lineView.frame = CGRectMake(0, 19 + size.height + kSystemMessagePostHeight, FM_SCREEN_WIDTH, 1);
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        self.backgroundColor = FMColorWithRGB0X(0xe9e9e9);
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
}

+ (CGFloat)cellHeight:(FMMessageInfo *)messageInfo {
    NSString *desc;
    if (messageInfo.type == BUY || messageInfo.type == SOLD) {
        FMTradeMessageInfo *tradeMessageInfo = messageInfo.contentId;
        desc = tradeMessageInfo.desc;
    } else {
        FMSystemMessageContent *systemMessageInfo = messageInfo.contentId;
        desc = systemMessageInfo.desc;
    }
    CGSize size = [desc sizeWithFont:[FMFontSize instance].cellLabelSize
                              constrainedToSize:CGSizeMake(280, 300)
                                  lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat height = size.height > 24 ? size.height + 20 : 44;

    return height + kSystemMessagePostHeight;
}

@end