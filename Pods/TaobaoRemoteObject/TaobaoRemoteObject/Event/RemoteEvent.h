//
// Created by zephyrleaves on 12-8-26.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "EventDefine.h"
#import "RemoteContext.h"

@interface BaseRemoteEvent : NSObject
@property(strong, nonatomic) RemoteContext *context;
@end


@interface SuccessRemoteEvent : BaseRemoteEvent <RemoteEventProtocol> {
}
@property(strong, nonatomic) id oriResponseData;
@property(strong, nonatomic) id responseData;
@property(strong, readonly, nonatomic) NSMutableDictionary *extra;
@property(assign, nonatomic) BOOL isSidInvalid;
@property(assign, nonatomic) BOOL isCache;
@end


@interface FailedRemoteEvent : BaseRemoteEvent <RemoteEventProtocol> {
}
@property(strong, readonly, nonatomic) NSMutableDictionary *extra;
@end

@interface CancelRemoteEvent : BaseRemoteEvent <RemoteEventProtocol> {
}
@end

@interface ProgressRemoteEvent : BaseRemoteEvent <RemoteEventProtocol> {
}
@property(nonatomic) ProgressEventStatus status;
@property(nonatomic) NSInteger bytesWritten;
@property(nonatomic) long long int totalBytesWritten;
@property(nonatomic) long long int totalBytesExpectedToWrite;
@property(nonatomic) NSInteger bytesRead;
@property(nonatomic) long long int totalBytesRead;
@property(nonatomic) long long int totalBytesExpectedToRead;
@end