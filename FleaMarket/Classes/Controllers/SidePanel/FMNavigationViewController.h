//
//  FMNavigationViewController.h
//  CustomNavigationController
//
//  Created by taobao on 13-3-29.
//  Copyright (c) 2013年 taobao. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FMNeedClosePanGestureProtocol

@end

@interface FMNavigationViewController : UINavigationController <UIGestureRecognizerDelegate> {
}

@property(nonatomic, assign) BOOL isCloseDrag;


@end
