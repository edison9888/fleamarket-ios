// 
// Created by henson on 6/6/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <MBMvc/TBMBSimpleStaticCommand+TBMBProxy.h>
#import <MBMvc/TBMBGlobalFacade.h>
#import <BlocksKit/UIView+BlocksKit.h>
#import "FMAccountViewController.h"
#import "FMLoginService.h"
#import "FMStyle.h"
#import "TBMBDefaultRootViewController+TBMBProxy.h"
#import "FMMySoldTradeViewController.h"
#import "FMItemDO.h"
#import "FMUserDO.h"
#import "NSString+Helper.h"
#import "FMTradesService.h"
#import "FMMyBuyTradeViewController.h"
#import "FMItemDetailViewController.h"
#import "FMPostQueueViewController.h"
#import "FMPostQueue.h"
#import "FMMessageViewController.h"
#import "FMCollectViewController.h"
#import "FMMessageService.h"
#import "FMPostViewController.h"
#import "FMMessageInfo.h"

#define FM_GUIDE_ACCOUNT  @"FMGuideAccount"

@implementation FMAccountInfo {
@private
    NSUInteger _sellingCount;
    NSUInteger _boughtCount;
    NSUInteger _soldCount;
    NSUInteger _postQueueCount;
    NSUInteger _messageUnreadCount;
    NSUInteger _collectCount;
    BOOL _loginDone;
}

@synthesize sellingCount = _sellingCount;
@synthesize boughtCount = _boughtCount;
@synthesize soldCount = _soldCount;
@synthesize messageUnreadCount = _messageUnreadCount;
@synthesize postQueueCount = _postQueueCount;
@synthesize loginDone = _loginDone;
@synthesize collectCount = _collectCount;
@end

@implementation FMAccountViewController {
@private
    FMAccountInfo *_accountInfo;

    NSUInteger _pageNum;

    __weak UIView *_guideBgView;
}

@synthesize accountInfo = _accountInfo;

- (id)init {
    self = [super init];
    if (self) {
        _accountInfo = [[FMAccountInfo alloc] init];
    }
    return self;
}


- (void)loadView {
    self.listType = FMListTypeSell;
    [super loadView];

    [self setTitle:@"个人中心"];
    self.view.backgroundColor = [FMColor instance].viewControllerBgColor;
    self.listView.accountInfo = _accountInfo;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showGuide];
}

- (void)showGuide {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:FM_GUIDE_ACCOUNT]) {
        __weak FMAccountViewController *weakSelf = self;
        UIView *guideBgView = [[UIView alloc] initWithFrame:
                CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        guideBgView.backgroundColor = [UIColor blackColor];
        guideBgView.userInteractionEnabled = YES;
        guideBgView.alpha = 0.8;
        guideBgView.onTouchUpBlock = ^(NSSet *set, UIEvent *event) {
            [weakSelf touchGuide];
        };
        _guideBgView = guideBgView;
        [self.view addSubview:guideBgView];

        UIImage *guideImage = [UIImage imageWithFileName:@"guide_account@2x.png"];
        UIImageView *guideImageView = [[UIImageView alloc] initWithFrame:
                CGRectMake(0, 164, guideImage.size.width, guideImage.size.height)];
        guideImageView.image = guideImage;
        [guideBgView addSubview:guideImageView];
    }
}

- (void)touchGuide {
    [_guideBgView removeFromSuperview];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:FM_GUIDE_ACCOUNT];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self sendNotificationForSEL:@selector($$getIdleUserInfo:)];
    [self sendNotificationForSEL:@selector($$getMessageUnreadCount:)];

    self.accountInfo.postQueueCount = [[FMPostQueue sharedInstance] getPostQueue].count;
}

#pragma mark -- request
- (void)requestItem:(BOOL)isRequestMore {
    if (isRequestMore) {
        _pageNum++;
    } else {
        _pageNum = 1;
    }
    id selfProxy = self.proxyObject;
    [[FMTradesService proxyObject]
            getSellingItems:_pageNum
                     result:^(BOOL isSuccess, FMItemDOList *itemDOList, NSString *errorMsg) {
                         [selfProxy requestItemFinish:itemDOList
                                        isRequestMore:isRequestMore
                                            isSuccess:isSuccess
                                             errorMsg:errorMsg];
                     }];
}

