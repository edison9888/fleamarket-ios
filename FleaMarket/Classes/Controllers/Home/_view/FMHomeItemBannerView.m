//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-25 上午10:15.
//


#import <QuartzCore/QuartzCore.h>
#import "FMHomeItemBannerView.h"
#import "FMHomeItemDO.h"

@implementation FMHomeItemBannerView {
@private
    FMHomeItemDO *_item;
    FMHomeScrollImageView *_scrollImageView;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 4.f;
        self.layer.masksToBounds = YES;

        _scrollImageView = [[FMHomeScrollImageView alloc]
                initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self addSubview:_scrollImageView];
    }
    return self;
}

- (FMHomeItemDO *)homeItemDO {
    return _item;
}

- (void)setHomeItemDO:(FMHomeItemDO *)homeItemDO {
    _item = homeItemDO;
    if (homeItemDO) {
        [_scrollImageView setData:homeItemDO.picUrls
                         isBanner:YES
                   imageScaleType:FMImageScaleNone];
    }
}

@end