//
//  FMLoginViewController.m
//  FleaMarket
//
//  Created by taobao sts on 12-7-30.
//  Copyright (c) 2012年 taobao.com. All rights reserved.
//


#import <MBMvc/TBMBDefaultRootViewController+TBMBProxy.h>
#import <Reachability/Reachability.h>
#import "FMLoginViewController.h"
#import "UIImageView+WebCache.h"
#import "FMApplication.h"
#import "FMUser.h"
#import "TTTAttributedLabel.h"
#import "MBProgressHUD.h"
#import "FMRegisterViewController.h"
#import "UIAlertView+BlocksKit.h"
#import "FMLoginService.h"
#import "TBMBSimpleStaticCommand+TBMBProxy.h"
#import "TBRONSStringUtil.h"
#import "FMStyle.h"
#import "FMCommon.h"

@interface FMLoginViewController () <UITableViewDataSource, UITableViewDelegate,
        UITextFieldDelegate, TTTAttributedLabelDelegate> {
    UIButton *_confirmButton;
    UILabel *_registerLabel;
    UIView *_line;
}

@end

@implementation FMLoginViewController {
@private
    UITableView *_tableView;
    UITextField *_usernameTextField;
    UITextField *_passwordTextField;

    NSString *_username;
    NSString *_password;

    UIImageView *_checkCodeImageView;
    UITextField *_checkCodeTextField;
    NSString *_checkCodeId;
    NSString *_checkCodeURL;

    FM_LOGIN_CALLBACK _loginCallback;
}

@synthesize loginCallback = _loginCallback;

- (id)init {
    self = [super init];
    if (self) {
        _checkCodeId = @"";
        _username = @"";
        _password = @"";
    }
    return self;
}

- (void)initHeaderBar {
    [self setLeftBarButtonTitle:nil
                     buttonType:LeftButtonWithIcon
                      iconImage:[UIImage imageWithFileName:@"btn_login_close.png"]];
    self.title = @"淘宝二手";

    UIImage *headerLogoImage = [UIImage imageWithFileName:@"header_tab_logo.png"];
    UIImageView *headerLogo = [[UIImageView alloc] initWithImage:headerLogoImage];
    CGRect logoRect = {{(FM_SCREEN_WIDTH - headerLogoImage.size.width) / 2.f, (kNavigationBarHeight - headerLogoImage
            .size.height) / 2.f}, headerLogoImage.size};
    headerLogo.frame = logoRect;
    headerLogo.backgroundColor = [UIColor clearColor];
    [self.titleView addSubview:headerLogo];
}

- (void)loadView {
    [super loadView];
    [self initHeaderBar];

    self.view.backgroundColor = [UIColor clearColor];
    _tableView = [[UITableView alloc]
                               initWithFrame:CGRectMake(0, 44, 320, FM_SCREEN_HEIGHT - 20 - 44)
                                       style:UITableViewStyleGrouped];
    _tableView.bounces = NO;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [FMColor instance].viewControllerBgGrayColor;
    _tableView.backgroundView = nil;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];

    _confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 155, 300, 37)];
    [_confirmButton setBackgroundImage:[UIImage imageWithFileName:@"btn_confirm_login.png"]
                      forState:UIControlStateNormal];
    [_confirmButton setTitle:@"登录" forState:UIControlStateNormal];
    [_confirmButton addTarget:self action:@selector(rightAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_confirmButton];

    _registerLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 200, 130, 20)];
    _registerLabel.backgroundColor = [UIColor clearColor];
    _registerLabel.text = @"没有账号？免费注册";
    _registerLabel.textColor = FMColorWithRed(0x66, 0x66, 0x66);
    _registerLabel.font = FMFont(NO, 14.0f);
    _registerLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *registerTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(touchRegister)];
    [_registerLabel addGestureRecognizer:registerTap];
    [self.view addSubview:_registerLabel];

    _line = [[UIView alloc] initWithFrame:CGRectMake(89, 220, 57, 1)];
    _line.backgroundColor = FMColorWithRed(186, 186, 182);
    [self.view addSubview:_line];
}


