//
// Created by yuanxiao on 13-6-14.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <BlocksKit/UIView+BlocksKit.h>
#import <MBMvc/TBMBGlobalFacade.h>
#import "FMListItemCell.h"
#import "FMImageView.h"
#import "FMItemDO.h"
#import "FMItemCommentDO.h"
#import "UIImage+Helper.h"
#import "FMVoiceButton.h"
#import "FMCommentView.h"
#import "FMPriceView.h"
#import "FMItemTitleView.h"
#import "FMItemBaseView.h"
#import "FMAvatarImageView.h"
#import "FMListCollectView.h"

#define kListItemCellLeftWidth    10
#define kListItemCellTopHeight    20
#define kListItemCellShowWidth    300

#define ListItemCellDecFont   FMFont(NO, 12)


@implementation FMListItemCell {
@private
    UIImageView *_groupBottomLine;
    UIView *_groupView;
    FMImageView *_itemImageView;
    FMVoiceButton *_voiceButton;
    FMListCollectView *_collectView;

    FMItemTitleView *_itemTitleView;

    UILabel *_moreCommentLabel;
    FMCommentView *_commentCell;
    FMItemBaseView *_itemBaseView;

    FMAvatarImageView *_avatarImageView;
    FMPriceView *_priceView;

    FMItemDO *_itemDO;
    FMListType _listType;
}


@synthesize itemDO = _itemDO;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
           listType:(FMListType)listType {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor redColor];
        _listType = listType;
        _groupView = [[UIView alloc] init];
        _groupView.backgroundColor = [UIColor clearColor];
        _groupView.layer.borderWidth = 0.5;
        _groupView.layer.borderColor = FMColorWithRed(216, 214, 198).CGColor;
        [self.contentView addSubview:_groupView];

        [self initTopImageView];
        [self initItemDes];
        [self initComment];

        _voiceButton = [[FMVoiceButton alloc] init];
        _voiceButton.hidden = YES;
        [_groupView addSubview:_voiceButton];

        _groupBottomLine = [[UIImageView alloc] init];
        _groupBottomLine.image = [UIImage imageNamed:@"item_shadow.png"];
        [self.contentView addSubview:_groupBottomLine];

        _avatarImageView = [[FMAvatarImageView alloc] init];
        [self.contentView addSubview:_avatarImageView];

        [self initTouch];
    }
    return self;
}

- (void)initTopImageView {
    _itemImageView = [[FMImageView alloc] initWithFrame:
            CGRectMake(0, 0, kListItemCellShowWidth, kListItemCellShowWidth)];
    _itemImageView.userInteractionEnabled = YES;
    [_groupView addSubview:_itemImageView];

    if (_listType == FMListTypeSell) {
        UIImage *image = [UIImage imageWithFileName:@"icon_edit_item@2x.png"];
        UIButton *editButton = [[UIButton alloc] initWithFrame:
                CGRectMake(kListItemCellShowWidth - 35 - 13, 13, 35, 26)];
        editButton.backgroundColor = [UIColor blackColor];
        editButton.layer.cornerRadius = 13;
        editButton.alpha = 0.6;
        [editButton setImage:image forState:UIControlStateNormal];
        [editButton addTarget:self action:@selector(onTouchEditButton:) forControlEvents:UIControlEventTouchUpInside];
        [_groupView addSubview:editButton];
    } else {
        __weak FMListItemCell *weakSelf = self;
        _collectView = [[FMListCollectView alloc] init];
        [_collectView setClickBlock:^{
            [weakSelf onTouchCollectButton];
        }];
        [_groupView addSubview:_collectView];
    }
    _priceView = [[FMPriceView alloc] initWithFrame:CGRectMake(0, 131, kListItemCellShowWidth, 102)];
    _priceView.userInteractionEnabled = NO;
    [_itemImageView addSubview:_priceView];
}

- (void)initItemDes {
    _itemTitleView = [[FMItemTitleView alloc] init];
    [_groupView addSubview:_itemTitleView];
}

- (void)initComment {
    _itemBaseView = [[FMItemBaseView alloc] initWithFrame:CGRectMake(10, 0, kListItemCellShowWidth, 120)];
    [self.contentView addSubview:_itemBaseView];

    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kListItemCellShowWidth, 1)];
    lineView.backgroundColor = FMColorWithRed(236, 233, 227);

    _moreCommentLabel = [[UILabel alloc] init];
    _moreCommentLabel.userInteractionEnabled = YES;
    _moreCommentLabel.backgroundColor = FMColorWithRed(240, 240, 240);
    _moreCommentLabel.font = FMFont(NO, 14);
    _moreCommentLabel.textColor = FMColorWithRed(176, 176, 173);
    [_moreCommentLabel addSubview:lineView];
    [self.contentView addSubview:_moreCommentLabel];

    _commentCell = [[FMCommentView alloc] init];
    _commentCell.hidden = YES;
    _commentCell.userInteractionEnabled = YES;
    [self.contentView addSubview:_commentCell];
}

