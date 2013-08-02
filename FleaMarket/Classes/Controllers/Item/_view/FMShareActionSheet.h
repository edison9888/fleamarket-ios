// 
// Created by henson on 12/26/12.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

@class FMShareActionSheetItem;

typedef NS_ENUM(NSUInteger, kFMShareType) {
    kFMShareTypeWeibo,
    kFMShareTypeWeiXin,
    kFMShareTypeWeiXinFriend,
    kFMShareTypeDouban,
};

@protocol FMShareActionSheetItemProtocol <NSObject>

@optional
- (void)actionSheetDidClick:(FMShareActionSheetItem *)actionSheetItem;

@end

@interface FMShareActionSheetItem : UIView

@property(nonatomic, strong) UILabel *textLabel;
@property(nonatomic, strong) UIImage *image;
@property(nonatomic, strong) UIImage *loginImage;
@property(nonatomic, assign) BOOL isLogin;
@property(nonatomic, weak) id <FMShareActionSheetItemProtocol> delegate;
@property(nonatomic, assign) kFMShareType type;

@end

@interface FMShareActionSheet : UIView <FMShareActionSheetItemProtocol>

- (void)setClickItemAction:(void (^)(FMShareActionSheetItem *, FMShareActionSheet *))block;

-(void)showInView:(UIView *)view;

@end