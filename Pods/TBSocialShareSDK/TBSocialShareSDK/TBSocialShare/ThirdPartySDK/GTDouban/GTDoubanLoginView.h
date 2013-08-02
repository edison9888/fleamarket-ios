//
//  GTDoubanLoginView.h
//   
//
//  Created by GTL on 12-9-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GTDoubanHeader.h"

@class GTDoubanLoginView;

@protocol GTDoubanLoginViewDelegate <NSObject>
@optional
- (void)authorizeWebView:(GTDoubanLoginView *)webView didReceiveString:(NSString *)string;
- (void)authorizeWebView:(GTDoubanLoginView *)webView cancel:(BOOL)cancel;

@end

@interface GTDoubanLoginView : UIView <UIWebViewDelegate> {
    id<GTDoubanLoginViewDelegate> delegate;
    UIWebView *webView;
    UIView *containerView;
    UIActivityIndicatorView *indicatorView;
    NSString *redirectURI;
}

@property (nonatomic, assign) id<GTDoubanLoginViewDelegate> delegate;
@property (nonatomic, retain) NSString *redirectURI;

- (id)initWithRedirectURI:(NSString *)theRedirectURI;
- (void)loadBarWithString:(NSString *)aString;
- (void)loadRequestWithURL:(NSURL *)url;
- (void)showLoginView:(BOOL)animated;
- (void)hideLoginView:(BOOL)animated;

@end