- (void)initTouch {
    __weak FMListItemCell *selfWeak = self;
    _groupView.onTouchUpBlock = ^(NSSet *set, UIEvent *event) {
        [selfWeak onTouchDownAction:set withEvent:event];
    };
    _avatarImageView.onTouchUpBlock = ^(NSSet *set, UIEvent *event) {
        [selfWeak onTouchDownAction:set withEvent:event];
    };
    _itemBaseView.onTouchUpBlock = ^(NSSet *set, UIEvent *event) {
        [selfWeak onTouchDownAction:set withEvent:event];
    };
    _moreCommentLabel.onTouchUpBlock = ^(NSSet *set, UIEvent *event) {
        [selfWeak onTouchCommentAction:set withEvent:event];
    };
    _commentCell.onTouchUpBlock = ^(NSSet *set, UIEvent *event) {
        [selfWeak onTouchCommentAction:set withEvent:event];
    };
}

- (void)refreshCollect {
    [_collectView setItemDO:_itemDO listType:_listType];
}

- (void)setData:(FMItemDO *)itemDO serverTime:(NSString *)serverTime {
    _itemDO = itemDO;

    [_itemImageView setWebPImageWithURL:itemDO.oriPicUrl
                    imageScaleType:FMImageScale640x640
                  placeholderImage:FMPlaceholderImage
                           success:^(UIImage *image, FMImageView *view) {
                               view.image = [image resetSquareImage];
                           }
                           failure:nil];


    if (_listType != FMListTypeSell) {
        [_collectView setItemDO:_itemDO listType:_listType];
    }
    [_priceView setItemDO:itemDO];
    //title, des
    [self setDec:itemDO serverTime:serverTime];

    if (itemDO.voiceUrl) {
        _voiceButton.frame = CGRectMake((FM_SCREEN_WIDTH - 68) / 2, _itemTitleView.frame.origin.y - 34 / 2, 68, 36);
        _voiceButton.hidden = NO;
        _voiceButton.voiceUrl = itemDO.voiceUrl;
    } else {
        _voiceButton.hidden = YES;
    }
    _avatarImageView.frame = CGRectMake(20, _groupView.frame.origin.y + _groupView.frame.size.height - 18,
            64, 64);
    _avatarImageView.itemDO = itemDO;
    //评论
    [self setComment:itemDO serverTime:serverTime];

}

- (void)setComment:(FMItemDO *)itemDO serverTime:(NSString *)serverTime {
    CGFloat commentHeight = _groupView.frame.origin.y + _groupView.frame.size.height;
    _itemBaseView.frame = CGRectMake(10, commentHeight, kListItemCellShowWidth, 55);
    [_itemBaseView setItemDO:itemDO serverTime:serverTime];

    commentHeight += 55;
    if (itemDO.itemCommentDOList && itemDO.itemCommentDOList.items.count > 0) {
        _commentCell.hidden = NO;
        FMItemCommentDO *commentDO = [itemDO.itemCommentDOList.items objectAtIndex:0];
        _commentCell.frame = CGRectMake(10, commentHeight, kListItemCellShowWidth, 0);
        [_commentCell setCommentDO:commentDO serverTime:serverTime];
        commentHeight += _commentCell.frame.size.height;
    } else {
        _commentCell.hidden = YES;
    }
    if ([itemDO.commentNum intValue] > 1) {
        _moreCommentLabel.hidden = NO;
        _moreCommentLabel.text = [NSString stringWithFormat:@"   查看全部%@条", itemDO.commentNum];
        _moreCommentLabel.frame = CGRectMake(10, commentHeight, kListItemCellShowWidth, kListItemCellMoreCommentHeight);
    } else {
        _moreCommentLabel.hidden = YES;
    }
}

- (void)setDec:(FMItemDO *)itemDO serverTime:(NSString *)serverTime {
    CGFloat titleHeight = [_itemTitleView setItemDO:itemDO withType:FMItemTitleViewTypeList];
    _itemTitleView.frame = CGRectMake(0, 233, kListItemCellShowWidth, titleHeight);

    _groupView.frame = CGRectMake(kListItemCellLeftWidth, kListItemCellTopHeight,
            kListItemCellShowWidth, 233 + titleHeight);
    _groupBottomLine.frame = CGRectMake(kListItemCellLeftWidth, kListItemCellTopHeight + 233 + titleHeight,
            kListItemCellShowWidth, 2);
}

- (void)onTouchDownAction:(NSSet *)touches withEvent:(UIEvent *)event {
    TBMBGlobalSendNotificationForSELWithBody(@selector($$pushDetailViewController:itemDO:), _itemDO);
}

- (void)onTouchCommentAction:(NSSet *)touches withEvent:(UIEvent *)event {
    TBMBGlobalSendNotificationForSELWithBody(@selector($$pushDetailViewControllerWithClickComment:itemDO:), _itemDO);
}

- (void)onTouchEditButton:(id)sender {
    TBMBGlobalSendNotificationForSELWithBody(@selector($$pushPostViewController:itemId:), _itemDO.id);
}

- (void)onTouchCollectButton {
    TBMBGlobalSendNotificationForSELWithBody(@selector($$collectItem:itemDO:), _itemDO);
}

@end