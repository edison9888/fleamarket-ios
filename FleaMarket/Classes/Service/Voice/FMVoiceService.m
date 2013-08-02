//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-17 上午9:32.
//


#import <TaobaoRemoteObject/HttpHandler.h>
#import <TaobaoRemoteObject/RemoteEvent.h>
#import <AVFoundation/AVFoundation.h>
#import "FMVoiceService.h"
#import "TBIUCache.h"
#import "FMVoicePlayer.h"
#import "FMVoiceRecorder.h"


@interface FMVoiceService () <TBIUCache>
@end

@implementation FMVoiceService {
@private
    TBIUCache *_voiceCache;
    AVAudioSession *_session;
    FMVoicePlayer *_player;
    FMVoiceRecorder *_recorder;
}

- (id)init {
    self = [super init];
    if (self) {
        _voiceCache = [[TBIUCache alloc]
                                  initWithNamespace:@"Voice"
                                         AndIoQueue:NULL];
        _voiceCache.delegate = self;
        _session = [AVAudioSession sharedInstance];
    }

    return self;
}

- (void)createVoicePlayer:(NSString *)url onCreateDone:(void (^)(FMVoicePlayer *))done {
    [self stopPlayVoice];
    NSString *pUrl = [url copy];
    TBIURunInCurrent *currentContext = [[TBIURunInCurrent alloc] init];
    [_voiceCache dataFromCacheForKey:url
                                done:^(NSData *data, TBIUCacheType cacheType) {
                                    [currentContext run:^{
                                        if (data) {
                                            if (_player.playing) {
                                                return;
                                            }
                                            _player = [[FMVoicePlayer alloc] initWithData:data];
                                            _player.url = pUrl;
                                            if (done) {
                                                done(_player);
                                            }
                                        }
                                    }
                                                 inType:TBIU_QUEUE];

                                }];
}

- (void)stopPlayVoice {
    [_player stop];
}


#pragma mark  - 录音

- (NSString *)_recordFilePath {
    NSString *path = NSTemporaryDirectory();
    if (!path) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        if (paths.count > 0) {
            NSString *documents = [paths objectAtIndex:0];
            path = [documents stringByAppendingPathComponent:@"Voice"];
            NSFileManager *fileManager = [[NSFileManager alloc] init];
            if (![fileManager fileExistsAtPath:path]) {
                [fileManager createDirectoryAtPath:path
                       withIntermediateDirectories:YES
                                        attributes:nil
                                             error:NULL];
            }
        }
    }
    return path;
}

- (void)createVoiceRecorder:(void (^)(FMVoiceRecorder *))done {
    [self stopAudioRecorder];
    if (!self._recordFilePath) {
        FMLOG(@"找不到目录啊目录");
        return;
    }
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyyMMddHHmmss"];
    NSString *fileName = [NSString stringWithFormat:@"FM_%@",
                                                    [dateFormat stringFromDate:[NSDate date]]];
    NSString *path = [[self._recordFilePath stringByAppendingPathComponent:fileName]
                                            stringByAppendingPathExtension:@"wav"];
    NSFileManager *manager = [[NSFileManager alloc] init];
    if ([manager fileExistsAtPath:path]) {
        [manager removeItemAtPath:path
                            error:NULL];
    }

    _recorder = [[FMVoiceRecorder alloc] initWithPath:path];
    if (done) {
        done(_recorder);
    }
}


- (void)stopAudioRecorder {
    if ([_recorder recording])
        [_recorder stop];
}

#pragma mark -各种 Delegate
- (void) cache:(TBIUCache *)cache
getDatawithKey:(NSString *)url
   AndWhenDone:(void (^)(NSData *data))doneBlock {
    RemoteContext *context = [[RemoteContext alloc] init];
    context.info = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [context addSuccessEventListener:^(SuccessRemoteEvent *event) {
        if ([event.oriResponseData isKindOfClass:[NSData class]]) {
            doneBlock(event.oriResponseData);
        } else {
            FMLOG(@"Get Voice Data Failed [%@]", event.oriResponseData);
            doneBlock(nil);
        }

    }];
    [context addFailedEventListener:^(FailedRemoteEvent *event) {
        FMLOG(@"Get Voice Failed [%@]", [event.context errorMessage]);
        doneBlock(nil);
    }];

    [context request];
}

- (void)dealloc {
    _voiceCache.delegate = nil;
}

@end