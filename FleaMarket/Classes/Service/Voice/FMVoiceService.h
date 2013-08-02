//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-17 上午9:32.
//


#import <Foundation/Foundation.h>
#import <MBMvc/TBMBSimpleSingletonCommand.h>

@class FMVoicePlayer;
@class FMVoiceRecorder;


@interface FMVoiceService : TBMBSimpleSingletonCommand


- (void)createVoicePlayer:(NSString *)url
             onCreateDone:(void (^)(FMVoicePlayer *))done;

- (void)stopPlayVoice;

- (void)createVoiceRecorder:(void (^)(FMVoiceRecorder *))done;

- (void)stopAudioRecorder;
@end