// 
// Created by henson on 7/18/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import "FMPostPickerView.h"

@implementation FMPostPickerView {
    UIPickerView *_pickerView;
    UIToolbar *_toolbar;
@private
    __weak id _delegate;
}

@synthesize delegate = _delegate;
@synthesize pickerView = _pickerView;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGRect toolbarRect = {self.bounds.origin, {frame.size.width, 44}};
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:toolbarRect];
        toolbar.barStyle = UIBarStyleBlackTranslucent;
        UIBarButtonItem *spaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                     target:nil
                                                                                     action:nil];
        UIBarButtonItem *confirmButton = [[UIBarButtonItem alloc] initWithTitle:@"完成"
                                                                          style:UIBarButtonItemStyleDone
                                                                         target:self
                                                                         action:@selector(confirmAction)];
        [toolbar setItems:@[spaceButton, confirmButton]];
        [self addSubview:toolbar];
        _toolbar = toolbar;

        CGRect pickerRect = {{0, _toolbar.frame.size.height}, {frame.size.width, frame.size.height -  _toolbar.frame.size.height}};
        UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:pickerRect];
        pickerView.backgroundColor = [UIColor clearColor];
        pickerView.showsSelectionIndicator = YES;
        [self addSubview:pickerView];
        _pickerView = pickerView;
    }

    return self;
}

- (void)show {
    [UIView animateWithDuration:0.2
                     animations:^{
        CGRect frame = self.frame;
        frame.origin.y = FM_SCREEN_HEIGHT - frame.size.height;
        self.frame = frame;
                     } completion:^(BOOL finished) {

    }];
}

- (void)hide {
    [UIView animateWithDuration:0.2
            animations:^{
                CGRect frame = self.frame;
                frame.origin.y = FM_SCREEN_HEIGHT;
                self.frame = frame;
            } completion:^(BOOL finished) {

    }];
}

- (void)confirmAction {
    [self hide];
}

- (void)setDelegate:(id)delegate {
    _delegate = delegate;

    _pickerView.delegate = delegate;
    _pickerView.dataSource = delegate;
}

- (void)dealloc {
    _pickerView.delegate = nil;
    _pickerView.dataSource = nil;
}

@end