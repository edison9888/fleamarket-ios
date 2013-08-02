// 
// Created by henson on 7/16/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

typedef NS_ENUM(NSUInteger, kVoicePowerStatus) {
    kVoicePowerStatusPower,
    kVoicePowerStatusCancel,
};

@interface FMVoicePowerView : UIView

@property(nonatomic, assign) kVoicePowerStatus powerStatus;

- (void)setPower:(float)averagePower peakPower:(float)peakPower;

@end