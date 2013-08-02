//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-11-6 上午9:17.
//


#import "FMCustomStatusBar.h"


@implementation FMCustomStatusBar {
    UILabel *_statusMsgLabel;
}

- (void)dealloc {
    _statusMsgLabel = nil;
}


- (id)init {
    self = [super initWithFrame:[UIApplication sharedApplication].statusBarFrame];
    if (self) {
        self.windowLevel = UIWindowLevelStatusBar + 1.0f;
        self.backgroundColor = [UIColor blackColor];
        _statusMsgLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _statusMsgLabel.backgroundColor = [UIColor clearColor];
        _statusMsgLabel.textColor = [UIColor whiteColor];
        _statusMsgLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        _statusMsgLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_statusMsgLabel];
    }
    return self;
}


- (void)showStatusMessage:(NSString *)message {
    self.hidden = NO;
    self.alpha = 1.0f;
    _statusMsgLabel.text = @"";

    CGSize totalSize = self.frame.size;
    self.frame = (CGRect) {self.frame.origin, 0, totalSize.height};

    [UIView animateWithDuration:0.5f
                     animations:^{
                         self.frame = (CGRect) {self.frame.origin, totalSize};
                     }
                     completion:^(BOOL finished) {
                         _statusMsgLabel.text = message;
                     }];
}

- (void)hide {
    self.alpha = 1.0f;

    [UIView animateWithDuration:0.5f
                     animations:^{
                         self.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         _statusMsgLabel.text = @"";
                         self.hidden = YES;
                     }];;
}

+ (void)showStatusMessage:(NSString *)message hideAfter:(NSTimeInterval)time {
    FMCustomStatusBar *bar = [[FMCustomStatusBar alloc] init];
    [bar showStatusMessage:message];
    [bar performSelector:@selector(hide)
              withObject:nil
              afterDelay:time];
}


@end