//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-12-14 下午3:21.
//


#import <Foundation/Foundation.h>
#import "FMBasePageView.h"

@class FMLocationFilterDO;
@class FMCitySelectionViewDO;

@interface FMCitySelectionView : FMBasePageView
@property(nonatomic, readonly) FMCitySelectionViewDO *viewDO;

- (id)initWithFrame:(CGRect)frame  viewDO:(FMCitySelectionViewDO *)viewDO;

@end