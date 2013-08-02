//
// Created by yuanxiao on 13-6-6.
// Copyright (c) 2013 Taobao. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "TBSocialShareWebViewController.h"
#import "SinaWeiboConstants.h"
#import "SinaWeiboRequest.h"
#import "TBSocialShareConfig.h"

#define kTBWebTitleHeight  44

@implementation TBSocialShareWebViewController {
@private
    __weak id<TBAuthorizeDelegate> _delegate;
    UIWebView *_webView;
    UIView *_containerView;
    UIActivityIndicatorView *_indicatorView;
    NSString *_redirectURI;
    NSString *_url;
    NSDictionary *_authParams;

    TBAuthorizeType _authorizeType;
}

@synthesize redirectURI = _redirectURI;

- (id)initWithRedirectURI:(NSString *)theRedirectURI
                      url:(NSString *)url
                 delegate:(id<TBAuthorizeDelegate>)delegate {
    if (self = [super init])
    {
        _redirectURI = theRedirectURI;
        _delegate = delegate;
        _url = url;
        _authorizeType = TBAuthorizeTypeDouban;

        [self.view setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (id)initWithAuthParams:(NSDictionary *)params
                delegate:(id<TBAuthorizeDelegate>)delegate
{
    if ((self = [self init]))
    {
        _delegate = delegate;
        _authParams = [params copy];
        _redirectURI = [_authParams objectForKey:@"redirect_uri"];
        _authorizeType = TBAuthorizeTypeSina;
    }
    return self;
}

- (void)initTitleBar {
    UIImage *titleBG = [UIImage imageNamed:@"header_bg.png"];
    UIImageView *titleView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, TB_SOCIAL_SCREEN_WIDTH, kTBWebTitleHeight + 3)];
    titleView.userInteractionEnabled = YES;
    titleView.backgroundColor = [UIColor clearColor];
    titleView.image = titleBG;
    [self.view addSubview:titleView];

    UIImage *image = [UIImage imageNamed:@"header_back_icon.png"];
    UIButton *backButton = [[UIButton alloc] init];
    backButton.frame = CGRectMake(0, 7, 45, 30);
    backButton.backgroundColor = [UIColor clearColor];
    [backButton setImage:image forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:backButton];

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, TB_SOCIAL_SCREEN_WIDTH - 200, kTBWebTitleHeight + 3)];
    titleLabel.text = _authorizeType == TBAuthorizeTypeSina ? @"新浪认证" : @"豆瓣认证";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    [titleView addSubview:titleLabel];
}

- (void)loadView {
    [super loadView];
    CGFloat y = TB_SOCIAL_SCREEN_HEIGHT - 20 - kTBWebTitleHeight;
    _containerView = [[UIView alloc] initWithFrame:CGRectMake(0, kTBWebTitleHeight, TB_SOCIAL_SCREEN_WIDTH, y)];
    [self.view addSubview:_containerView];

    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, TB_SOCIAL_SCREEN_WIDTH, y)];
    [_webView setDelegate:self];
    [_containerView addSubview:_webView];

    _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_indicatorView setCenter:CGPointMake(TB_SOCIAL_SCREEN_WIDTH / 2, y / 2)];
    [_containerView addSubview:_indicatorView];

    [self initTitleBar];

    if (_authorizeType == TBAuthorizeTypeSina) {
        NSString *authPagePath = [SinaWeiboRequest serializeURL:kSinaWeiboWebAuthURL
                                                         params:_authParams httpMethod:@"GET"];
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:authPagePath]]];
    } else if (_authorizeType == TBAuthorizeTypeDouban) {
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_url]]];
    }
}

- (void)dealloc {
    _webView = nil;
    _webView.delegate = nil;
    _redirectURI = nil;
    _url = nil;
}

- (void)dismiss:(id)sender {
    [_delegate authorizeWebView:self cancel:YES];
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UIWebViewDelegate Methods
- (void)webViewDidStartLoad:(UIWebView *)aWebView {
    [_indicatorView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
    [_indicatorView stopAnimating];
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error {
    [_indicatorView stopAnimating];
}

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (_authorizeType == TBAuthorizeTypeSina) {
        return [self receiveSina:request];
    } else if (_authorizeType == TBAuthorizeTypeDouban) {
        return [self receiveDouban:request];
    }
    return YES;
}

- (BOOL)receiveDouban:(NSURLRequest *)request  {
    NSURL *urlObj =  [request URL];
    NSString *url = [urlObj absoluteString];
    if ([url hasPrefix:self.redirectURI]) {
        NSString* urlString = [urlObj query];
        NSRange range = [urlString rangeOfString:@"code="];
        if (range.location != NSNotFound) {
            NSString *code = [urlString substringFromIndex:range.location + range.length];
            if ([_delegate respondsToSelector:@selector(authorizeWebView:didRecieveAuthorizationCode:)]) {
                [_delegate authorizeWebView:self didRecieveAuthorizationCode:code];
            }
            [self dismissModalViewControllerAnimated:YES];
        }
        return NO;
    }
    return YES;
}

- (BOOL)receiveSina:(NSURLRequest *)request {
    NSString *url = request.URL.absoluteString;
    NSString *siteRedirectURI = [NSString stringWithFormat:@"%@%@", kSinaWeiboSDKOAuth2APIDomain, _redirectURI];

    if ([url hasPrefix:_redirectURI] || [url hasPrefix:siteRedirectURI])
    {
        NSString *error_code = [SinaWeiboRequest getParamValueFromUrl:url paramName:@"error_code"];

        if (error_code)
        {
            NSString *error = [SinaWeiboRequest getParamValueFromUrl:url paramName:@"error"];
            NSString *error_uri = [SinaWeiboRequest getParamValueFromUrl:url paramName:@"error_uri"];
            NSString *error_description = [SinaWeiboRequest getParamValueFromUrl:url paramName:@"error_description"];

            NSDictionary *errorInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                    error, @"error",
                    error_uri, @"error_uri",
                    error_code, @"error_code",
                    error_description, @"error_description", nil];

            if ([_delegate respondsToSelector:@selector(authorizeView:didFailWithErrorInfo:)]) {
                [_delegate authorizeView:self didFailWithErrorInfo:errorInfo];
            }
        }
        else
        {
            NSString *code = [SinaWeiboRequest getParamValueFromUrl:url paramName:@"code"];
            if (code && [_delegate respondsToSelector:@selector(authorizeWebView:didRecieveAuthorizationCode:)])
            {
                [_delegate authorizeWebView:self didRecieveAuthorizationCode:code];
            }
        }
        [self dismissModalViewControllerAnimated:YES];
        return NO;
    }
    return YES;
}
@end