- (void)touchRegister {
    FMRegisterViewController *registerViewController = [[FMRegisterViewController alloc] init];
    registerViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:registerViewController
                                         animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)releaseViews {
    [super releaseViews];
    _tableView = nil;
    _registerLabel = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == 202) {
        [_passwordTextField becomeFirstResponder];
        return YES;
    }
    [self loginAction];
    return YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (_loginCallback) {
        _loginCallback([FMApplication instance].loginUser.isLogin);
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)leftAction:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)rightAction:(id)sender {
    [self loginAction];
}

- (void)loginAction {
    if ([_usernameTextField.text length] < 1 || [_passwordTextField.text length] < 1) {
        UIAlertView *alertView = [UIAlertView alertViewWithTitle:@""
                                                         message:@"请输入用户名或密码"];
        [alertView setCancelButtonWithTitle:@"确认"
                                    handler:NULL];
        [alertView show];
        return;
    }
    NSString *checkCode = nil;
    NSString *checkCodeId = nil;
    if (_checkCodeTextField.hidden == NO && [_checkCodeTextField.text length] > 0) {
        checkCode = _checkCodeTextField.text;
        checkCodeId = _checkCodeId;
    }

    if (![self isReachable]) {
        [FMCommon alert:@"" message:@"亲，无网络连接，请检查网络"];
        return;
    }

    NSArray *array = [MBProgressHUD allHUDsForView:[self keyboardKeyWindow]];
    for (id hudViews in array) {
        [hudViews hide:NO];
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[self keyboardKeyWindow]
                                              animated:YES];
    hud.userInteractionEnabled = NO;
    hud.labelText = @"登录中...";

    id proxy = self.proxyObject;
    [[FMLoginService proxyObject]
                     loginWithUserName:_usernameTextField.text
                           AndPassword:_passwordTextField.text
                        AndCheckCodeId:checkCodeId
                          AndCheckCode:checkCode
                         loginResponse:^(FMLoginResponse *loginResponse) {
                             [proxy loginDone:loginResponse];
                         }];
}

- (BOOL)isReachable {
    Reachability *reachability = [Reachability reachabilityWithHostname: @"http://www.taobao.com"];
    return [reachability isReachable];
}

- (void)loginDone:(FMLoginResponse *)loginResponse {
    if (loginResponse.isSuccess) {
        [self dismissModalViewControllerAnimated:NO];
        [MBProgressHUD hideHUDForView:[self keyboardKeyWindow]
                             animated:YES];
    } else {
        [MBProgressHUD hideHUDForView:[self keyboardKeyWindow]
                             animated:YES];
        if (loginResponse.needCheckCode) {
            _checkCodeId = loginResponse.checkCodeId;
            _checkCodeURL = loginResponse.checkCodeUrl;
            _username = [_usernameTextField.text copy];
            _password = [_passwordTextField.text copy];
            [_tableView reloadData];

            [_confirmButton setFrame:CGRectMake(_confirmButton.frame.origin.x, 210,
                    _confirmButton.frame.size.width,
                    _confirmButton.frame.size.height
            )];
            [_registerLabel setFrame:CGRectMake(_registerLabel.frame.origin.x, 255,
                    _registerLabel.frame.size.width,
                    _registerLabel.frame.size.height
            )];
            [_line setFrame:CGRectMake(_line.frame.origin.x, 275,
                    _line.frame.size.width,
                    _line.frame.size.height
            )];

            [_usernameTextField resignFirstResponder];
            [_passwordTextField resignFirstResponder];
        }
        if ([TBRONSStringUtil isNotBlank:loginResponse.errorString]) {
            UIAlertView *view = [UIAlertView alertViewWithTitle:@""
                                                        message:loginResponse.errorString];
            [view setCancelButtonWithTitle:@"确定"
                                   handler:NULL];
            [view show];
        } else {
            UIAlertView *view = [UIAlertView alertViewWithTitle:@""
                                                        message:loginResponse.errorString];
            [view setCancelButtonWithTitle:@"确定"
                                   handler:NULL];
            [view show];
        }
    }
}

- (UIWindow *)keyboardKeyWindow {
    if ([[[UIApplication sharedApplication] windows] count] > 1) {
        return [[[UIApplication sharedApplication] windows] objectAtIndex:1];
    }
    return [UIApplication sharedApplication].keyWindow;
}

- (void)dealloc {
    FMLog(@"%@ dealloc", [self description]);
    [MBProgressHUD hideHUDForView:[self keyboardKeyWindow]
                         animated:NO];
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
}

