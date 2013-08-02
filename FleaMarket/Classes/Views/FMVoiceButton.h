//
// Created by yuanxiao on 13-6-14.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

typedef enum {
    FMVoiceButtonTypeSmall,
    FMVoiceButtonTypeBig
} FMVoiceButtonType;

@interface FMVoiceButton : UIButton

- (id)initWithFrame:(CGRect)frame withType:(FMVoiceButtonType)buttonType;

@property (nonatomic, copy) NSString *voiceUrl;
@property (nonatomic, strong) NSData *voiceData;

@property (nonatomic) double progress;

@end
