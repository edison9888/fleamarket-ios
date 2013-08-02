//
//  GTDouban.m
//   
//
//  Created by admin on 12-9-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GTDouban.h"
#import "SFHFKeychainUtils.h"

#define kDBURLSchemePrefix              @"DB_"

#define kDBKeychainServiceNameSuffix    @"_DouBanServiceName"
#define kDBKeychainUserID               @"DouBanUserID"
#define kDBKeychainAccessToken          @"DouBanAccessToken"
#define kDBKeychainExpireTime           @"DouBanExpireTime"

@interface GTDouban (Private)
- (void)loadRequestWithMethodName:(NSString *)methodName
                       httpMethod:(NSString *)httpMethod
                           params:(NSDictionary *)params
                     postDataType:(GTDoubanRequestPostDataType)postDataType
                 httpHeaderFields:(NSDictionary *)httpHeaderFields;

@end


@implementation GTDouban

@synthesize tag;
@synthesize appKey;
@synthesize appSecret;
@synthesize userID;
@synthesize accessToken;
@synthesize expireTime;
@synthesize redirectURI;
@synthesize isUserExclusive;
@synthesize request;
@synthesize authorize;
@synthesize delegate;

#pragma mark - GTDouban Life Circle
- (id)initWithAppKey:(NSString *)_appKey
           appSecret:(NSString *)_appSecrect
      appRedirectURI:(NSString *)_appRedirectURI
         andDelegate:(id<GTDoubanDelegate>)_delegate {
    self = [super init];
    if (self) {
        self.appKey = _appKey;
        self.appSecret = _appSecrect;
        self.redirectURI = _appRedirectURI;
        self.delegate = _delegate;
        isUserExclusive = NO;
        [self readAuthorizeDataFromKeychain];
    }
    return self;
}

- (void)dealloc {
    [appKey release], appKey = nil;
    [appSecret release], appSecret = nil;
    [userID release], userID = nil;
    [accessToken release], accessToken = nil;
    [redirectURI release], redirectURI = nil;
    [request setDelegate:nil];
    [request disconnect];
    [request release], request = nil;    
    [authorize setDelegate:nil];
    [authorize release], authorize = nil;    
    delegate = nil;
    [super dealloc];
}

#pragma mark - GTDouban Public Methods
#pragma mark Authorization
- (void)logIn {
    if ([self isLoggedIn]) {
        if ([delegate respondsToSelector:@selector(engineAlreadyLoggedIn:)]) {
            [delegate engineAlreadyLoggedIn:self];
        }
        if (isUserExclusive) {
            return;
        }
    }
    
    GTDoubanAuthor *auth = [[GTDoubanAuthor alloc] initWithAppKey:self.appKey
                                                        appSecret:self.appSecret
                                                   appRedirectURI:self.redirectURI];
    [auth setDelegate:self];
    self.authorize = auth;
    [auth release];
    [authorize startAuthorize];
}

- (void)logOut {
    [self deleteAuthorizeDataInKeychain];
    if ([delegate respondsToSelector:@selector(engineDidLogOut:)]) {
        [delegate engineDidLogOut:self];
    }
}

- (BOOL)isLoggedIn {
    return userID && accessToken && (expireTime > 0);
}

- (BOOL)isAuthorizeExpired {
    if ([[NSDate date] timeIntervalSince1970] > expireTime) {
        // force to log out
        [self deleteAuthorizeDataInKeychain];
        return YES;
    }
    return NO;
}

- (void)saveAuthorizeDataToKeychain {
    NSString *serviceName = [self urlSchemeString];
    [SFHFKeychainUtils storeUsername:kDBKeychainUserID
                         andPassword:self.userID
                      forServiceName:serviceName
                      updateExisting:YES
                               error:nil];
    [SFHFKeychainUtils storeUsername:kDBKeychainAccessToken
                         andPassword:self.accessToken
                      forServiceName:serviceName
                      updateExisting:YES
                               error:nil];
    NSString *strExpireTime = [NSString stringWithFormat:@"%f", self.expireTime];
    [SFHFKeychainUtils storeUsername:kDBKeychainExpireTime
                         andPassword:strExpireTime
                      forServiceName:serviceName
                      updateExisting:YES
                               error:nil];
}

- (void)readAuthorizeDataFromKeychain {
    NSString *serviceName = [self urlSchemeString];
    self.userID = [SFHFKeychainUtils getPasswordForUsername:kDBKeychainUserID
                                                andServiceName:serviceName
                                                         error:nil];
    self.accessToken = [SFHFKeychainUtils getPasswordForUsername:kDBKeychainAccessToken
                                                     andServiceName:serviceName
                                                              error:nil];
    NSString *strExpireTime = [SFHFKeychainUtils getPasswordForUsername:kDBKeychainExpireTime
                                                      andServiceName:serviceName
                                                               error:nil];
    self.expireTime = [strExpireTime doubleValue];
}

- (void)deleteAuthorizeDataInKeychain {
    self.userID = nil;
    self.accessToken = nil;
    self.expireTime = 0;

    NSString *serviceName = [self urlSchemeString];
    [SFHFKeychainUtils deleteItemForUsername:kDBKeychainUserID
                              andServiceName:serviceName
                                       error:nil];
    [SFHFKeychainUtils deleteItemForUsername:kDBKeychainAccessToken
                              andServiceName:serviceName
                                       error:nil];
    [SFHFKeychainUtils deleteItemForUsername:kDBKeychainExpireTime
                              andServiceName:serviceName
                                       error:nil];
}

