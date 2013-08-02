//
//  FMWebViewController.m
//  fleamarket
//
//  Created by  on 11-12-29.
//  Copyright (c) 2011年 Taobao. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>
#import "FMWebViewController.h"

@implementation FMWebViewController {
@private
    FMWebViewType       _webViewType;
    UIWebView           *_webView;
    BOOL                _loaded;
    BOOL                _scaled;
    BOOL                _clearCookie;
    NSString            *_url;
}

@synthesize scaled = _scaled;
@synthesize clearCookie = _clearCookie;
@synthesize webViewType = _webViewType;
@synthesize url = _url;

- (void)loadView {
    [super loadView];
    self.barViewDO.leftButtonShow = YES;
    CGRect rect = self.titleView.frame;

    rect = CGRectMake(0,
            44,
            self.view.frame.size.width,
            self.view.frame.size.height - rect.origin.y - rect.size.height
    );

    _webView = [[UIWebView alloc] initWithFrame:rect];
    _webView.backgroundColor = [UIColor lightGrayColor];
    _webView.dataDetectorTypes = UIDataDetectorTypeNone;
    _webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    _webView.delegate = self;

    ((UIScrollView *) [_webView.subviews objectAtIndex:0]).bounces = NO;
    [self.view addSubview:_webView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_webView.loading || _loaded)
        return;
    if (_clearCookie) {
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
        for (NSHTTPCookie *cookie in cookies) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
    if (_webViewType == FMWebViewTypeRequest) {
        NSURL *nsUrl = [[NSURL alloc] initWithString:_url];
        [_webView loadRequest:[[NSURLRequest alloc] initWithURL:nsUrl]];
    }
    else if (_webViewType == FMWebViewTypeHTML) {
        [_webView loadHTMLString:_url
                         baseURL:[NSURL URLWithString:TAO_PHOTO_REFER]];
    }

    _webView.scalesPageToFit = self.scaled;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_webView stopLoading];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (BOOL)           webView:(UIWebView *)webView1
shouldStartLoadWithRequest:(NSURLRequest *)aRequest
            navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view
                                              animated:YES];
    hud.labelText = @"加载中";
    hud.userInteractionEnabled = NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView1 {
    _loaded = YES;
    [MBProgressHUD hideAllHUDsForView:self.view
                             animated:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [MBProgressHUD hideAllHUDsForView:self.view
                             animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _loaded = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [MBProgressHUD hideHUDForView:self.view
                         animated:YES];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    _loaded = NO;
}

- (void)rightAction:(id)sender {

}

- (void)dealloc {
    _webView.delegate = nil;
    FMLog(@"FMWebviewController dealloc");
}

@end
