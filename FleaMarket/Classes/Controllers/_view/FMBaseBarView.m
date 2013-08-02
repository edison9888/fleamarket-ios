//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-8 上午7:59.
//


#import "FMBaseBarView.h"

#import "NSString+Helper.h"
#import "TBMBBind.h"
#import "UIImage+Helper.h"

@implementation FMBaseBarViewDO {
@private
    UIImage *_rightSelectIcon;
    FMHeaderBarBGType _headerBarBGType;
}
@synthesize rightSelectIcon = _rightSelectIcon;
@synthesize headerBarBGType = _headerBarBGType;
@end

@implementation FMBaseBarView {
@private
    UILabel *_titleLabel;
    UIButton *_leftBarButton;
    UIButton *_rightBarButton;
    UIView *_titleView;
    __weak id <FMBaseBarViewDelegate> _delegate;
    FMBaseBarViewDO *_viewDO;

    UIView *_rightLine;
    UIView *_leftLine;
    UIImageView *_imageView;
}

@synthesize leftBarButton = _leftBarButton;
@synthesize rightBarButton = _rightBarButton;
@synthesize delegate = _delegate;
@synthesize viewDO = _viewDO;

@synthesize titleView = _titleView;

- (void)loadView {
    [super loadView];
    UIView *titleView = [[UIView alloc] initWithFrame:self.bounds];
    titleView.backgroundColor = [UIColor clearColor];

    _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _imageView.contentMode = UIViewContentModeScaleToFill;
    [titleView addSubview:_imageView];
    [self addSubview:titleView];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 200, titleView.frame.size.height)];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = (NSTextAlignment) UITextAlignmentCenter;
    label.font = FMFont(YES, 19.0f);
    label.textColor = FMColorWithRed(61, 61, 61);
    label.text = self.viewDO.title;
    [titleView addSubview:label];
    _titleLabel = label;

    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setHidden:YES];
    [leftButton setImage:[UIImage imageWithFileName:@"header_back_icon.png"]
                forState:UIControlStateNormal];
    [leftButton setImage:[UIImage imageWithFileName:@"header_back_icon_highlight.png"]
                forState:UIControlStateHighlighted];
    [leftButton addTarget:self
                   action:@selector(leftAction:)
         forControlEvents:UIControlEventTouchUpInside];
    leftButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
    [leftButton setFrame:CGRectMake(0, 7, 45, 30)];
    [titleView addSubview:leftButton];
    _leftBarButton = leftButton;

    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setHidden:YES];
    [rightButton addTarget:self
                    action:@selector(rightAction:)
          forControlEvents:UIControlEventTouchUpInside];
    [rightButton setFrame:CGRectMake(320 - 49, 7, 45, 30)];
    rightButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
    [titleView addSubview:rightButton];
    _rightBarButton = rightButton;
    _titleView = titleView;

    _rightLine = [[UIView alloc] init];
    _rightLine.hidden = YES;
    [self addSubview:_rightLine];

    _leftLine = [[UIView alloc] init];
    _leftLine.hidden = YES;
    [self addSubview:_leftLine];
}

- (void)rightAction:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(onRightButtonPressed:)]) {
        [_delegate onRightButtonPressed:sender];
    }
}

- (void)leftAction:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(onLeftButtonPressed:)]) {
        [_delegate onLeftButtonPressed:sender];
    }
}


TBMBWhenThisKeyPathChange(viewDO, title){
    _titleLabel.text = new;
}

TBMBWhenThisKeyPathChange(viewDO, leftButtonShow){
    [_leftBarButton setHidden:![new boolValue]];
    [_leftLine setHidden:![new boolValue]];
}

TBMBWhenThisKeyPathChange(viewDO, rightButtonShow){
    [_rightBarButton setHidden:![new boolValue]];
    [_rightLine setHidden:![new boolValue]];
}

//TBMBWhenThisKeyPathChange(viewDO, leftButtonName){
//    [_leftBarButton setTitle:new
//                    forState:UIControlStateNormal];
//}

