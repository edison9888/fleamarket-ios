//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-12-13 下午6:30.
//


#import <Foundation/Foundation.h>
#import "FMBaseViewController.h"

@class FMSearchParameter;
@class FMFilterFieldOptionDO;

@interface FMStuffStatusViewController : FMBaseViewController

- (id)initWithSearchParameter:(FMSearchParameter *)searchParameter;

- (void)setDidSelectAction:(void (^)(FMFilterFieldOptionDO *))block;


@end