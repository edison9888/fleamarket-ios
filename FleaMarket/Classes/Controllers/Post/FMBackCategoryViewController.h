// 
// Created by henson on 7/12/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>
#import "FMBaseViewController.h"

@interface FMBackCategoryViewController : FMBaseViewController <UITableViewDelegate, UITableViewDataSource>

- (id)initWithCategories:(NSArray *)categories;

- (void)setCategoryDidSelect:(void (^)(NSArray *))block;

@end