//
// Created by zephyrleaves on 12-8-26.
//
// To change the template use AppCode | Preferences | File Templates.
//

@class SuccessRemoteEvent;
@class FailedRemoteEvent;
@class ProgressRemoteEvent;
@class CancelRemoteEvent;
#define TBRO_SID_INVALID_NOTIFICATION_NAME @"TBRO_SID_INVALID_NOTIFICATION_NAME"
#define TBRO_SID_INVALID_REMOTE_CONTEXT @"TBRO_SID_INVALID_REMOTE_CONTEXT"

typedef enum {
    TBRO_SUCCESS,
    TBRO_FAILED,
    TBRO_CANCEL,
    TBRO_PROGRESS
} RemoteEventType;

typedef enum {
    TBRO_UPLOAD,
    TBRO_DOWNLOAD
} ProgressEventStatus;

@protocol RemoteEventProtocol <NSObject>
@required
- (RemoteEventType)getType;
@end


typedef void (^EventListener)(id <RemoteEventProtocol> event);

typedef void (^SuccessEventListener)(SuccessRemoteEvent *event);

typedef void (^FailedEventListener)(FailedRemoteEvent *event);

typedef void (^ProgressEventListener)(ProgressRemoteEvent *event);

typedef void (^CancelEventListener)(CancelRemoteEvent *event);

#pragma mark - monitor

typedef enum {
    TBRO_MONITOR_REQUEST,
    TBRO_MONITOR_REQUEST_DONE,
    TBRO_MONITOR_REQUEST_FAILED,
    TBRO_MONITOR_REQUEST_NETWORK_ERROR
} TBROMonitorState;

typedef enum {
    TBRO_MONITOR_CLIENT_API,
    TBRO_MONITOR_MTOP,
    TBRO_MONITOR_TOP
} TBROMonitorType;

typedef void(^TBROMonitorFunction)(TBROMonitorType type, TBROMonitorState state, NSString *key);