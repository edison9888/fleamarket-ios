//
//  FMRegisterViewController.m
//  FleaMarket
//
//  Created by Henson on 8/21/12.
//  Copyright (c) 2012 taobao.com. All rights reserved.
//

#define KFMRegisterMessageNumber      @"1069099988"

#import <MessageUI/MessageUI.h>
#import "FMRegisterViewController.h"
#import "UIAlertView+BlocksKit.h"
#import "FMWebViewController.h"
#import "FMStyle.h"

@interface FMRegisterViewController () <MFMessageComposeViewControllerDelegate>

@end

@implementation FMRegisterViewController

- (void)initNavigation {
    [self setTitle:@"免费注册"];
    [self setLeftBarButtonTitle:nil
                     buttonType:LeftButtonWithBack
                      iconImage:nil];
}

- (void)loadView {
    [super loadView];

    [self initNavigation];
    self.view.backgroundColor = [FMColor instance].viewControllerBgGrayColor;

    UILabel *messageLabel = [self textLabel];
    messageLabel.text = @"中国大陆用户";
    messageLabel.frame = CGRectMake(10, 64, 300, 20);
    [self.view addSubview:messageLabel];

    UIButton *messageButton = [self textButton];
    [messageButton setTitle:[NSString stringWithFormat:@"编辑短信到%@",
                                                       KFMRegisterMessageNumber]
                   forState:UIControlStateNormal];
    [messageButton setFrame:CGRectMake(10, 90, 300, 56)];
    [messageButton addTarget:self
                      action:@selector(sendMessage:)
            forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:messageButton];

    UILabel *descriptionText = [[UILabel alloc] initWithFrame:CGRectMake(10, 152, 320, 20)];
    descriptionText.text = @"根据短信提示操作，即可成功注册";
    descriptionText.textColor = FMColorWithRed(0x66, 0x66, 0x66);
    descriptionText.font = [UIFont systemFontOfSize:13.f];
    descriptionText.backgroundColor = [UIColor clearColor];
    descriptionText.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:descriptionText];

    UILabel *webLabel = [self textLabel];
    webLabel.text = @"非中国大陆用户";
    webLabel.frame = CGRectMake(10, 190, 300, 20);
    [self.view addSubview:webLabel];

    UIButton *webButton = [self textButton];
    [webButton setTitle:@"网页注册"
               forState:UIControlStateNormal];
    [webButton setFrame:CGRectMake(10, 220, 300, 56)];
    [webButton addTarget:self
                  action:@selector(webRegisterAction)
        forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:webButton];
}

- (UILabel *)textLabel {
    UILabel *indicateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    indicateLabel.font = FMFont(YES, 16.f);
    indicateLabel.textAlignment = NSTextAlignmentLeft;
    indicateLabel.backgroundColor = [UIColor clearColor];
    return indicateLabel;
}

- (UIButton *)textButton {
    UIImage *btnImage = [[UIImage imageWithFileName:@"btn_register_normal.png"]
                                  resizeImageWithCapInsets:UIEdgeInsetsMake(0, 6, 0, 6)];
    UIImage *pressImage = [[UIImage imageWithFileName:@"btn_register_pressed.png"]
                                    resizeImageWithCapInsets:UIEdgeInsetsMake(0, 6, 0, 6)];
    UIButton *messageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [messageButton setBackgroundImage:btnImage
                             forState:UIControlStateNormal];
    [messageButton setBackgroundImage:pressImage
                             forState:UIControlStateSelected];
    [messageButton setTitleColor:[UIColor blackColor]
                        forState:UIControlStateNormal];
    [messageButton setTitleColor:[UIColor whiteColor]
                        forState:UIControlStateHighlighted];
    [messageButton.titleLabel setFont:FMFont(YES, 20)];
    return messageButton;
}

- (void)sendMessage:(id)sender {
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    controller.messageComposeDelegate = self;
    if ([MFMessageComposeViewController canSendText]) {
        controller.body = [NSString stringWithFormat:@"TB"];
        controller.recipients = @[KFMRegisterMessageNumber];
        [self.navigationController presentViewController:controller
                                                animated:YES
                                              completion:nil];
        return;
    }
    UIAlertView *view = [UIAlertView alertViewWithTitle:@""
                                                message:@"亲，您的设备不支持发短信功能"];
    [view setCancelButtonWithTitle:@"确定"
                           handler:NULL];
    [view show];
    return;
}

- (void)webRegisterAction {
    FMWebViewController *webView = [[FMWebViewController alloc] init];
    webView.url = @"http://u.m.taobao.com/reg/new_user.htm";
    webView.webViewType = FMWebViewTypeRequest;
    webView.title = @"免费注册";
    [self.navigationController pushViewController:webView
                                         animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - messageComposeDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
    [controller dismissModalViewControllerAnimated:YES];
    switch (result) {
        case MessageComposeResultCancelled:
            break;
        case MessageComposeResultFailed:
            break;
        case MessageComposeResultSent:
            break;
        default:
            break;
    }
    return;
}

@end
