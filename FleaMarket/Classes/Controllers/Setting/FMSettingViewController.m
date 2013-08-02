// 
// Created by henson on 6/6/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <BlocksKit/UIAlertView+BlocksKit.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <SDWebImage/SDImageCache.h>
#import "FMSettingViewController.h"
#import "FMLoginService.h"
#import "FMAboutViewController.h"
#import "FMWebviewController.h"
#import "TBSocialShareManager.h"
#import "FMPushService.h"
#import "FMCustomStatusBar.h"
#import "FMApplication.h"
#import "FMSetting.h"
#import "FMBaseTableViewCell.h"
#import "KLSwitch.h"
#import "FMStyle.h"
#import "FMVoicePlayer.h"
#import "FMCommon.h"

#define kSettingShareWeiboTag     100001
#define kSettingShareDoubanTag    100002

@implementation FMSettingViewController {
    UITableView *_tableView;

    KLSwitch *_notificationSwitch;
    BOOL _isFirst;
}

- (void)initNavigationBar {
    [self setTitle:@"设置"];
}

- (void)loadView {
    [super loadView];
    [self initNavigationBar];
    _isFirst = YES;

    CGRect tableRect = {{0, kNavigationBarHeight}, {FM_SCREEN_WIDTH, FM_SCREEN_HEIGHT - kStatusBarHeight - kNavigationBarHeight}};
    UITableView *tableView = [[UITableView alloc] initWithFrame:tableRect style:UITableViewStyleGrouped];
    tableView.backgroundView = nil;
    tableView.backgroundColor = [FMColor instance].viewControllerBgGrayColor;
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    _tableView = tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [FMPushService fetchSubscribeCfg:^(BOOL isSuccess, NSArray *subscribes) {
        FMLog(@"subscribes :[%@]", subscribes);
        BOOL isNotification = (isSuccess && subscribes.count > 0) ? YES : NO;
        if (!isNotification) {
            _isFirst = NO;
        }
        [_notificationSwitch setOn:isNotification animated:NO];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_tableView reloadData];
}

- (void)dealloc {
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([FMLoginService isLogin]) {
        return 5;
    }
    return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return @"分享";
    }

    if (section == 2) {
        return @"更多";
    }

    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 4;
    }
    if (section == 1) {
        return 2;
    }
    if (section == 2) {
        return 4;
    }
    if (section == 3) {
        return 1;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = (NSUInteger) [indexPath row];
    NSUInteger section = (NSUInteger) [indexPath section];
    __weak FMSettingViewController *selfWeak = self;

    if (section == 4) {
        UITableViewCell *logoutCell = [[UITableViewCell alloc] init];
        logoutCell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        UIButton *logoutButton = [self getLogoutButton];
        [logoutCell.contentView addSubview:logoutButton];
        return logoutCell;
    }

    FMBaseTableViewCell *cell = [[FMBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                           reuseIdentifier:nil];

    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.textColor = FMColorWithRed(74, 76, 77);
    cell.textLabel.font = FMFont(NO, 15);
    cell.accessoryView = nil;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSString *cellText;
    if (section == 0) {
        if (row == 0) {
            cellText = @"自动压缩图片上传";
            KLSwitch *aSwitch = [self createSwitch:row];
            [aSwitch setOn:[FMApplication instance].setting.isAutoImageCompress animated:NO];
            aSwitch.didChangeHandler = ^(BOOL isOn) {
                [FMApplication instance].setting.isAutoImageCompress = isOn;
            };
            cell.accessoryView = aSwitch;
        } else if (row == 1) {
            cellText = @"只在WIFI环境下发布宝贝";
            KLSwitch *aSwitch = [self createSwitch:row];
            [aSwitch setOn:[FMApplication instance].setting.isPostItemInWifi animated:NO];
            aSwitch.didChangeHandler = ^(BOOL isOn) {
                [FMApplication instance].setting.isPostItemInWifi = isOn;
            };
            cell.accessoryView = aSwitch;
        } else if (row == 2) {
            cellText = @"留言通知";
            if (!_notificationSwitch) {
                _notificationSwitch = [self createSwitch:row];
                _notificationSwitch.didChangeHandler = ^(BOOL isOn) {
                    [selfWeak updateMessageNotification];
                };
            }
            cell.accessoryView = _notificationSwitch;
        } else {
            cellText = @"开启听筒模式";
            KLSwitch *aSwitch = [self createSwitch:row];
            [aSwitch setOn:[FMApplication instance].setting.isOpenHeadPhone
                  animated:NO];
            aSwitch.didChangeHandler = ^(BOOL isOn) {
                [selfWeak updateVoiceMode:isOn];
            };
            cell.accessoryView = aSwitch;
        }
        cell.textLabel.text = cellText;
        cell.isCanSelect = NO;
    } else if (section == 1) {
        if (row == 0) {
            cellText = @"微博";
            cell.imageView.image = [UIImage imageNamed:@"setting_share_weibo_icon.png"];
            cell.accessoryView = [self shareBindButtonWithTag:kSettingShareWeiboTag];
        }  else if (row == 1) {
            cellText = @"豆瓣";
            cell.imageView.image = [UIImage imageNamed:@"setting_share_douban_icon.png"];
            cell.accessoryView = [self shareBindButtonWithTag:kSettingShareDoubanTag];
        }
        cell.textLabel.text = cellText;
        cell.isCanSelect = NO;
    } else if (section == 2) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (row == 0) {
            cellText = @"关于淘宝二手";
        } else if (row == 1) {
            cellText = @"推荐应用";
        } else if (row == 2) {
            cellText = @"帮助与反馈";
        } else if (row == 3) {
            cellText = @"去评分";
        }
        cell.textLabel.text = cellText;
    } else if (section == 3) {
        cellText = @"清除缓存";
        cell.textLabel.text = cellText;
    }

    return cell;
}

