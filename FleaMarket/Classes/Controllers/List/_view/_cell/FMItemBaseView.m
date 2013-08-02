//
// Created by yuanxiao on 13-7-11.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "FMItemBaseView.h"
#import "FMItemDO.h"
#import "UIImage+Helper.h"

@implementation FMItemBaseView {
@private
    UILabel *_userNameLabel;
    UILabel *_fromLabel;
    UIImageView *_positionImageView;
    UILabel *_positionLabel;
    UIButton *_postTime;

    UIView *_lineView;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.from  = kFMItemBaseViewFromList;

        self.backgroundColor = FMColorWithRed(240, 240, 240);
        _userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(82, 7, 100, 20)];
        _userNameLabel.font = FMFont(YES, 13);
        _userNameLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_userNameLabel];

        _fromLabel = [[UILabel alloc] init];
        _fromLabel.font = FMFont(NO, 10);
        _fromLabel.textColor = FMColorWithRed(176, 176, 173);
        _fromLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_fromLabel];

        UIImage *image = [UIImage imageWithFileName:@"location_icon.png"];
        _positionImageView = [[UIImageView alloc] initWithFrame:
                CGRectMake(82, 28, image.size.width, image.size.height)];
        _positionImageView.image = image;
        [self addSubview:_positionImageView];

        _positionLabel = [[UILabel alloc] initWithFrame:
                CGRectMake(82 + image.size.width + 5, 25, 110, 20)];
        _positionLabel.font = FMFont(NO, 13);
        _positionLabel.adjustsFontSizeToFitWidth = YES;
        _positionLabel.textColor = FMColorWithRed(102, 102, 102);
        _positionLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_positionLabel];

        _postTime = [[UIButton alloc] init];
        _postTime.enabled = NO;
        [_postTime setImage:[UIImage imageWithFileName:@"post_time_icon.png"]
                   forState:UIControlStateNormal];
        _postTime.backgroundColor = [UIColor clearColor];
        _postTime.titleLabel.font = FMFont(NO, 10);
        _postTime.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
        _postTime.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_postTime setTitleColor:FMColorWithRed(176, 176, 173) forState:UIControlStateNormal];
        [self addSubview:_postTime];

        UIView *lineView = [[UIView alloc] initWithFrame:CGRectZero];
        lineView.backgroundColor = FMColorWithRed(235, 235, 235);
        lineView.hidden = YES;
        [self addSubview:lineView];
        _lineView = lineView;
    }
    return self;
}

- (void)setItemDO:(FMItemDO *)itemDO serverTime:(NSString *)serverTime {
    _userNameLabel.text = itemDO.userNick;
    _fromLabel.text = itemDO.detailFrom;
    CGSize size = [_fromLabel.text sizeWithFont:_fromLabel.font
                              constrainedToSize:CGSizeMake(self.frame.size.width, 30)
                                  lineBreakMode:NSLineBreakByWordWrapping];
    _fromLabel.frame = CGRectMake(self.frame.size.width - size.width - 15, 12, size.width, size.height);

    _positionLabel.text = [itemDO getLocationText];

    NSString *postTime = [FMCommon relativeTime:itemDO.firstModified serverTime:serverTime];
    [_postTime setTitle:postTime
               forState:UIControlStateNormal];
    size = [postTime sizeWithFont:_postTime.titleLabel.font
                constrainedToSize:CGSizeMake(100, 30)
                    lineBreakMode:NSLineBreakByWordWrapping];
    _postTime.frame = CGRectMake(self.frame.size.width - size.width - 35, _positionLabel.frame.origin.y + 5,
            size.width + 20, size.height);

    if (self.from == kFMItemBaseViewFromDetail) {
        _lineView.hidden = NO;
        _lineView.frame = CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1);
    } else {
        _lineView.hidden = YES;
        _lineView.frame = CGRectZero;
    }
}

@end