//
// Created by zephyrleaves on 12-8-26.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "RemoteEvent.h"

@implementation BaseRemoteEvent {
@private
    RemoteContext *_context;
}

@synthesize context = _context;
@end


@implementation SuccessRemoteEvent {
@private
    id _responseData;
    NSMutableDictionary *_extra;
    id _oriResponseData;
    BOOL _isSidInvalid;
    BOOL _isCache;
}
@synthesize responseData = _responseData;
@synthesize extra = _extra;
@synthesize oriResponseData = _oriResponseData;


@synthesize isSidInvalid = _isSidInvalid;

@synthesize isCache = _isCache;

- (id)init {
    self = [super init];
    if (self) {
        _isSidInvalid = NO;
        _isCache = NO;
        _extra = [[NSMutableDictionary alloc] initWithCapacity:2];
    }
    return self;
}


- (RemoteEventType)getType {
    return TBRO_SUCCESS;
}
@end

@implementation FailedRemoteEvent {

@private
    NSMutableDictionary *_extra;
}
@synthesize extra = _extra;

- (id)init {
    self = [super init];
    if (self) {
        _extra = [[NSMutableDictionary alloc] initWithCapacity:2];
    }
    return self;
}


- (RemoteEventType)getType {
    return TBRO_FAILED;
}
@end

@implementation CancelRemoteEvent

- (RemoteEventType)getType {
    return TBRO_CANCEL;
}
@end


@implementation ProgressRemoteEvent {
@private
    ProgressEventStatus _status;
    NSInteger _bytesWritten;
    long long int _totalBytesWritten;
    long long int _totalBytesExpectedToWrite;
    NSInteger _bytesRead;
    long long int _totalBytesRead;
    long long int _totalBytesExpectedToRead;
}
@synthesize status = _status;
@synthesize bytesWritten = _bytesWritten;
@synthesize totalBytesWritten = _totalBytesWritten;
@synthesize totalBytesExpectedToWrite = _totalBytesExpectedToWrite;
@synthesize bytesRead = _bytesRead;
@synthesize totalBytesRead = _totalBytesRead;
@synthesize totalBytesExpectedToRead = _totalBytesExpectedToRead;

- (RemoteEventType)getType {
    return TBRO_PROGRESS;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"ProgressRemoteEvent{status:[%d] UPLOAD(%d,%lld,%lld) DOWNLOAD(%d,%lld,%lld)}",
                                      _status,
                                      _bytesWritten,
                                      _totalBytesWritten,
                                      _totalBytesExpectedToWrite,
                                      _bytesRead,
                                      _totalBytesRead,
                                      _totalBytesExpectedToRead];
}


@end