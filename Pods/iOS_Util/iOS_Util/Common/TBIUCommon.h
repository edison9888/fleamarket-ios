//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-13 下午6:38.
//


#import <Foundation/Foundation.h>

#if  __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0
#define TBIUWeak __weak
#define TBIUPropertyWeak weak
#else

#define TBIUWeak __unsafe_unretained
#define TBIUPropertyWeak assign
#endif
//


typedef enum {
    TBIU_OPERATION,
    TBIU_THREAD,
    TBIU_QUEUE,
    TBIU_MAIN,
    TBIU_AUTO
} TBIURunType;


//回到当前状态执行代码
@interface TBIURunInCurrent : NSObject

@property(nonatomic, strong) NSOperationQueue *currentOperationQueue;
@property(nonatomic, strong) NSThread *currentThread;
@property(nonatomic) dispatch_queue_t currentQueue;

- (void)run:(void (^)())block;

- (void)run:(void (^)())block inType:(TBIURunType)type;

- (void)runInType:(TBIURunType)type withBlock:(void (^)())block;
@end