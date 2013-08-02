// 
// Created by henson on 1/26/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

@interface FMPageLoadingView : UIView

- (void)showRefreshText:(void (^)(void))block;

- (void)showMessageText:(NSString *)text;

@end