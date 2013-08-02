//
//  FMSegmentedControl.m
//  FleaMarket
//
//  Created by Henson on 10/16/12.
//  Copyright (c) 2012 taobao.com. All rights reserved.
//

#import "FMSegmentedControl.h"
#import "TBMBBind.h"
#import "UIImage+Helper.h"

@implementation FMSegmentedControlItem
@synthesize selectedImage = _selectedImage;
@synthesize image = _image;
@synthesize delegate = _delegate;
@synthesize arrowImage = _arrowImage;
@synthesize enable = _enable;

- (id)init {
    self = [super init];
    if (self) {
        _isRepeatTouch = NO;
        _enable = YES;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (id)initWithTitle:(NSString *)title hasArrowImage:(BOOL)yesOrNo isRepeatTouch:(BOOL)isRepeatTouch {
    self = [self init];
    if (self) {
        _isRepeatTouch = isRepeatTouch;

        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.origin.x,
                self.bounds.origin.y, self.frame.size.width, self.frame.size.height)];
        _backgroundImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_backgroundImageView];

        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 20)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = (NSTextAlignment) UITextAlignmentCenter;
        _titleLabel.font = FMFont(YES, 15.0f);
        _titleLabel.textColor = FMColorWithRed(0x66, 0x66, 0x66);
        _titleLabel.shadowColor = [UIColor whiteColor];
        _titleLabel.shadowOffset = CGSizeMake(0, 1.0);
        _titleLabel.text = title;
        [self addSubview:_titleLabel];

        if (yesOrNo == YES) {
            _arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 12)];
            _arrowImageView.backgroundColor = [UIColor clearColor];
            _arrowImageView.image = [UIImage imageWithFileName:@"sort_arrow_up.png"];
            _arrowImageView.hidden = YES;
            [self addSubview:_arrowImageView];
        }
    }
    return self;
}

- (id)initWithTitle:(NSString *)title {
    return [self initWithTitle:title hasArrowImage:NO isRepeatTouch:NO];
}

- (void)setArrowImage:(UIImage *)arrowImage {
    _arrowImage = arrowImage;
    if (_arrowImageView != nil) {
        _arrowImageView.image = arrowImage;
    }
}

- (void)layoutSubviews {
    _titleLabel.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);

    _backgroundImageView.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.frame.size.width, self.frame.size.height);
    CGSize textSize = [_titleLabel.text sizeWithFont:[UIFont systemFontOfSize:14.f]
                                   constrainedToSize:CGSizeMake(200, 1000.0f)
                                       lineBreakMode:(NSLineBreakMode) UILineBreakModeCharacterWrap];

    if (_arrowImageView != nil) {
        _arrowImageView.frame = CGRectMake((self.frame.size.width - textSize.width) / 2.0 + textSize.width + 5, 9.5,
                _arrowImageView.frame.size.width, _arrowImageView.frame.size.height);
    }
}

- (void)setItemSelected:(BOOL)selected {
    _selected = selected;
    if (_selected) {
        _backgroundImageView.image = _selectedImage;
        if (_arrowImageView != nil) {
            _arrowImageView.hidden = NO;
        }
        return;
    }
    if (_arrowImageView != nil) {
        _arrowImageView.hidden = YES;
    }

    _backgroundImageView.image = _image;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!_enable) {
        return;
    }

    if (_selected && _isRepeatTouch == NO) {
        return;
    }

    _selected = YES;
    if (_delegate && [_delegate respondsToSelector:@selector(selectedSegmentedControlItem:)]) {
        [_delegate performSelector:@selector(selectedSegmentedControlItem:) withObject:self];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    return;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    return;
}

- (void)drawRect:(CGRect)rect {
    if (_selected) {
        _backgroundImageView.image = _selectedImage;
    } else {
        _backgroundImageView.image = _image;
    }
}

@end

@implementation FMSegmentedControl {
    void (^_segmentChangedActionBlock)(FMSegmentedControlItem *);
}

@synthesize delegate = _delegate;
@synthesize items = _items;
@synthesize selectedIndex = _selectedIndex;
@synthesize enable = _enable;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.enable = YES;
        _items = [[NSMutableArray alloc] initWithCapacity:3];
    }

    return self;
}

- (void)setSegmentedItems:(NSArray *)items {
    if (items == nil || [items count] < 1) {
        return;
    }

    for (FMSegmentedControlItem *item in _items) {
        [item removeFromSuperview];
    }

    [_items removeAllObjects];
    [_items addObjectsFromArray:items];

    for (int i = 0; i < [_items count]; i++) {
        FMSegmentedControlItem *item = [_items objectAtIndex:(NSUInteger)i];
        item.frame = CGRectMake(i * (self.frame.size.width / [items count]), 0, (self.frame.size.width / [items count]), self.frame.size.height);
        item.backgroundColor = [UIColor clearColor];
        TBMBAutoNilDelegate(FMSegmentedControlItem *, item, delegate, self);
        [item setItemSelected:NO];
        if (i == 0) {
            item.image = item.image ? : [[UIImage imageNamed:@"left_segmented_normal.png"]
                    resizeImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)];
            item.selectedImage = item.selectedImage ? : [[UIImage imageWithFileName:@"left_segmented_selected.png"]
                    resizeImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)];
        } else if (i == [_items count] - 1) {
            item.image = item.image ? : [[UIImage imageWithFileName:@"right_segmented_normal.png"]
                    resizeImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)];
            item.selectedImage = item.selectedImage ? : [[UIImage imageWithFileName:@"right_segmented_selected.png"]
                    resizeImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)];
        } else {
            item.image = item.image ? : [UIImage imageWithFileName:@"segmented_normal.png"];
            item.selectedImage = item.selectedImage ? : [UIImage imageWithFileName:@"segmented_selected.png"];
        }
        [self addSubview:item];
    }
    [self setSelectedIndex:0];
}

- (void)setSegmentChangedAction:(void (^)(FMSegmentedControlItem *))block {
    _segmentChangedActionBlock = block;
}

- (void)setEnable:(BOOL)enable {
    _enable = enable;
    for (FMSegmentedControlItem *item in _items) {
        item.enable = enable;
    }
}

- (void)setSelectedIndex:(NSUInteger)index {
    for (FMSegmentedControlItem *item in _items) {
        [item setItemSelected:NO];
    }
    FMSegmentedControlItem *segmentedControlItem = (FMSegmentedControlItem *)[_items objectAtIndex:index];
    [segmentedControlItem setItemSelected:YES];
}

- (void)selectedSegmentedControlItem:(FMSegmentedControlItem *)segmentedControlItem {
    for (FMSegmentedControlItem *item in _items) {
        [item setItemSelected:NO];
    }

    [segmentedControlItem setItemSelected:YES];

    if (_segmentChangedActionBlock) {
        _segmentChangedActionBlock(segmentedControlItem);
        return;
    }

    if (_delegate && [_delegate respondsToSelector:@selector(selectedSegmentedControl:)]) {
        [_delegate performSelector:@selector(selectedSegmentedControl:) withObject:segmentedControlItem];
    }
}

- (void)drawRect:(CGRect)rect {

}

@end
