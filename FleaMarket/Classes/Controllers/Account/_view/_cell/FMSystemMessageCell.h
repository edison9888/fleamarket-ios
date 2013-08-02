//
// Created by yuanxiao on 13-7-15.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "FMBaseTableViewCell.h"

@class FMMessageInfo;

@interface FMSystemMessageCell : UITableViewCell

- (void)setCommentDO:(FMMessageInfo *)commentDO;

+ (CGFloat)cellHeight:(FMMessageInfo *)messageInfo;

@end