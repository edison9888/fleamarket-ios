//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-8-27 下午6:00.
//


#import "BaseHandler.h"

static NSMutableArray *ALL_HANDLER = nil;

static NSMutableDictionary *CONTEXT_MAP = nil;


@implementation BaseHandler {
@private
    TBROMonitorFunction _monitorFunction;
}

@synthesize monitorFunction = _monitorFunction;

- (id)init {
    self = [super init];
    if (self) {
        if (![self isMemberOfClass:[BaseHandler class]]) {
            @synchronized ([BaseHandler class]) {
                if (ALL_HANDLER == nil) {
                    ALL_HANDLER = [[NSMutableArray alloc] initWithCapacity:2];
                }
                [ALL_HANDLER addObject:self];
            }
        }
    }
    return self;
}

- (TBROMonitorFunction)monitorFunction {
    if (_monitorFunction) {
        return _monitorFunction;
    } else {
        return ^(TBROMonitorType type, TBROMonitorState state, NSString *key) {
        };
    }
}


+ (NSArray *)getAllHandler {
    @synchronized ([BaseHandler class]) {
        if (ALL_HANDLER == nil) {
            return [[NSArray alloc] init];
        } else {
            return [NSArray arrayWithArray:ALL_HANDLER];
        }
    }
}

- (void)addContextToMap:(RemoteContext *)remoteContext {
    id key;
    if ((key = remoteContext.key) != nil) {
        @synchronized ([BaseHandler class]) {
            if (CONTEXT_MAP == nil) {
                CONTEXT_MAP = [[NSMutableDictionary alloc] initWithCapacity:2];
            }
            NSMutableArray *array;
            if ((array = [CONTEXT_MAP objectForKey:key]) == nil) {
                array = [[NSMutableArray alloc] initWithCapacity:2];
                [CONTEXT_MAP setObject:array
                                forKey:key];
            }
            remoteContext.internalHandler = self;
            [array addObject:remoteContext];
        }
    }
}

- (void)removeContextFromMap:(RemoteContext *)remoteContext {
    id key;
    if ((key = remoteContext.key) != nil) {
        @synchronized ([BaseHandler class]) {
            NSMutableArray *array;
            if (CONTEXT_MAP != nil && (array = [CONTEXT_MAP objectForKey:key]) != nil) {
                [array removeObject:remoteContext];
                if ([array count] == 0) {
                    [CONTEXT_MAP removeObjectForKey:key];
                }
            }
        }
    }
}

- (void)cancel:(RemoteContext *)context {
    [self removeContextFromMap:context];
}

+ (void)cancelAllByKey:(id)key {
    if (key) {
        @synchronized ([BaseHandler class]) {
            NSMutableArray *array;
            if (CONTEXT_MAP != nil && (array = [CONTEXT_MAP objectForKey:key]) != nil && [array count] > 0) {
                for (RemoteContext *context in array) {
                    [context.internalHandler cancel:context];
                }
            }
        }
    }
}


- (BOOL)request:(RemoteContext *)remoteContext {
    if (remoteContext) {
        if ([self isMemberOfClass:[BaseHandler class]]) {
            [remoteContext addErrorMessage:@"It is BaseHandler"];
            return NO;
        }
        if ([self respondsToSelector:@selector(preProcess:)]) {
            if (![self preProcess:remoteContext]) {
                return NO;
            }
        }
        if ([self respondsToSelector:@selector(process:)]) {
            [self addContextToMap:remoteContext];
            [self process:remoteContext];
        }
        return YES;
    }
    return NO;
}

@end