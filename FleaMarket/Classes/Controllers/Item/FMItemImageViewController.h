//
// Created by yuanxiao on 12-11-1.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import <UIKit/UIKit.h>
#import "FMBaseViewController.h"
#import "FMNavigationViewController.h"

@interface FMItemImageViewController : FMBaseViewController<UIScrollViewDelegate,
        FMNeedClosePanWithSidePanel, FMNeedClosePanGestureProtocol, UIGestureRecognizerDelegate> {
}

@property(nonatomic, retain) NSArray *images;
@property(nonatomic, copy) NSString *titleText;


- (void)scrollToPage:(int)page;

@end


























