//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-18 下午3:05.
//


#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class FMVoicePlayer;

typedef void (^FMVoiceProgressBlock)(NSTimeInterval currentTime, NSTimeInterval duration,
        FMVoicePlayer *player, NSString *url);

typedef void (^FMVoiceFinishBlock)(FMVoicePlayer *player, NSString *url);

typedef enum {
    FM_SPEAKER,
    FM_HEADPHONE
} FMSpeakerType;

@interface FMVoicePlayer : NSObject
@property(nonatomic, strong, readonly) AVAudioPlayer *player;
@property(nonatomic, strong) AVAudioSession *session;
@property(nonatomic, copy) FMVoiceProgressBlock progress;
@property(nonatomic, copy) FMVoiceFinishBlock finish;
@property(nonatomic, copy) NSString *url;

+ (void)setSpeakerType:(FMSpeakerType)type;

- (id)initWithData:(NSData *)data;

- (void)play;

- (BOOL)playing;

- (void)stop;

@end