TBMBWhenThisKeyPathChange(viewDO, headerBarBGType){
    FMHeaderBarBGType headerBarBGType =  (FMHeaderBarBGType) [new intValue];
    if (headerBarBGType == FMHeaderBarBGTypeBlack) {
        _imageView.image = [[UIImage imageWithFileName:@"header_bg_black.png"]
                resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        _rightLine.backgroundColor = FMColorWithRed(52, 52, 52);
        if (self.viewDO.rightButtonType == RightButtonWithNoIcon) {
            [_rightBarButton setBackgroundImage:[[UIImage imageWithFileName:@"header_right_select_black_icon.png"]
                    resizeImageWithCapInsets:UIEdgeInsetsMake(4, 0, 0, 4)]
                                       forState:UIControlStateHighlighted];
        }
    } else if (headerBarBGType == FMHeaderBarBGTypeGreen) {
        _imageView.image = [[UIImage imageWithFileName:@"header_bg.png"]
                resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        _rightLine.backgroundColor = FMColorWithRed(225, 225, 225);
        if (self.viewDO.rightButtonType == RightButtonWithNoIcon) {
            [_rightBarButton setBackgroundImage:[[UIImage imageWithFileName:@"header_right_select_icon.png"]
                    resizeImageWithCapInsets:UIEdgeInsetsMake(4, 0, 0, 4)]
                                       forState:UIControlStateHighlighted];
        }
    }
}

TBMBWhenThisKeyPathChange(viewDO, rightButtonName){
    if (isInit) {
        return;
    }
    [_rightBarButton setTitle:new
                     forState:UIControlStateNormal];
    if (self.viewDO.rightButtonType == RightButtonWithNoIcon) {
        _rightLine.hidden = NO;
        CGSize size1 = [new sizeWithFont:_rightBarButton.titleLabel.font
                       constrainedToSize:CGSizeMake(100, 30)
                           lineBreakMode:NSLineBreakByWordWrapping];
        CGSize size2 = [@"确定" sizeWithFont:_rightBarButton.titleLabel.font
                         constrainedToSize:CGSizeMake(100, 30)
                             lineBreakMode:NSLineBreakByWordWrapping];
        CGFloat width = 56 + (size1.width - size2.width);
        _rightLine.frame = CGRectMake(FM_SCREEN_WIDTH - width, 0, 1, kNavigationBarHeight);
        _rightBarButton.frame = CGRectMake(FM_SCREEN_WIDTH - width, 0, width, kNavigationBarHeight);
    } else if (self.viewDO.rightButtonType == RightButtonWithIcon) {
        _rightBarButton.frame = CGRectMake(320 - 49, 7, 45, 30);
    }
}

TBMBWhenThisKeyPathChange(viewDO, leftButtonName){
    if (isInit) {
        return;
    }
    [_leftBarButton setTitle:new
                     forState:UIControlStateNormal];
}

TBMBWhenThisKeyPathChange(viewDO, leftIcon){
    if (self.viewDO.leftButtonType == LeftButtonWithIcon) {
        if (!new) {
            return;
        }
        [_leftBarButton setImage:new
                        forState:UIControlStateNormal];
        [_leftBarButton setImage:new
                        forState:UIControlStateHighlighted];
        return;
    }
}

TBMBWhenThisKeyPathChange(viewDO, rightIcon){
    if (self.viewDO.rightButtonType == RightButtonWithIcon) {
        if (!new) {
            return;
        }
        [_rightBarButton setImage:new
                         forState:UIControlStateNormal];
        [_rightBarButton setImage:new
                         forState:UIControlStateHighlighted];
        [_rightBarButton setBackgroundImage:nil
                                   forState:UIControlStateHighlighted];
        _rightBarButton.frame = CGRectMake(FM_SCREEN_WIDTH - 49, 7, 45, 30);
    }
}

TBMBWhenThisKeyPathChange(viewDO, rightSelectIcon){
    if (self.viewDO.rightButtonType == RightButtonWithIcon) {
        if (!new) {
            return;
        }
        [_rightBarButton setImage:new
                         forState:UIControlStateHighlighted];
        [_rightBarButton setBackgroundImage:nil
                                   forState:UIControlStateHighlighted];
    }
}

TBMBWhenThisKeyPathChange(viewDO, leftButtonType){
    FMHeaderBarLeftButtonType buttonType = (FMHeaderBarLeftButtonType) [new intValue];
    if (buttonType == LeftButtonWithBack) {
        [_leftBarButton setImage:[UIImage imageWithFileName:@"header_back_icon.png"]
                        forState:UIControlStateNormal];
        [_leftBarButton setImage:[UIImage imageWithFileName:@"header_back_icon_highlight.png"]
                        forState:UIControlStateHighlighted];
        _leftLine.hidden = YES;
        return;
    }

    if (buttonType == LeftButtonWithIcon) {
        if (!self.viewDO.leftIcon) {
            return;
        }
        [_leftBarButton setImage:self.viewDO.leftIcon
                        forState:UIControlStateNormal];
        [_leftBarButton setImage:self.viewDO.leftIcon
                        forState:UIControlStateHighlighted];
        _leftLine.hidden = YES;
        return;
    }

    if (buttonType == LeftButtonWithWhite) {
        [_leftBarButton setImage:nil
                        forState:UIControlStateNormal];
        [_leftBarButton setImage:nil
                        forState:UIControlStateHighlighted];

        [_leftBarButton setBackgroundImage:[[UIImage imageWithFileName:@"header_right_select_icon.png"]
                resizeImageWithCapInsets:UIEdgeInsetsMake(4, 0, 0, 4)]
                        forState:UIControlStateHighlighted];
        [_leftBarButton setBackgroundImage:nil
                                  forState:UIControlStateNormal];

        [_leftBarButton setTitle:self.viewDO.leftButtonName
                        forState:UIControlStateNormal];

        [_leftBarButton setTitleColor:[UIColor blackColor]
                             forState:UIControlStateNormal];

        _leftBarButton.titleLabel.font = FMFont(NO, 14.0f);

        _leftLine.hidden = NO;
        CGSize size1 = [self.viewDO.leftButtonName sizeWithFont:_rightBarButton.titleLabel.font
                       constrainedToSize:CGSizeMake(100, 30)
                           lineBreakMode:NSLineBreakByWordWrapping];
        CGSize size2 = [@"确定" sizeWithFont:_rightBarButton.titleLabel.font
                         constrainedToSize:CGSizeMake(100, 30)
                             lineBreakMode:NSLineBreakByWordWrapping];
        CGFloat width = 56 + (size1.width - size2.width);
        _leftLine.frame = CGRectMake(width, 0, 1, kNavigationBarHeight);
        _leftBarButton.frame = CGRectMake(0, 0, width, kNavigationBarHeight);
        _leftLine.backgroundColor = FMColorWithRed(225, 225, 225);
        return;
    }

    if (buttonType == LeftButtonWithGreen) {
        [_leftBarButton setImage:nil
                        forState:UIControlStateNormal];
        [_leftBarButton setImage:nil
                        forState:UIControlStateHighlighted];
        [_leftBarButton setTitle:self.viewDO.leftButtonName
                        forState:UIControlStateNormal];
        [_leftBarButton setTitleColor:[UIColor whiteColor]
                             forState:UIControlStateNormal];
        [_leftBarButton setFrame:CGRectMake(10, 7, 45, 30)];
        _leftBarButton.titleLabel.font = FMFont(YES, 14.0f);
        [_leftBarButton setTitleShadowColor:FMColorWithRedAlpha(0, 0, 0, 0.4)
                                   forState:UIControlStateNormal];
        _leftBarButton.titleLabel.shadowOffset = CGSizeMake(0, -1.0);
        _leftLine.hidden = NO;
        _leftLine.backgroundColor = FMColorWithRed(225, 225, 225);
        return;
    }

}

TBMBWhenThisKeyPathChange(viewDO, rightButtonType){
    if (isInit) {
        return;
    }
    FMHeaderBarRightButtonType rightButtonType = (FMHeaderBarRightButtonType) [new intValue];
    if (rightButtonType != RightButtonWithIcon && [self.viewDO.rightButtonName isBlank]) {
        return;
    }

    [_rightBarButton setHidden:NO];
    if (rightButtonType == RightButtonWithNoIcon) {
        [_rightBarButton setTitleColor:[UIColor blackColor]
                              forState:UIControlStateNormal];
        [_rightBarButton setTitle:self.viewDO.rightButtonName
                         forState:UIControlStateNormal];
        _rightBarButton.titleLabel.font = FMFont(NO, 14.0f);
        [_rightBarButton setTitleShadowColor:[UIColor grayColor]
                                    forState:UIControlStateNormal];
        return;
    }

    if (rightButtonType == RightButtonWithIcon) {
        if (!self.viewDO.rightIcon) {
            return;
        }
        [_rightBarButton setImage:self.viewDO.rightIcon
                         forState:UIControlStateNormal];
        [_rightBarButton setImage:self.viewDO.rightSelectIcon
                         forState:UIControlStateHighlighted];
        [_rightBarButton setBackgroundImage:nil
                                   forState:UIControlStateHighlighted];
        _rightBarButton.frame = CGRectMake(FM_SCREEN_WIDTH - 49, 7, 45, 30);
        _rightLine.hidden = YES;
        return;
    }
}


@end