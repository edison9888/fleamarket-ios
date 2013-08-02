//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-18 下午3:05.
//


#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class FMVoiceRecorder;

typedef void (^FMRecordPowerBlock)(CGFloat averagePower, CGFloat peakPower, FMVoiceRecorder *recorder);

typedef void (^FMRecordFinishBlock)(NSData *data,
        NSString *amrFile,
        NSTimeInterval recordTime,
        FMVoiceRecorder *recorder);

@interface FMVoiceRecorder : NSObject
@property(nonatomic, readonly, strong) AVAudioRecorder *recorder;
@property(nonatomic, readonly, assign) NSTimeInterval recordTime;
@property(nonatomic, copy) FMRecordPowerBlock powerBlock;
@property(nonatomic, copy) FMRecordFinishBlock finishBlock;
@property(nonatomic, strong) AVAudioSession *session;

+ (void)setMaxRecordTime:(NSTimeInterval)time;


- (id)initWithPath:(NSString *)path;

- (void)record;

- (BOOL)recording;

- (void)stop;

- (void)deleteArmFile;
@end