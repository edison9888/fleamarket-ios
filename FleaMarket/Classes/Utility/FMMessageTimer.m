//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-10-30 上午9:04.
//


#import "FMConstants.h"
#import "FMPushService.h"


@implementation FMMessageTimer {
@private
    NSTimer *_timer;
    NSTimer *_reUpdateTimer;

}
+ (FMMessageTimer *)instance {
    static FMMessageTimer *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }

    return _instance;
}

- (void)initFMMessageTimer {
    [[NSNotificationCenter defaultCenter]
                           addObserver:self
                              selector:@selector(switchLoginStatus:)
                                  name:FM_UPDATE_DEVICE_DONE object:nil];
    [[NSNotificationCenter defaultCenter]
                           addObserver:self
                              selector:@selector(stopGetMessageTimer:)
                                  name:FM_UPDATE_DEVICE_FAILED object:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        _reUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:(30 * 60) target:self
                                                        selector:@selector(reUpdateTimer:)
                                                        userInfo:nil repeats:YES];
    }
    );
}

- (void)reUpdateTimer:(NSTimer *)timer {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_timer == nil && [FMConstants sharedInstance].isLogin) {
            [FMPushService updateDevice];
        }
    }
    );
}

- (void)switchLoginStatus:(id)notification {
    if ([FMConstants sharedInstance].isLogin) {
        [self startGetMessageTimer:notification];
    } else {
        [self stopGetMessageTimer:notification];
    }
}

- (void)stopGetMessageTimer:(id)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_timer) {
            [_timer invalidate];
            _timer = nil;
        }
    }
    );
}

- (void)startGetMessageTimer:(id)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_timer == nil || !_timer.isValid) {
            _timer = [NSTimer scheduledTimerWithTimeInterval:MESSAGE_LOOP_TIME
                                                      target:self
                                                    selector:@selector(getMessage:)
                                                    userInfo:nil
                                                     repeats:YES];
            [_timer fire];
        }
    }
    );
}

- (void)fire {
    FMLOG(@"%@", @"FMMessageTimer fire!");
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_timer) {
            [_timer fire];
        }
    }
    );
}

- (void)getMessage:(NSTimer *)timer {
    FMLOG(@"start getMessage at [%@]", [[NSDate date] descriptionWithLocale:[NSLocale currentLocale]]);
    TBMBGlobalSendNotificationForSEL(@selector($$getNewMessage:));

    TBMBDefaultNotification *notification = [[TBMBDefaultNotification alloc] initWithSEL:@selector($$getReceiverCommentMessage:)];
    notification.delay=5;
    TBMBGlobalSendTBMBNotification(notification);
}


@end