// 
// Created by henson on 4/11/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>

@interface FMShipmentsItemInfoCell : UITableViewCell

@property(nonatomic, strong) UILabel *rightLabel;

- (void)setLeft:(NSString *)leftText right:(NSString *)rightText;

@end