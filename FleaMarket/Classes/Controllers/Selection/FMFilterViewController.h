//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-12-13 下午6:22.
//

enum {
    FMFilterFieldNone = 0,
    FMFilterFieldStatus = 1 << 0,
    FMFilterFieldPrice = 1 << 1,
    FMFilterFieldSortOrder = 1 << 2,
    FMFilterFieldCategory = 1 << 3,
    FMFilterFieldDistance = 1 << 4,
    FMFilterFieldTrade = 1 << 5,
    FMFilterFieldLocationLimit = 1 << 6,
    FMFilterFieldLocation = 1 << 7,
};

#import <Foundation/Foundation.h>
#import "FMBaseViewController.h"

@class FMSearchParameter;

@interface FMFilterViewController : FMBaseViewController

@property(nonatomic, strong) FMSearchParameter *searchParameter;

- (id)initWithFilterFields:(NSUInteger)filterFields;

- (void)setFilterDone:(void (^)())filterDoneBlock;

@end