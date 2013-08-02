//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-9-12 下午3:09.
//


@class BaseHandler;

@protocol Verifiable <NSObject>
@optional
- (BOOL)validate;
@end


@protocol TBROHasHandler <NSObject>
@required
- (BaseHandler *)requestHandler;
@end