// 
// Created by henson on 7/3/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import "FMCommentDO.h"
#import "NSString+Helper.h"

@implementation FMCommentDO {

}

- (BOOL)hasVoice {
    if (self.voiceUrl && [self.voiceUrl isNotBlank]) {
        return YES;
    }
    return NO;
}

@end