//
// Created by yuanxiao on 13-6-28.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class FMItemCommentDO;


@interface FMCommentView : UIView

+ (float)cellHeight:(FMItemCommentDO *)commentDO;

- (void)setCommentDO:(FMItemCommentDO *)commentDO serverTime:(NSString *)serverTime;

@end