#pragma mark -- message count
//刷新个人中心相关数字
- (void)$$receiveIdleUserInfo:(id <TBMBNotification>)notification user:(FMUserDO *)user {
    self.accountInfo.boughtCount = (NSUInteger) [user.idleBuyNum unsignedLongLongValue];
    self.accountInfo.sellingCount = (NSUInteger) [user.idleSellingNum unsignedLongLongValue];
    self.accountInfo.soldCount = (NSUInteger) [user.idleSoldNum unsignedLongLongValue];
    self.accountInfo.collectCount = (NSUInteger) [user.idleFavNum unsignedLongLongValue];
}

//清除消息未读数
- (void)$$hasClearMessageUnreadCount:(id <TBMBNotification>)notification {
    self.accountInfo.messageUnreadCount = 0;
}

//有新消息，需要刷新消息未读数
- (void)$$hasNewMessage:(id <TBMBNotification>)notification isSync:(NSNumber *)isSync {
    [self sendNotificationForSEL:@selector($$getMessageUnreadCount:)];
}

//更新消息未读数
- (void)$$receiveMessageUnreadCount:(id <TBMBNotification>)notification count:(NSNumber *)count {
    self.accountInfo.messageUnreadCount = [count unsignedIntegerValue];
}

//更新发布队列数字
- (void)$$postQueueUpdate:(id <TBMBNotification>)notification {
    _accountInfo.postQueueCount = [[FMPostQueue sharedInstance] queueCount];
}

#pragma mark -- push
//跳转到我卖出的宝贝列表
- (void)$$pushToMySoldViewController {
    if (!self.showing) {
        return;
    }
    FMMySoldTradeViewController *soldTradeViewController = [[FMMySoldTradeViewController alloc] init];
    [self.navigationController pushViewController:soldTradeViewController animated:YES];
}

//跳转到我买到的宝贝列表
- (void)$$pushToMyBoughtViewController {
    if (!self.showing) {
        return;
    }
    FMMyBuyTradeViewController *soldTradeViewController = [[FMMyBuyTradeViewController alloc] init];
    [self.navigationController pushViewController:soldTradeViewController animated:YES];
}

//跳转到我的收藏
- (void)$$pushFavViewController {
    if (!self.showing) {
        return;
    }
    FMCollectViewController *listViewController = [[FMCollectViewController alloc] init];
    listViewController.listType = FMListTypeCollect;
    listViewController.title = @"我的收藏";
    [self.navigationController pushViewController:listViewController animated:YES];
}

//调整到发布队列
- (void)$$pushPostQueueViewController {
    if (!self.showing) {
        return;
    }
    FMPostQueueViewController *postQueueViewController = [[FMPostQueueViewController alloc] init];
    [self.navigationController pushViewController:postQueueViewController animated:YES];
}

//跳转到消息中心
- (void)$$pushMessageViewController {
    if (!self.showing) {
        return;
    }
    FMMessageViewController *messageViewController = [[FMMessageViewController alloc] init];
    [self.navigationController pushViewController:messageViewController animated:YES];
    [self sendNotificationForSEL:@selector($$clearMessageUnreadCount:)];
}

//宝贝发布成功后，个人中心导航被选中，跳转到详情页
- (void)$$postItemDidFinishedToAccount:(id <TBMBNotification>)notification withIsLoad:(NSNumber *)isLoad {
    [self requestItem:NO];
    FMItemDetailViewController *detailViewController = [[FMItemDetailViewController alloc]
            initWithItemDO:[notification.userInfo objectForKey:@"itemDO"]];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

//详情页宝贝删除成功后刷新在售列表，由于服务端数据不同步，可能刷新后，删除宝贝数据还在
- (void)$$itemDeleteDidFinish:(id <TBMBNotification>)notification {
    if (self.isViewLoaded) {
        [self performSelector:@selector(requestItem) withObject:nil afterDelay:0.5];
    }
}

- (void)requestItem {
    [self requestItem:NO];
}

//点击编辑按钮，调整发布页
- (void)$$pushPostViewController:(id <TBMBNotification>)notification itemId:(NSString *)itemId {
    if (!self.showing) {
        return;
    }
    FMPostViewController *postViewController = [[FMPostViewController alloc] initWithItemId:itemId];
    UINavigationController *postNavigationController = [[UINavigationController alloc]
            initWithRootViewController:postViewController];
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationFade];
    [self.navigationController presentViewController:postNavigationController
                                            animated:YES
                                          completion:nil];
}

