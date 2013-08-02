//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-13 下午6:38.
//


#import "TBIUCommon.h"

@interface TBIURunInCurrent () {
    NSOperationQueue *_currentOperationQueue;
    NSThread *_currentThread;
    dispatch_queue_t _currentQueue;
}
@end

@implementation TBIURunInCurrent

@synthesize currentOperationQueue = _currentOperationQueue;
@synthesize currentThread = _currentThread;
@synthesize currentQueue = _currentQueue;

- (id)init {
    self = [super init];
    if (self) {
        _currentOperationQueue = [NSOperationQueue currentQueue];
        _currentThread = [NSThread currentThread];
        _currentQueue = dispatch_get_current_queue();
    }

    return self;
}


- (void)run:(void (^)())block {
    if (!block) {
        return;
    }
    if (_currentOperationQueue) {
        [_currentOperationQueue addOperationWithBlock:block];
    } else if (_currentQueue) {
        dispatch_async(_currentQueue, block);
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

- (void)run:(void (^)())block inType:(TBIURunType)type {
    [self runInType:type
          withBlock:block];
}

- (void)runInType:(TBIURunType)type withBlock:(void (^)())block {
    if (!block) {
        return;
    }
    switch (type) {
        case TBIU_OPERATION:
            if (_currentOperationQueue) {
                [_currentOperationQueue addOperationWithBlock:block];
                return;
            }
        case TBIU_THREAD:
            if (_currentThread && _currentThread.isExecuting) {
                [self performSelector:@selector(runBlock:)
                             onThread:_currentThread
                           withObject:block
                        waitUntilDone:NO];
            }
            return;
        case TBIU_QUEUE:
            dispatch_async(_currentQueue, block);
            return;
        case TBIU_MAIN:
            dispatch_async(dispatch_get_main_queue(), block);
            return;
        case TBIU_AUTO:
            [self run:block];
            return;
    }
}


- (void)runBlock:(void (^)(void))block {
    if (block) {
        block();
    }
}

@end