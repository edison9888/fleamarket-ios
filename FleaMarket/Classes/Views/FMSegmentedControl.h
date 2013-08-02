//
//  FMSegmentedControl.h
//  FleaMarket
//
//  Created by Henson on 10/16/12.
//  Copyright (c) 2012 taobao.com. All rights reserved.
//

@interface FMSegmentedControlItem : UIView {
    UIImageView *_backgroundImageView;
    UILabel *_titleLabel;
    UIImageView *_arrowImageView;

    UIImage *_selectedImage;
    UIImage *_image;
    UIImage *_arrowImage;
    BOOL _enable;

    BOOL _isRepeatTouch;
    BOOL _selected;
    __unsafe_unretained id _delegate;
}

@property(nonatomic, strong) UIImage *selectedImage;
@property(nonatomic, strong) UIImage *image;
@property(nonatomic, assign) id delegate;
@property(nonatomic, strong) UIImage *arrowImage;
@property(nonatomic, assign) BOOL enable;

- (id)initWithTitle:(NSString *)title hasArrowImage:(BOOL)yesOrNo isRepeatTouch:(BOOL)isRepeatTouch;

- (id)initWithTitle:(NSString *)title;

@end

@interface FMSegmentedControl : UIView {
    NSMutableArray *_items;
    __unsafe_unretained id _delegate;
    NSUInteger _selectedIndex;
    BOOL _enable;
}

@property(nonatomic, assign) id delegate;
@property(nonatomic, strong) NSMutableArray *items;
@property(nonatomic) NSUInteger selectedIndex;
@property(nonatomic) BOOL enable;

- (void)setSegmentedItems:(NSArray *)items;

- (void)setSegmentChangedAction:(void (^)(FMSegmentedControlItem *))block;

@end
