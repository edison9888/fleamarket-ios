// 
// Created by henson on 6/14/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <QuartzCore/QuartzCore.h>
#import <MBMvc/TBMBGlobalFacade.h>
#import "FMAvatarImageView.h"
#import "FMItemDO.h"

@implementation FMAvatarImageView {

@private
    FMItemDO *_itemDO;
}

@synthesize itemDO = _itemDO;

- (id)initWithImage:(UIImage *)image {
    self = [super initWithImage:image];
    if (self) {
        [self setupRadius];
    }

    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupRadius];
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(touchAvatar)];
        tapped.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tapped];
        _isClick = YES;
    }

    return self;
}

- (void)setImage:(UIImage *)image {
    [super setImage:image];
    [self setupRadius];
}

- (void)setItemDO:(FMItemDO *)itemDO {
    _itemDO = itemDO;
    [self setFMImageWithURL:[NSString stringWithFormat:kApiHeadPortrait, itemDO.userId]];
}

- (void)setupRadius {
    self.layer.cornerRadius = self.frame.size.width / 2.f;
    self.layer.masksToBounds = YES;
}

- (void)touchAvatar {
    if (_isClick)
        TBMBGlobalSendNotificationForSELWithBody(@selector($$pushUserItemsControllerByItemDetail:itemDO:), _itemDO);
}

@end