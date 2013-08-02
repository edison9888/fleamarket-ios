//
// Created by zephyrleaves on 12-8-26.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "RemoteContext.h"


@protocol RemoteHandlerProtocol <NSObject>
@optional
- (BOOL)preProcess:(RemoteContext *)context;

- (void)process:(RemoteContext *)context;


@required
- (BOOL)request:(RemoteContext *)remoteContext;

- (void)cancel:(RemoteContext *)context;


@end