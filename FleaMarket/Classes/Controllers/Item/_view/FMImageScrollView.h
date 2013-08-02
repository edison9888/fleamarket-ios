//
//  FMScrollView.h
//  FleaMarket
//
//  Created by yuanxiao on 12-9-21.
//  Copyright (c) 2012年 taobao.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FMImageView;


@interface FMImageScrollView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) FMImageView *imageView;

- (void)downLoad;
@end
