// 
// Created by henson on 6/13/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>

typedef enum {
    FMCommentCellTypeDetail,
    FMCommentCellTypeMessage
} FMCommentCellType;

@class FMItemCommentDO;

@interface FMItemCommentCell : UITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
    commentCellType:(FMCommentCellType)commentCellType;

+ (float)cellHeight:(FMItemCommentDO *)commentDO;

- (void)setCommentDO:(FMItemCommentDO *)commentDO serverTime:(NSString *)serverTime;

@end