//从详情页进入编辑宝贝，成功后通知，刷新在售列表
- (void)$$editItemDidFinished:(id <TBMBNotification>)notification {
    [self requestItem:NO];
}

//从个人中心在售宝贝点进编辑宝贝，成功后通知，跳转到详情页并刷新在售列表
- (void)$$editItemDidFinishedWithItemId:(id <TBMBNotification>)notification itemId:(NSString *)itemId {
    if (!self.showing) {
        return;
    }
    FMItemDetailViewController *detailViewController = [[FMItemDetailViewController alloc]
            initWithItemId:itemId];
    [self.navigationController pushViewController:detailViewController animated:YES];
    [self requestItem:NO];
}

//登录成功后刷新数据
- (void)$$loginSuccess:(id <TBMBNotification>)notification {
    if (self.isViewLoaded) {
        [self sendNotificationForSEL:@selector($$getIdleUserInfo:)];
        [self sendNotificationForSEL:@selector($$getMessageUnreadCount:)];

        self.accountInfo.postQueueCount = [[FMPostQueue sharedInstance] getPostQueue].count;
        [self requestItem:NO];
    }
}

//- (void)$$loginSuccess:(id <TBMBNotification>)notification {
//    //FIXME
//    [FMMessageService deleteSystemAllMessage:^(NSNumber *number) {
//    }];
//
//    FMMessageInfo *info1 = [[FMMessageInfo alloc] init];
//    info1.content = @"{\"desc\":\"你的xxx宝贝被拍下了\", \"tradeType\":2, \"orderId\":\"92218880104121\"}";
//    info1.unread = YES;
//    info1.type = SOLD;
//    [FMMessageService insertMessageInfo:info1
//                                 result:^(NSNumber *number) {
//                                     FMLOG(@"记得最后删了 number:%@", number);
//                                 }];
//
//    FMMessageInfo *info2 = [[FMMessageInfo alloc] init];
//    info2.content = @"{\"desc\":\"你的xxx宝贝已发货了\", \"tradeType\":1, \"orderId\":\"92220920545711\"}";
//    info2.unread = YES;
//    info2.type = BUY;
//    [FMMessageService insertMessageInfo:info2
//                                 result:^(NSNumber *number) {
//                                     FMLOG(@"记得最后删了 number:%@", number);
//                                 }];
//
//    FMMessageInfo *info3 = [[FMMessageInfo alloc] init];
//    info3.content = @"{\"desc\":\"xxx活动\", \"type\":2, \"actionURL\":\"http://m.taobao.com/\", \"title\":\"活动信息\"}";
//    info3.unread = YES;
//    info3.type = ACTIVITY;
//    [FMMessageService insertMessageInfo:info3
//                                 result:^(NSNumber *number) {
//                                     FMLOG(@"记得最后删了 number:%@", number);
//                                 }];
//
//    FMMessageInfo *info4 = [[FMMessageInfo alloc] init];
//    info4.content = @"{\"desc\":\"xxx系统消息\", \"type\":1, \"actionURL\":\"http://m.taobao.com/\", \"title\":\"系统信息\"}";
//    info4.unread = YES;
//    info4.type = SYSTEM;
//    [FMMessageService insertMessageInfo:info4
//                                 result:^(NSNumber *number) {
//                                     FMLOG(@"记得最后删了 number:%@", number);
//                                 }];
//    [self sendNotificationForSEL:@selector($$getMessageUnreadCount:)];
//}

@end