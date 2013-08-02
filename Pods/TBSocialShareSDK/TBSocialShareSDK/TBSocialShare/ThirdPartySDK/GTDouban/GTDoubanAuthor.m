//
//  GTDoubanAuthor.m
//   
//
//  Created by GTL on 12-9-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GTDoubanAuthor.h"

@interface GTDoubanAuthor (Private)

- (void)requestAccessTokenWithAuthorizeCode:(NSString *)code;

@end

@implementation GTDoubanAuthor
@synthesize appKey;
@synthesize appSecret;
@synthesize request;
@synthesize delegate;
@synthesize appRedirectURI;

#pragma mark LifeCircle
- (id)initWithAppKey:(NSString *)theAppKey appSecret:(NSString *)theAppSecret appRedirectURI:(NSString *)theAppRedirectURI{
    self = [super init];
    if (self) {
        self.appKey = theAppKey;
        self.appSecret = theAppSecret;
        self.appRedirectURI = theAppRedirectURI;
    }
    return self;
}

- (void)dealloc {
    [appKey release], appKey = nil;
    [appRedirectURI release]; appRedirectURI = nil;
    [appSecret release], appSecret = nil;
    [request setDelegate:nil];
    [request disconnect];
    [request release], request = nil;
    delegate = nil;
    [super dealloc];
}

#pragma mark PrivateMethods
- (void)requestAccessTokenWithAuthorizeCode:(NSString *)code {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:appKey, @"client_id",
                            appSecret, @"client_secret",
                            @"authorization_code", @"grant_type",
                            self.appRedirectURI, @"redirect_uri",
                            code, @"code", nil];
    [request disconnect];
    
    self.request = [GTDoubanRequest requestWithURL:kGTAccessTokenURL
                                  httpMethod:@"POST"
                                      params:params
                                postDataType:kGTRequestPostDataTypeNormal
                            httpHeaderFields:nil 
                                    delegate:self];
    [request connect];
}


- (void)startAuthorize {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:appKey, @"client_id",
                            @"code", @"response_type",
                            self.appRedirectURI, @"redirect_uri",
                            nil];
    NSString *urlString = [GTDoubanRequest serializeURL:kGTAuthorizeURL
                                           params:params
                                       httpMethod:@"GET"];

    TBSocialShareWebViewController *authorize = [[TBSocialShareWebViewController alloc]
            initWithRedirectURI:self.appRedirectURI url:urlString delegate:self];
    [[UIApplication sharedApplication].keyWindow.rootViewController
            presentViewController:authorize
                         animated:YES
                       completion:nil];
    [authorize release];
}

#pragma mark - GTDoubanLoginViewDelegate Methods
- (void)authorizeWebView:(TBSocialShareWebViewController *)webView didRecieveAuthorizationCode:(NSString *)code {
    // if not canceled
    if (![code isEqualToString:@"access_denied"]) {
        [self requestAccessTokenWithAuthorizeCode:code];
    } else {
        if ([delegate respondsToSelector:@selector(authorize:didCancel:)]) {
            [delegate authorize:self didCancel:YES];
        }
    }
}

- (void)authorizeWebView:(TBSocialShareWebViewController *)webView cancel:(BOOL)cancel {
    if ([delegate respondsToSelector:@selector(authorize:didCancel:)]) {
        [delegate authorize:self didCancel:YES];
    }
}

#pragma mark - GTDoubanRequestDelegate Methods
- (void)request:(GTDoubanRequest *)theRequest didFinishLoadingWithResult:(id)result {
    BOOL success = NO;
    if ([result isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary *)result;
        NSString *token = [dict objectForKey:kGTDoubanAccessToken];
        NSString *userID = [dict objectForKey:kGTDoubanUserID];
        NSInteger seconds = [[dict objectForKey:kGTDoubanExpireTime] intValue];
//        NSString *refresh_token = [dict objectForKey:kGTDoubanRefreshToken];
//        NSLog(@"refresh_token:%@", refresh_token);
        success = token && userID;
        
        if (success && [delegate respondsToSelector:@selector(authorize:didSucceedWithAccessToken:userID:expiresIn:)]) {
            [delegate authorize:self didSucceedWithAccessToken:token userID:userID expiresIn:seconds];
        } else if (!success && [delegate respondsToSelector:@selector(authorize:didFailWithError:)]) {
            NSError *error = [NSError errorWithDomain:nil 
                                                 code:110 
                                             userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@", @"授权失败"] forKey:@"WeiBoAuthorError"]];
            [delegate authorize:self didFailWithError:error];
        }
    }
    
}

- (void)request:(GTDoubanRequest *)theReqest didFailWithError:(NSError *)error {
    if ([delegate respondsToSelector:@selector(authorize:didFailWithError:)]) {
        [delegate authorize:self didFailWithError:error];
    }
}

@end
