//
// Created by yuanxiao on 13-6-14.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "FMBaseTableViewCell.h"
#import "FMListView.h"

@class FMItemCommentDO;
@class FMItemDO;

@interface FMListItemCell : UITableViewCell

@property (nonatomic, strong) FMItemDO *itemDO;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
           listType:(FMListType)listType;

- (void)setData:(FMItemDO *)itemDO serverTime:(NSString *)serverTime;

- (void)refreshCollect;

@end