- (void)updateVoiceMode:(BOOL)isOn {
    [FMApplication instance].setting.isOpenHeadPhone = isOn;
    [FMVoicePlayer setSpeakerType:isOn ? FM_HEADPHONE : FM_SPEAKER];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    NSUInteger row = (NSUInteger) [indexPath row];
    NSUInteger section = (NSUInteger) [indexPath section];

    if (section == 2) {
        if (row == 0) {
            FMAboutViewController *aboutViewController = [[FMAboutViewController alloc] init];
            [self.navigationController pushViewController:aboutViewController animated:YES];
        } else if (row == 3) {
            [self goMark];
        } else if (row == 1) {
            [self pushRecommendAppsController];
        } else if (row == 2) {
            [self pushFAQController];
        }
    } else if (section == 3) {
        [self clearCacheAction];
    }
}

- (UIButton *)getLogoutButton {
    CGRect logoutRect = CGRectMake(0, 0, 300, 44);
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = logoutRect;
    [button setTitle:@"退出登录" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = FMFont(NO, 18.f);
    [button setBackgroundImage:[self cellButtonBgImage] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(logoutAction) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)clearCacheAction {
    [UIAlertView showAlertViewWithTitle:nil
                                message:@"亲，您确定要清除缓存吗？"
                      cancelButtonTitle:@"取消"
                      otherButtonTitles:@[@"确定"]
                                handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                    if (buttonIndex == 0) {
                                        [self clearCache];
                                        return;
                                    }
    }];
}

- (void)goMark {
    [[UIApplication sharedApplication] openURL:
            [NSURL URLWithString:@"https://itunes.apple.com/cn/app/tao-bao-tiao-zao-jie-qing/id510909506?mt=8"]];
}

- (void)clearCache {
    NSArray *array = [MBProgressHUD allHUDsForView:self.view];
    for (id hudViews in array) {
        [hudViews hide:NO];
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.userInteractionEnabled = NO;
    hud.labelText = @"清除中";
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [[SDImageCache sharedImageCache] clearDisk];
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [FMCommon showToast:self.view text:@"亲，图片缓存清除成功"];
        });
    });
}

- (void)logoutAction {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"亲，您确定要注销？"
                                                   delegate:nil
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"确定", nil];
    
    [alert setHandler:^{
        [FMLoginService logout];
    } forButtonAtIndex:1];
    [alert show];
}

- (void)$$loginSuccess:(id <TBMBNotification>)notification {
    [_tableView reloadData];
}

- (void)$$logoutDone:(id <TBMBNotification>)notification {
    [_tableView reloadData];
}

