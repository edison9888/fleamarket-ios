// 
// Created by henson on 6/6/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>
#import "FMSidePanelController.h"

#define FMTapHomeName       @"主页"
#define FMTapThemeName      @"随便逛逛"
#define FMTapPostName       @"我要卖"
#define FMTapAccountName    @"个人中心"
#define FMTapSearchName     @"搜索"
#define FMTapSettingName    @"设置"

#define kSidePanelRightFixedWidth  27

typedef enum {
    FMTapTypeHome,
    FMTapTypeTheme,
    FMTapTypePost,
    FMTapTypeAccount,
    FMTapTypeSearch,
    FMTapTypeSetting
} FMTapType;

@interface FMRootViewControllerDO : NSObject

@property (nonatomic, assign) FMTapType tapType;
@property (nonatomic, copy) NSString *itemName;
@property (nonatomic, copy) NSString *itemImage;
@property (nonatomic, copy) NSString *itemSelectedImage;
@property (nonatomic, strong) UIColor *itemBGColor;
@property (nonatomic, strong) UIColor *itemNameSelectedColor;
@property (nonatomic, strong) UIViewController *viewController;

@end


@interface FMRootViewController : FMSidePanelController <UINavigationControllerDelegate>

@end