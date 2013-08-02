//
// Created by yuanxiao on 13-6-6.
// Copyright (c) 2013 Taobao. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

typedef enum {
    TBAuthorizeTypeNone,
    TBAuthorizeTypeSina,
    TBAuthorizeTypeDouban
} TBAuthorizeType;

@class TBSocialShareWebViewController;

@protocol TBAuthorizeDelegate <NSObject>
@optional
- (void)authorizeWebView:(TBSocialShareWebViewController *)webView didRecieveAuthorizationCode:(NSString *)code;
- (void)authorizeWebView:(TBSocialShareWebViewController *)webView cancel:(BOOL)cancel;

- (void)authorizeView:(TBSocialShareWebViewController *)authView didFailWithErrorInfo:(NSDictionary *)errorInfo;

@end

@interface TBSocialShareWebViewController : UIViewController<UIWebViewDelegate> {
}

@property (nonatomic, retain) NSString *redirectURI;

- (id)initWithRedirectURI:(NSString *)theRedirectURI
                      url:(NSString *)url
                 delegate:(id<TBAuthorizeDelegate>)delegate;

- (id)initWithAuthParams:(NSDictionary *)params
                delegate:(id<TBAuthorizeDelegate>)delegate;

@end