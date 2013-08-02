//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-12-13 下午6:28.
//

#import "FMBaseViewController.h"

@class FMSearchParameter;
@class FMFilterFieldOptionDO;

@interface FMPriceFilterViewController : FMBaseViewController

- (id)initWithSearchParameter:(FMSearchParameter *)searchParameter;

- (void)setDidSelectAction:(void (^)(FMFilterFieldOptionDO *, FMFilterFieldOptionDO *))block;

@end