// 
// Created by henson on 7/21/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>
#import "FMBaseViewController.h"

@interface FMPostImagePreviewController : FMBaseViewController <UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray *imageInfos;
@property (nonatomic, assign) NSUInteger index;

- (void)setPostImagePreviewDismiss:(void(^)())block;

- (void)setDeleteDismiss:(void (^)(NSUInteger))block;

@end