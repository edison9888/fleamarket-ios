// 
// Created by henson on 7/18/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>

@interface FMPostPickerView : UIView

@property(nonatomic, weak) id delegate;
@property(nonatomic, strong, readonly) UIPickerView *pickerView;

- (void)show;

- (void)hide;

@end