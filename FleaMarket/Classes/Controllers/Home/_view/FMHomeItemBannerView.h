//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-25 上午10:15.
//


#import <Foundation/Foundation.h>
#import "FMImageView.h"
#import "FMHomeItemViewProtocol.h"
#import "FMHomeScrollImageView.h"

@class FMHomeItemDO;

@interface FMHomeItemBannerView : UIView <FMHomeItemViewProtocol>

- (FMHomeItemDO *)homeItemDO;

- (void)setHomeItemDO:(FMHomeItemDO *)homeItemDO;

@end