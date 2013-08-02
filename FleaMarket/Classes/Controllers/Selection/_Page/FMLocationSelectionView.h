//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-12-13 下午7:41.
//


#import <Foundation/Foundation.h>
#import "FMBasePageView.h"

@class FMLocationFilterDO;
@class FMLocationViewDO;

@protocol FMLocationSelectionViewDelegate
- (void)gotoSelectCity;
@end

@interface FMLocationSelectionView : FMBasePageView
@property(nonatomic, strong) FMLocationFilterDO *filterDO;
@property(nonatomic, readonly) FMLocationViewDO *viewDO;

@property(nonatomic, strong) id <FMLocationSelectionViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame AndViewDO:(FMLocationViewDO *)locationViewDO;


@end