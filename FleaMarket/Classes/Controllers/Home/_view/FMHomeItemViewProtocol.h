//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-25 上午10:26.
//


#import <Foundation/Foundation.h>

@class FMHomeItemDO;

@protocol FMHomeItemViewProtocol <NSObject>
@required
- (FMHomeItemDO *)homeItemDO;

- (void)setHomeItemDO:(FMHomeItemDO *)homeItemDO;
@end