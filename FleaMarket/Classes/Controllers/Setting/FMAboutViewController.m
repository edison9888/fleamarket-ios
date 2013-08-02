// 
// Created by henson on 6/21/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <BlocksKit/UIAlertView+BlocksKit.h>
#import <sys/ucred.h>
#import "FMAboutViewController.h"
#import "FMVersionService.h"
#import "NSString+Helper.h"
#import "FMCommon.h"
#import "TBSocialShareMailModel.h"
#import "TBSocialShareManager.h"
#import "FMBaseTableViewCell.h"
#import "FMStyle.h"
#import "FMGuideController.h"
#import "FMSidePanelController.h"

@implementation FMAboutViewController {
    UITableView *_tableView;
}

- (void)initNavigationBar {
    [self setTitle:@"关于淘宝二手"];
    [self setLeftBarButtonTitle:nil
                     buttonType:LeftButtonWithBack
                      iconImage:nil];
}

- (void)loadView {
    [super loadView];
    [self initNavigationBar];

    [self initIcon];
    [self initGuide];

    CGRect tableRect = {{0, kNavigationBarHeight + 130 + 84},
            {FM_SCREEN_WIDTH, 170}};
    UITableView *tableView = [[UITableView alloc] initWithFrame:tableRect style:UITableViewStyleGrouped];
    tableView.backgroundView = nil;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.scrollEnabled = NO;
    tableView.tableHeaderView = [self headView];
    [self.view addSubview:tableView];
    _tableView = tableView;
}

- (void)initIcon {
    CGRect rect = CGRectMake((FM_SCREEN_WIDTH - 57)/2, kNavigationBarHeight + 15, 57, 57);
    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:rect];
    iconImageView.image = [UIImage imageNamed:@"icon.png"];
    [self.view addSubview:iconImageView];

    rect = CGRectMake(95, kNavigationBarHeight + 90, 130, 40);
    UILabel *versionLabel = [[UILabel alloc] initWithFrame:rect];
    versionLabel.text = [NSString stringWithFormat:@"淘宝二手iPhone版\n%@", FM_APP_VERSION];
    versionLabel.font = FMFont(NO, 15);
    versionLabel.numberOfLines = 2;
    versionLabel.textAlignment = NSTextAlignmentCenter;
    versionLabel.textColor = [FMColor instance].cellColor;
    versionLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:versionLabel];
}

- (void)initGuide {
    CGRect rect = CGRectMake(10, kNavigationBarHeight + 130 + 20, 300, 44);
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = rect;
    [button setTitle:@"查看引导功能" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = FMFont(NO, 18.f);
    [button setBackgroundImage:[self cellButtonBgImage] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(gotoGuide) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)dealloc {
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
}

- (UIView *)headView {
    UILabel *label = [[UILabel alloc] initWithFrame:
            CGRectMake(0, 0, FM_SCREEN_WIDTH, 20)];
    label.text = @"联系我们";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [FMColor instance].cellColor;
    label.backgroundColor = [UIColor whiteColor];
    label.font = FMFont(NO, 15);
    return label;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    FMBaseTableViewCell *cell = [[FMBaseTableViewCell alloc] init];

    NSUInteger row = (NSUInteger) [indexPath row];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textColor = FMColorWithRed(74, 76, 77);
    cell.textLabel.font = FMFont(NO, 15);
    cell.accessoryView = nil;
    NSString *cellText;
    UIImage *image;
    if (row == 0) {
        cell.isCanSelect = NO;
        cellText = @"微信：淘宝二手";
        image = [UIImage imageWithFileName:@"setting_share_weixin_icon.png"];
    } else if (row == 1) {
        cell.isCanSelect = NO;
        cellText = @"微博：淘宝二手";
        image = [UIImage imageWithFileName:@"setting_share_weibo_icon.png"];
    } else if (row == 2) {
        cellText = @"给我们发邮件";
        image = [UIImage imageWithFileName:@"setting_share_email_icon.png"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.imageView.image = image;
    cell.textLabel.text = cellText;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 0 && indexPath.row == 2) {
        [self gotoMail];
    }
}

- (void)gotoMail {
    TBSocialShareManager *manager = [TBSocialShareManager instance];
    TBSocialShareMailModel *mailModel = [[TBSocialShareMailModel alloc] init];
    mailModel.suggestionMail = kSuggestionMail;
    mailModel.title = [NSString stringWithFormat:@"[跳蚤街意见反馈]客户端版本:%@",FM_APP_VERSION];
    mailModel.appVersion = FM_APP_VERSION;
    mailModel.currentTTID = kCurrentTTID;
    [manager shareContent:mailModel shareType:TBSocialShareTypeEmail delegate:self];
}

- (void)gotoGuide {
    FMGuideController *guideController = [[FMGuideController alloc] init];
    guideController.isFromAbout = YES;
    self.fmSidePanelController.modalPresentationStyle = UIModalPresentationCurrentContext;
    self.fmSidePanelController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.fmSidePanelController presentViewController:guideController
                                             animated:YES
                                           completion:nil];
}

- (void)updateVersion {
    [FMVersionService getNewVersion:^(NewVersionInfo *info) {
        if (info.hasNewVersion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:@"亲，有新版本哦，快去更新体验吧"
                                                               delegate:nil
                                                      cancelButtonTitle:@"以后再说"
                                                      otherButtonTitles:@"立即更新", nil];
                [alert setHandler:^{
                    if (info && [info.itemUrl isNotBlank]) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:info.itemUrl]];
                        return;
                    }
                } forButtonAtIndex:1];
                [alert show];
            });
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [FMCommon showToast:self.view text:@"亲，您已经是最新版本了"];
        });
        return;
    }];
}

- (UIImage *)cellButtonBgImage {
    return [[UIImage imageWithFileName:@"setting_cell_btn_bg.png"]
            resizeImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)];
}

- (UILabel *)versionLabel {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentRight;
    label.textColor = FMColorWithRed(0x66,0x66,0x66);
    label.text = FM_APP_VERSION;
    label.font = FMFont(NO, 15.0f);
    return label;
}

@end