- (NSString *)urlSchemeString {
    return [NSString stringWithFormat:@"%@%@%@",
                                      kDBURLSchemePrefix,
                                      self.appKey,
                                      kDBKeychainServiceNameSuffix];
}

#pragma mark - GTDoubanAuthorDelegate Methods
- (void)authorize:(GTDoubanAuthor *)_authorize didSucceedWithAccessToken:(NSString *)theAccessToken userID:(NSString *)theUserID expiresIn:(NSInteger)seconds {
    self.accessToken = theAccessToken;
    self.userID = theUserID;
    self.expireTime = [[NSDate date] timeIntervalSince1970] + seconds;
    [self saveAuthorizeDataToKeychain];
    if ([delegate respondsToSelector:@selector(engineDidLogIn:)]) {
        [delegate engineDidLogIn:self];
    }
}

- (void)authorize:(GTDoubanAuthor *)_authorize didFailWithError:(NSError *)error {
    if ([delegate respondsToSelector:@selector(engine:didFailToLogInWithError:)]) {
        [delegate engine:self didFailToLogInWithError:error];
    }
}

- (void)authorize:(GTDoubanAuthor *)_authorize didCancel:(BOOL)cancel {
    if ([delegate respondsToSelector:@selector(engine:didCancel:)]) {
        [delegate engine:self didCancel:YES];
    }
}

#pragma mark Request
- (void)loadRequestWithMethodName:(NSString *)methodName
                       httpMethod:(NSString *)httpMethod
                           params:(NSDictionary *)params
                     postDataType:(GTDoubanRequestPostDataType)postDataType
                 httpHeaderFields:(NSDictionary *)httpHeaderFields {
	if (![self isLoggedIn])	{
        if ([delegate respondsToSelector:@selector(engineNotAuthorized:)]) {
            [delegate engineNotAuthorized:self];
        }
        return;
	}
    if ([self isAuthorizeExpired]) {
        if ([delegate respondsToSelector:@selector(engineAuthorizeExpired:)]) {
            [delegate engineAuthorizeExpired:self];
        }
        return;
    }
    [request disconnect];
    self.request = [GTDoubanRequest requestWithAccessToken:accessToken
                                                 url:[NSString stringWithFormat:@"%@%@", kGTSDKAPIDomain, methodName]
                                          httpMethod:httpMethod
                                              params:params
                                        postDataType:postDataType
                                    httpHeaderFields:httpHeaderFields
                                            delegate:self];
	[request connect];
}

#pragma mark API
- (void)sendWeiBoWithText:(NSString *)text {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   appKey, @"source",
                                   text, @"text",
                                   nil];
    [self loadRequestWithMethodName:@"shuo/v2/statuses/"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kGTRequestPostDataTypeNormal
                   httpHeaderFields:nil];
}

- (void)sendWeiBoWithText:(NSString *)text imageData:(NSData *)imageData {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   appKey, @"source",
                                   imageData, @"image",
                                   text, @"text",
                                   nil];
    [self loadRequestWithMethodName:@"shuo/v2/statuses/"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kGTRequestPostDataTypeMultipart
                   httpHeaderFields:nil];
}

- (void)sendWeiBoWithParams:(NSDictionary *)params {
    if ([params objectForKey:@"image"]) {
        [self loadRequestWithMethodName:@"shuo/v2/statuses/"
                             httpMethod:@"POST"
                                 params:params
                           postDataType:kGTRequestPostDataTypeMultipart
                       httpHeaderFields:nil];
    } else {
        [self loadRequestWithMethodName:@"shuo/v2/statuses/"
                             httpMethod:@"POST"
                                 params:params
                           postDataType:kGTRequestPostDataTypeNormal
                       httpHeaderFields:nil];
    }
}

- (void)getFriendShips {
    NSString *resquetString = [NSString stringWithFormat:@"shuo/v2/users/%@/following", userID];
    [self loadRequestWithMethodName:resquetString
                         httpMethod:@"GET"
                             params:nil
                       postDataType:kGTRequestPostDataTypeNone
                   httpHeaderFields:nil];
}

// 测试没成功
- (void)createFriendWithUserId:(NSString *)_userId {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   appKey, @"source",
                                   _userId, @"user_id",
                                   nil];
    [self loadRequestWithMethodName:@"shuo/v2/friendships/create"
                         httpMethod:@"POST"
                             params:params
                       postDataType:kGTRequestPostDataTypeNormal
                   httpHeaderFields:nil];
}

- (void)getUserInfo {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:self.userID, @"uid", nil];
    [self loadRequestWithMethodName:@"v2/user/~me"
                         httpMethod:@"GET"
                             params:params
                       postDataType:kGTRequestPostDataTypeNone
                   httpHeaderFields:nil];
}

#pragma mark - GTDoubanRequestDelegate Methods
- (void)request:(GTDoubanRequest *)request didFinishLoadingWithResult:(id)result {
    if ([delegate respondsToSelector:@selector(engine:requestDidSucceedWithResult:)]) {
        [delegate engine:self requestDidSucceedWithResult:result];
    }
}

- (void)request:(GTDoubanRequest *)request didFailWithError:(NSError *)error {
    if ([delegate respondsToSelector:@selector(engine:requestDidFailWithError:)]) {
        [delegate engine:self requestDidFailWithError:error];
    }
}

@end
