//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-10-17 上午9:19.
//

#ifdef TBRO_DEBUG
#define TBRO_LOG(msg, args...) NSLog(@"[TBRO] " msg, ##args)
#else
#define TBRO_LOG(msg, args...)
#endif

#if  __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0
#define TBROWeak __weak
#define TBROPropertyWeak weak
#else
#define TBROWeak __unsafe_unretained
#define TBROPropertyWeak assign
#endif