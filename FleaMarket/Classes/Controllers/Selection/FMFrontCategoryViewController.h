//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-12-13 下午6:28.
//


#import <Foundation/Foundation.h>
#import "FMBaseViewController.h"

@class FMSearchParameter;

typedef enum {
    FMFrontCategoryViewTypeNone,
    FMFrontCategoryViewTypeSearch
} FMFrontCategoryViewType;

@interface FMFrontCategoryViewController : FMBaseViewController

- (id)initWithType:(FMFrontCategoryViewType)viewType;

- (id)initWithSearchParameter:(FMSearchParameter *)searchParameter;

- (void)setDidSelectAction:(void (^)(NSArray *))block;


@end