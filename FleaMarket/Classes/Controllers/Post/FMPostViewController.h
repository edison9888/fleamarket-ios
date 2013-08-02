// 
// Created by henson on 6/6/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>
#import "FMBaseViewController.h"

typedef enum {
    FMPostTypePost = 0,
    FMPostTypeEdit = 1,
} FMPostType;

@class FMItemDO;

@interface FMPostViewController : FMBaseViewController <UIScrollViewDelegate,
        UINavigationControllerDelegate,
        UIImagePickerControllerDelegate,
        FMNeedLoginProtocol>

@property(nonatomic, assign) BOOL isFromQueue;

- (id)initWithItemDO:(FMItemDO *)itemDO;

- (id)initWithItemId:(NSString *)itemId;

@end