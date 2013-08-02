// 
// Created by henson on 7/4/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import "FMCommentReplyDO.h"
#import "NSString+Helper.h"

@implementation FMCommentReplyDO {

}

- (BOOL)hasVoice {
    if (self.voiceUrl && [self.voiceUrl isNotBlank]) {
        return YES;
    }
    return NO;
}

@end