//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-8 上午7:59.
//


#import <Foundation/Foundation.h>
#import "TBMBDefaultPage.h"

typedef enum {
    LeftButtonWithBack = 0,
    LeftButtonWithIcon,
    LeftButtonWithWhite,
    LeftButtonWithGreen
} FMHeaderBarLeftButtonType;

typedef enum {
    RightButtonWithNoIcon = 0,
    RightButtonWithIcon
} FMHeaderBarRightButtonType;

typedef enum {
    FMHeaderBarBGTypeGreen,
    FMHeaderBarBGTypeBlack
} FMHeaderBarBGType;


@interface FMBaseBarViewDO : NSObject
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *leftButtonName;
@property(nonatomic, copy) NSString *rightButtonName;
@property(nonatomic, assign) FMHeaderBarLeftButtonType leftButtonType;
@property(nonatomic, assign) FMHeaderBarRightButtonType rightButtonType;
@property(nonatomic, strong) UIImage *leftIcon;
@property(nonatomic, strong) UIImage *rightIcon;
@property(nonatomic, strong) UIImage *rightSelectIcon;
@property(nonatomic, assign) FMHeaderBarBGType headerBarBGType;
@property(nonatomic, assign) BOOL leftButtonShow;
@property(nonatomic, assign) BOOL rightButtonShow;

@end

@protocol FMBaseBarViewDelegate <NSObject>
@optional
- (void)onRightButtonPressed:(UIButton *)button;

- (void)onLeftButtonPressed:(UIButton *)button;
@end

@interface FMBaseBarView : TBMBDefaultPage

@property(nonatomic, strong) FMBaseBarViewDO *viewDO;

@property(nonatomic, strong, readonly) UIButton *leftBarButton;
@property(nonatomic, strong, readonly) UIButton *rightBarButton;
@property(nonatomic, strong, readonly) UIView *titleView;

@property(nonatomic, weak) id <FMBaseBarViewDelegate> delegate;


@end