- (UIButton *)shareBindButtonWithTag:(NSInteger)tag {
    CGRect bindRect = CGRectMake(0, 0, 59, 29);
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = bindRect;
    [button setTitle:[self getShareStrWithTag:tag]
            forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = FMFont(NO, 15.f);
    [button setBackgroundImage:[self bindBgImage:tag]
                      forState:UIControlStateNormal];
    [button addTarget:self action:@selector(shareButton:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = tag;
    return button;
}

- (NSString *)getShareStrWithTag:(NSInteger)tag {
    TBSocialShareManager *socialShareManager = [TBSocialShareManager instance];
    NSString *str;
    if (tag == kSettingShareWeiboTag) {
        if ([socialShareManager isLoginWithShareType:TBSocialShareTypeSina]) {
            str = @"解绑";
        } else {
            str = @"绑定";
        }
    } else if(tag == kSettingShareDoubanTag) {
        if ([socialShareManager isLoginWithShareType:TBSocialShareTypeDouban]) {
            str = @"解绑";
        } else {
            str = @"绑定";
        }
    }
    return str;
}

- (void)shareButton:(id)sender {
    UIButton *button = (UIButton *)sender;
    TBSocialShareManager *socialShareManager = [TBSocialShareManager instance];
    if (button.tag == kSettingShareWeiboTag) {
        if ([button.titleLabel.text isEqualToString:@"解绑"]) {
            [socialShareManager logoutWithShareType:TBSocialShareTypeSina
                                           delegate:self];
        } else {
            [socialShareManager loginWithShareType:TBSocialShareTypeSina
                                          delegate:self];
        }
    } else if (button.tag == kSettingShareDoubanTag) {
        if ([button.titleLabel.text isEqualToString:@"解绑"]) {
            [socialShareManager logoutWithShareType:TBSocialShareTypeDouban
                                           delegate:self];
        } else {
            [socialShareManager loginWithShareType:TBSocialShareTypeDouban
                                          delegate:self];
        }
    }
}

- (KLSwitch *)createSwitch:(NSInteger)row {
    CGRect switchRect = {{0, 0}, {50, 30}};
    KLSwitch *cellSwitch = [[KLSwitch alloc] initWithFrame:switchRect];
    [cellSwitch setOnTintColor:FMColorWithRGB0X(0xf2614c)];
    cellSwitch.shouldConstrainFrame = YES;
    cellSwitch.tag = row;
    return cellSwitch;
}

- (void)updateMessageNotification {
    if (_isFirst && _notificationSwitch.isOn) {
        _isFirst = NO;
        return;
    }
    _isFirst = NO;
    [FMPushService updateSubscribeCfg:_notificationSwitch.isOn ret:^(BOOL isSuccess) {
        if (isSuccess) {
            [FMCustomStatusBar showStatusMessage:@"更新通知设置成功" hideAfter:2];
        } else {
            [FMCustomStatusBar showStatusMessage:@"更新通知设置失败" hideAfter:2];
            [_notificationSwitch setOn:!_notificationSwitch.isOn animated:NO];
        }
    }];
}

- (UIImage *)cellButtonBgImage {
    return [[UIImage imageNamed:@"setting_cell_btn_bg.png"]
            resizeImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)];
}

- (UIImage *)bindBgImage:(NSInteger)tag {
    TBSocialShareManager *socialShareManager = [TBSocialShareManager instance];
    UIImage *image;
    if (tag == kSettingShareWeiboTag) {
        if ([socialShareManager isLoginWithShareType:TBSocialShareTypeSina]) {
            image = [self unbindBgImage];
        } else {
            image = [self bindBgImage];
        }
    } else if(tag == kSettingShareDoubanTag) {
        if ([socialShareManager isLoginWithShareType:TBSocialShareTypeDouban]) {
            image = [self unbindBgImage];
        } else {
            image = [self bindBgImage];
        }
    }
    return image;

}

- (UIImage *)bindBgImage {
    return [[UIImage imageNamed:@"setting_share_bind_bg.png"]
            resizeImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)];
}

- (UIImage *)unbindBgImage {
    return [[UIImage imageNamed:@"setting_share_unbind_bg.png"]
            resizeImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)];
}

// FIXME
- (void)pushRecommendAppsController {
    FMWebViewController *webView = [[FMWebViewController alloc] init];
    webView.webViewType = FMWebViewTypeRequest;
    webView.url = @"http://www.taobao.com";
    [self.navigationController pushViewController:webView
                                         animated:YES];
    [webView setTitle:@"推荐应用"];
}

// FIXME
- (void)pushFAQController {
    FMWebViewController *webView = [[FMWebViewController alloc] init];
    webView.webViewType = FMWebViewTypeRequest;
    webView.url = @"http://www.taobao.com";
    [self.navigationController pushViewController:webView
                                         animated:YES];
    [webView setTitle:@"帮助与反馈"];
}

#pragma mark -- share login delegate
- (void)loginSuccess:(TBSocialShareType)shareType {
    if (shareType == TBSocialShareTypeSina) {
        [self setShareButton:@"解绑" tag:kSettingShareWeiboTag];
    } else if (shareType == TBSocialShareTypeDouban) {
        [self setShareButton:@"解绑" tag:kSettingShareDoubanTag];
    }
}

- (void)loginFailed:(TBSocialShareType)shareType error:(NSError *)error {
    FMLog(@"绑定失败:%@", error);
}

- (void)logoutSuccess:(TBSocialShareType)shareType {
    if (shareType == TBSocialShareTypeSina) {
        [self setShareButton:@"绑定" tag:kSettingShareWeiboTag];
    } else if (shareType == TBSocialShareTypeDouban) {
        [self setShareButton:@"绑定" tag:kSettingShareDoubanTag];
    }
}

- (void)setShareButton:(NSString *)title tag:(NSInteger)tag {
    UIButton *button = (UIButton *) [self.view viewWithTag:tag];
    [button setTitle:title forState:UIControlStateNormal];
    [button setBackgroundImage:[self bindBgImage:tag]
                      forState:UIControlStateNormal];
}

@end