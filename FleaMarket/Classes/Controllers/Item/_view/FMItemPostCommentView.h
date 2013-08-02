// 
// Created by henson on 6/19/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>
#import <HPGrowingTextView/HPGrowingTextView.h>

@interface FMItemPostCommentView : UIImageView <UITextFieldDelegate, HPGrowingTextViewDelegate>

@property(nonatomic, strong, readonly) UIButton *backButton;
@property(nonatomic, weak) id delegate;

@property(nonatomic, strong) HPGrowingTextView *commentTextField;

- (void)setTouchEndAction:(void (^)(void))block;

- (void)setTouchDragEnterAction:(void (^)(void))block;

- (void)setTouchDragExitAction:(void (^)(void))block;

- (void)setTouchDownAction:(void (^)(void))block;

- (void)setTouchUpAction:(void (^)(void))block;

- (void)setTextViewPlaceholder:(NSString *)placeholder;

- (void)showTextView;

- (void)switchVoice;

@end