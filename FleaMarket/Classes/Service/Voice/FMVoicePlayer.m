//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-18 下午3:05.
//


#import <AVFoundation/AVFoundation.h>
#import <iOS_Util/TBIUAmrCodec.h>
#import "FMVoicePlayer.h"

static FMSpeakerType FM_SPEAKER_TYPE = FM_SPEAKER;

#define FM_TIMER_INTERVAL  (0.05)

@interface FMVoicePlayer () <AVAudioPlayerDelegate>
@end

@implementation FMVoicePlayer {
@private
    AVAudioPlayer *_player;
    AVAudioSession *_session;
    FMVoiceProgressBlock _progress;
    FMVoiceFinishBlock _finish;
    NSTimer *_playTimer;
    NSString *_url;
}
@synthesize player = _player;
@synthesize session = _session;

@synthesize progress = _progress;
@synthesize finish = _finish;

@synthesize url = _url;

+ (void)setSpeakerType:(FMSpeakerType)type {
    FM_SPEAKER_TYPE = type;
}


- (id)initWithData:(NSData *)data {
    if ((self = [super init])) {
        _session = [AVAudioSession sharedInstance];
        _player = [[AVAudioPlayer alloc]
                                  initWithData:DecodeAMRToWAVE(data)
                                         error:NULL];
        _player.delegate = self;
    }
    return self;
}

- (void)resetSessionWithRecord {
    NSError *sessionError;
    if (FM_SPEAKER_TYPE == FM_SPEAKER) {
        [_session setCategory:AVAudioSessionCategoryPlayback
                        error:&sessionError];
    } else {
        [_session setCategory:AVAudioSessionCategoryPlayAndRecord
                        error:&sessionError];
    }
    if (_session == nil)
        NSLog(@"Error creating session: %@", [sessionError description]);
    else
        [_session setActive:YES
                      error:nil];
}

- (void)play {
    [self resetSessionWithRecord];
    [_player play];
    [self handleProximityMonitoring:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_playTimer invalidate];
        _playTimer = [NSTimer scheduledTimerWithTimeInterval:FM_TIMER_INTERVAL
                                                      target:self
                                                    selector:@selector(playTimerUpdate)
                                                    userInfo:nil
                                                     repeats:YES];
        NSRunLoop *main = [NSRunLoop currentRunLoop];
        [main addTimer:_playTimer
               forMode:NSRunLoopCommonModes];
    }
    );
}

- (void)playTimerUpdate {
    if (_progress) {
        _progress(_player.currentTime, _player.duration, self, _url);
    }
}

#pragma mark - 监听听筒or扬声器
- (void)handleProximityMonitoring:(BOOL)state {
    [[UIDevice currentDevice] setProximityMonitoringEnabled:state]; //建议在播放之前设置yes，播放结束设置NO，这个功能是开启红外感应

    if (state)//添加监听
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sensorStateChange:)
                                                     name:UIDeviceProximityStateDidChangeNotification
                                                   object:nil];
    else//移除监听
        [[NSNotificationCenter defaultCenter]
                               removeObserver:self
                                         name:UIDeviceProximityStateDidChangeNotification
                                       object:nil];
}


//处理监听触发事件
- (void)sensorStateChange:(NSNotificationCenter *)notification; {

    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if ([[UIDevice currentDevice] proximityState] == YES) {
        FMLOG(@"Device is close to user");
        [_session setCategory:AVAudioSessionCategoryPlayAndRecord
                        error:nil];
    }
    else {
        FMLOG(@"Device is not close to user");
        if (FM_SPEAKER_TYPE == FM_HEADPHONE) {
            [_session setCategory:AVAudioSessionCategoryPlayAndRecord
                            error:nil];
        } else {
            [_session setCategory:AVAudioSessionCategoryPlayback
                            error:nil];
        }
    }
}

- (BOOL)playing {
    return _player.playing;
}


- (void)stop {
    [self handleProximityMonitoring:NO];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_finish) {
            _finish(self, _url);
        }
        _finish = nil;
        _progress = nil;
    }
    );
    [_player stop];
    NSTimer *timer = _playTimer;
    dispatch_async(dispatch_get_main_queue(), ^{
        [timer invalidate];
    }
    );
}


- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self finishPlay];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    [self finishPlay];
}

- (void)finishPlay {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stop];
    }
    );
}


- (void)dealloc {
    _player.delegate = nil;
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    [[NSNotificationCenter defaultCenter]
                           removeObserver:self
                                     name:UIDeviceProximityStateDidChangeNotification
                                   object:nil];
    NSTimer *timer = _playTimer;
    dispatch_async(dispatch_get_main_queue(), ^{
        [timer invalidate];
    }
    );
}


@end