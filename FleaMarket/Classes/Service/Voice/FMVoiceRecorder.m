//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-18 下午3:05.
//


#import <AVFoundation/AVFoundation.h>
#import <iOS_Util/TBIUAmrCodec.h>
#import "FMVoiceRecorder.h"

static NSTimeInterval FM_MAX_RECORD_TIME = 60.0f;

#define FMSampleRate    8000.0
#define FMChannelsKey   1
#define FMBitDepthKey   16

#define FM_TIMER_INTERVAL  (0.05)


@interface FMVoiceRecorder () <AVAudioRecorderDelegate>
@end

@implementation FMVoiceRecorder {
@private
    AVAudioRecorder *_recorder;

    FMRecordPowerBlock _powerBlock;
    FMRecordFinishBlock _finishBlock;
    AVAudioSession *_session;
    NSTimer *_recordTimer;
    NSTimeInterval _startTime;
    NSTimeInterval _recorderTime;

    NSString *_armFile;
}
@synthesize recorder = _recorder;

@synthesize powerBlock = _powerBlock;
@synthesize finishBlock = _finishBlock;

@synthesize session = _session;

+ (void)setMaxRecordTime:(NSTimeInterval)time {
    FM_MAX_RECORD_TIME = time;
}

- (id)initWithPath:(NSString *)path {
    if ((self = [super init])) {
        _recorderTime = 0;
        _session = [AVAudioSession sharedInstance];
        _recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL URLWithString:path]
                                                settings:[self _recordSetting]
                                                   error:nil];
        _recorder.delegate = self;
        _recorder.meteringEnabled = YES;
    }
    return self;
}

- (void)record {
    if (![_recorder prepareToRecord]) {
        FMLOG(@"prepareToRecord Failed");
        if (_finishBlock) {
            _finishBlock(nil, nil, 0, self);
            _finishBlock = nil;
            _powerBlock = nil;
        }
        return;
    }
    [self resetSessionWithRecord];
    _startTime = [[NSDate date] timeIntervalSince1970];
    [_recorder recordForDuration:FM_MAX_RECORD_TIME];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_recordTimer invalidate];
        _recordTimer = [NSTimer scheduledTimerWithTimeInterval:FM_TIMER_INTERVAL
                                                        target:self
                                                      selector:@selector(recordPowerUpdate)
                                                      userInfo:nil
                                                       repeats:YES];
        [_recordTimer fire];
    }
    );
}

- (BOOL)recording {
    return [_recorder isRecording];
}

- (NSTimeInterval)recordTime {
    return _recorderTime;
}


- (void)stop {
    [_recorder stop];
    FMLOG(@"stop %@", _recorder.url);
    NSTimer *timer = _recordTimer;
    dispatch_async(dispatch_get_main_queue(), ^{
        [timer invalidate];
    }
    );
}

- (void)deleteArmFile {
    if (_armFile) {
        NSFileManager *manager = [[NSFileManager alloc] init];
        [manager removeItemAtPath:_armFile
                            error:NULL];
        _armFile = nil;
    }
}


- (void)recordPowerUpdate {
    //刷新音量数据
    [_recorder updateMeters];
//获取音量的平均值
    CGFloat averagePower = [_recorder averagePowerForChannel:0];
//获取音量的峰值
    CGFloat peakPower = [_recorder peakPowerForChannel:0];
    if (_powerBlock) {
        _powerBlock(averagePower, peakPower, self);
    }
}

- (void)resetSessionWithRecord {
    NSError *sessionError;
    [_session setCategory:AVAudioSessionCategoryPlayAndRecord
                    error:&sessionError];

    if (_session == nil)
        NSLog(@"Error creating session: %@", [sessionError description]);
    else
        [_session setActive:YES
                      error:nil];
}


- (NSDictionary *)_recordSetting {
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                                      [NSNumber numberWithFloat:FMSampleRate], AVSampleRateKey,
                                                      [NSNumber numberWithInt:FMChannelsKey], AVNumberOfChannelsKey,
                                                      [NSNumber numberWithInt:FMBitDepthKey], AVLinearPCMBitDepthKey,
                                                      [NSNumber numberWithInt:AVAudioQualityMin], AVEncoderAudioQualityKey,
                                                      nil];

}


- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    _recorderTime = [[NSDate date] timeIntervalSince1970] - _startTime;
    NSURL *url = recorder.url;
    FMLOG(@"record Done:%@", url);
    NSData *amr = nil;
    if (flag && url) {
        NSString *wavFile = [url absoluteString];
        _armFile = [[url absoluteString] stringByAppendingPathExtension:@"amr"];
        FMLOG(@"start encoding");
        EncodeWAVEFileToAMRFile([wavFile cStringUsingEncoding:NSUTF8StringEncoding],
                [_armFile cStringUsingEncoding:NSUTF8StringEncoding], FMChannelsKey, FMBitDepthKey
        );
        amr = [NSData dataWithContentsOfFile:_armFile];
        FMLOG(@"end encoding:[%d]", [amr length]);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            NSFileManager *manager = [[NSFileManager alloc] init];
            NSString *strUrl = [recorder.url absoluteString];
            if ([manager fileExistsAtPath:strUrl]) {
                if (![manager removeItemAtPath:strUrl error:NULL]) {
                    FMLOG(@"deleteRecording Failed [%@]", recorder.url);
                }
            }
        }
        );
    }

    if (_finishBlock) {
        if (_armFile && amr) {
            _finishBlock(amr, _armFile, _recorderTime, self);
        } else {
            _finishBlock(nil, nil, 0, self);
        }
        _finishBlock = nil;
        _powerBlock = nil;
    }
    NSTimer *timer = _recordTimer;
    dispatch_async(dispatch_get_main_queue(), ^{
        [timer invalidate];
    }
    );
}

- (void)dealloc {
    _recorder.delegate = nil;
    NSTimer *timer = _recordTimer;
    dispatch_async(dispatch_get_main_queue(), ^{
        [timer invalidate];
    }
    );
}

@end