- (void)requestRefreshCheckCode {
    id proxy = self.proxyObject;
    [[FMLoginService proxyObject]
                     refreshCheckCode:^(BOOL isSuccess, NSString *checkCodeId, NSString *checkCodeUrl, NSString *error) {
                         [proxy refreshCheckCode:isSuccess
                                     checkCodeId:checkCodeId
                                    checkCodeUrl:checkCodeUrl];
                     }];
}

- (void)refreshCheckCode:(BOOL)isSuccess checkCodeId:(NSString *)checkCodeId checkCodeUrl:(NSString *)checkCodeUrl {
    if (isSuccess) {
        if ([TBRONSStringUtil isNotBlank:checkCodeId] && [TBRONSStringUtil isNotBlank:checkCodeUrl]) {
            [_checkCodeImageView setImageWithURL:[NSURL URLWithString:checkCodeUrl]];
            _checkCodeId = [checkCodeId copy];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([_checkCodeId length] > 0) {
        return 2;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return 1;
    }
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    __autoreleasing UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    }

    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                   reuseIdentifier:@"FMLoginTableViewCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 3.0f, 55.0f, 38.0f)];
            [label setBackgroundColor:[UIColor clearColor]];
            label.text = @"账 号:";
            [cell.contentView addSubview:label];

            _usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(80, 7, 210, 30)];
            _usernameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            _usernameTextField.backgroundColor = [UIColor clearColor];
            _usernameTextField.delegate = self;
            _usernameTextField.returnKeyType = UIReturnKeyNext;
            _usernameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
            _usernameTextField.text = ([_username length] > 0) ? _username : @"";
            _usernameTextField.tag = 202;
            _usernameTextField.font = FMFont(YES, 15.f);
            NSString *userNameStr = [[FMApplication instance].loginUser.name copy];
            _usernameTextField.placeholder = @"淘宝网账号";
            _usernameTextField.text = userNameStr;
            [cell.contentView addSubview:_usernameTextField];
            [_usernameTextField becomeFirstResponder];
        } else if (indexPath.row == 1) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 3.0f, 55.0f, 38.0f)];
            [label setBackgroundColor:[UIColor clearColor]];
            label.text = @"密 码:";
            [cell.contentView addSubview:label];

            _passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(80, 7, 210, 30)];
            _passwordTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            _passwordTextField.placeholder = @"登录密码";
            _passwordTextField.delegate = self;
            _passwordTextField.returnKeyType = UIReturnKeyDone;
            _passwordTextField.secureTextEntry = YES;
            _passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
            _passwordTextField.text = ([_password length] > 0) ? _password : @"";
            _passwordTextField.font = FMFont(YES, 15.f);
            [cell.contentView addSubview:_passwordTextField];
        }
    } else if (indexPath.section == 1) {
        _checkCodeTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 5, 135, 35)];
        _checkCodeTextField.placeholder = @"请输入验证码";
        _checkCodeTextField.backgroundColor = [UIColor clearColor];
        _checkCodeTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _checkCodeTextField.delegate = self;
        _checkCodeTextField.returnKeyType = UIReturnKeyDone;
        [_checkCodeTextField becomeFirstResponder];
        [cell.contentView addSubview:_checkCodeTextField];

        UIView *checkCodeView = [[UIView alloc] initWithFrame:CGRectMake(135, 0, 165, 44)];
        checkCodeView.userInteractionEnabled = YES;

        _checkCodeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, 100, 35)];
        [_checkCodeImageView setImageWithURL:[NSURL URLWithString:_checkCodeURL]];
        [checkCodeView addSubview:_checkCodeImageView];

        UILabel *refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(105, 10, 65, 24)];
        refreshLabel.text = @"换一换";
        refreshLabel.backgroundColor = [UIColor clearColor];
        [checkCodeView addSubview:refreshLabel];

        UITapGestureRecognizer *refreshCheckCodeTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                              action:@selector(requestRefreshCheckCode)];
        refreshCheckCodeTap.numberOfTouchesRequired = 1;
        refreshCheckCodeTap.numberOfTapsRequired = 1;
        [checkCodeView addGestureRecognizer:refreshCheckCodeTap];

        [cell.contentView addSubview:checkCodeView];
    }
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
