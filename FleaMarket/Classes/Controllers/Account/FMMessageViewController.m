//
// Created by yuanxiao on 13-7-1.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <MBMvc/TBMBDefaultRootViewController+TBMBProxy.h>
#import <MBMvc/TBMBSimpleStaticCommand+TBMBProxy.h>
#import "FMMessageViewController.h"
#import "FMItemDetailViewController.h"
#import "FMMessageTapView.h"
#import "FMMessageView.h"
#import "FMMessageService.h"
#import "FMMessage.h"
#import "FMItemCommentDO.h"
#import "FMItemCommentService.h"
#import "FMTradeMessageInfo.h"
#import "FMMessageInfo.h"
#import "FMMyBuyTradeViewController.h"
#import "FMMySoldTradeViewController.h"
#import "FMWebviewController.h"
#import "FMSystemMessageContent.h"

@implementation FMMessageViewInfo {
@private
    NSInteger _systemCount;
    NSInteger _receiveCount;
    NSInteger _sendCount;
}

@synthesize systemCount = _systemCount;
@synthesize receiveCount = _receiveCount;
@synthesize sendCount = _sendCount;
@end


@implementation FMMessageViewController {
@private
    BOOL _edit;
    __weak FMMessageView *_systemMessageView;
    __weak FMMessageView *_receiveMessageView;
    __weak FMMessageView *_sendMessageView;

    FMMessageList *_systemMessageList;
    FMMessageList *_receiveMessageList;
    FMMessageList *_sendMessageList;

    __weak FMMessageTapView *_messageTapView;
    FMMessageViewInfo *_messageInfo;

    FMMessageViewType _messageViewType;
}

@synthesize messageInfo = _messageInfo;

- (id)init {
    self = [super init];
    if (self) {
        _messageInfo = [[FMMessageViewInfo alloc] init];
        _systemMessageList = [[FMMessageList alloc] init];
        _receiveMessageList = [[FMMessageList alloc] init];
        _sendMessageList = [[FMMessageList alloc] init];
    }
    return self;
}


- (void)initNavigationBar {
    [self setTitle:@"消息中心"];
    self.leftBarButton.hidden = NO;
    [self setRightButtonTitle:@"清空"];
}

- (void)loadView {
    [super loadView];
    self.view.backgroundColor = [UIColor clearColor];
    [self initNavigationBar];
    __weak FMMessageViewController *weakSelf = self;

    FMMessageView *messageView1 = [self getMessageView:FMMessageViewTypeSystem];
    messageView1.messageList = _systemMessageList;
    _systemMessageView = messageView1;

    FMMessageView *messageView2 = [self getMessageView:FMMessageViewTypeReceive];
    _receiveMessageView = messageView2;
    _receiveMessageView.hidden = YES;
    _receiveMessageView.messageList = _receiveMessageList;

    FMMessageView *messageView3 = [self getMessageView:FMMessageViewTypeSend];
    _sendMessageView = messageView3;
    _sendMessageView.hidden = YES;
    _sendMessageView.messageList = _sendMessageList;

    FMMessageTapView *messageTapView = [[FMMessageTapView alloc] init];
    messageTapView.messageInfo = _messageInfo;
    [self.view addSubview:messageTapView];
    _messageTapView = messageTapView;
    [messageTapView setTouchMessageTapItem:^(FMMessageViewType messageViewType) {
        [weakSelf switchView:messageViewType];
    }];

    [_messageTapView selectMessageTap:_selectMessageType];
}

- (void)setSelectMessageType:(FMMessageViewType)selectMessageType {
    _selectMessageType = selectMessageType;
    if (self.isViewLoaded) {
        [_messageTapView selectMessageTap:_selectMessageType];
    }
}

- (FMMessageView *)getMessageView:(FMMessageViewType)messageViewType {
    CGRect rect = {{0, 0},{FM_SCREEN_WIDTH, FM_SCREEN_HEIGHT - 20}};
    FMMessageView *messageView = [[FMMessageView alloc] initWithFrame:rect messageViewType:messageViewType];
    [self.view addSubview:messageView];
    __weak FMMessageViewController *weakSelf = self;
    [messageView setRequestBlock:^(NSUInteger pageNum) {
        [weakSelf request:pageNum];
    }];
    [messageView setDeleteComment:^(FMItemCommentDO *commentDO) {
        [weakSelf deleteComment:commentDO];
    }];
    return messageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (_sendMessageList.items.count == 0) {
        [FMMessageService countSystemAll:^(NSNumber *result) {
            self.messageInfo.systemCount = [result intValue];
            [self requestSystemMessage:1];
        }];
    }
    if (_receiveMessageList.items.count == 0) {
        [self requestReceiveMessage:1];
    }
    if (_sendMessageList.items.count == 0) {
        [self requestSendMessage:1];
    }
}

- (void)dealloc {
    FMLog(@"%@ dealloc", NSStringFromClass([self class]));
}

- (void)rightAction:(id)sender {
    [super rightAction:sender];
    if (_messageViewType == FMMessageViewTypeSystem) {
        [FMMessageService deleteSystemAllMessage:^(NSNumber *number) {
            [_systemMessageList.items removeAllObjects];
            self.messageInfo.systemCount = 0;
            [_systemMessageView refreshView:1];
        }];
        return;
    }
//    if (_edit) {
//        _edit = NO;
//        [self setRightButtonTitle:@"编辑"];
//    } else {
//        _edit = YES;
//        [self setRightButtonTitle:@"完成"];
//    }
//    FMMessageView *messageView;
//    if (_messageViewType == FMMessageViewTypeReceive) {
//        messageView = _receiveMessageView;
//    } else if (_messageViewType == FMMessageViewTypeSend) {
//        messageView = _sendMessageView;
//    }
//    [messageView setEdit:_edit];
}

- (void)switchView:(FMMessageViewType)messageViewType {
    CGFloat scrollHeight = _messageTapView.frame.origin.y - kNavigationBarHeight;
    _messageViewType = messageViewType;
    if (messageViewType == FMMessageViewTypeSystem) {
        _systemMessageView.hidden = NO;
        _receiveMessageView.hidden = YES;
        _sendMessageView.hidden = YES;
        [_systemMessageView scrollToHeight:scrollHeight];
//        [self setRightButtonTitle:@"清空"];
        self.titleView.viewDO.rightButtonShow = YES;
    } else if (messageViewType == FMMessageViewTypeReceive) {
        _systemMessageView.hidden = YES;
        _receiveMessageView.hidden = NO;
        _sendMessageView.hidden = YES;
        [_receiveMessageView scrollToHeight:scrollHeight];
//        [self setRightButtonTitle:@"编辑"];
        self.titleView.viewDO.rightButtonShow = NO;
    } else if (messageViewType == FMMessageViewTypeSend) {
        _systemMessageView.hidden = YES;
        _receiveMessageView.hidden = YES;
        _sendMessageView.hidden = NO;
        [_sendMessageView scrollToHeight:scrollHeight];
//        [self setRightButtonTitle:@"编辑"];
        self.titleView.viewDO.rightButtonShow = NO;
    }
}

- (void)$$messagePushDetail:(id <TBMBNotification>)notification itemId:(NSString *)itemId {
    if ([self isReceiveNotification]) {
        return;
    }
    FMItemDetailViewController *detailViewController = [[FMItemDetailViewController alloc]
            initWithItemId:itemId];
    detailViewController.isScrollToComment = YES;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)$$messagePushTrade:(id <TBMBNotification>)notification messageInfo:(FMMessageInfo *)messageInfo {
    if ([self isReceiveNotification]) {
        return;
    }
    if (messageInfo.type == BUY) {
        FMMyBuyTradeViewController *buyTradeViewController = [[FMMyBuyTradeViewController alloc] init];
        buyTradeViewController.orderId = ((FMTradeMessageInfo *)messageInfo.contentId).orderId;
        [self.navigationController pushViewController:buyTradeViewController animated:YES];
    } else if (messageInfo.type == SOLD) {
        FMMySoldTradeViewController *soldTradeViewController = [[FMMySoldTradeViewController alloc] init];
        soldTradeViewController.orderId = ((FMTradeMessageInfo *)messageInfo.contentId).orderId;
        [self.navigationController pushViewController:soldTradeViewController animated:YES];
    } else if (messageInfo.type == ACTIVITY || messageInfo.type == SYSTEM) {
        FMSystemMessageContent *systemMessageContent = (FMSystemMessageContent *)messageInfo.contentId;
        FMWebViewController *webViewController = [[FMWebViewController alloc] init];
        webViewController.webViewType = FMWebViewTypeRequest;
        webViewController.url = systemMessageContent.actionURL;
        webViewController.title = systemMessageContent.title;
        [self.navigationController pushViewController:webViewController animated:YES];
    }
}

- (void)$$hasNewMessage:(id <TBMBNotification>)notification isSync:(NSNumber *)isSync {
    if ([self isReceiveNotification]) {
        return;
    }
    [FMMessageService countSystemAll:^(NSNumber *result) {
        self.messageInfo.systemCount = [result intValue];
        [self requestSystemMessage:1];
    }];
}

- (BOOL)isReceiveNotification {
    return !self.showing;
}

#pragma mark -- request
- (void)request:(NSUInteger)pageNum {
    if (_messageViewType == FMMessageViewTypeSystem) {
        [self requestSystemMessage:pageNum];
    }else if (_messageViewType == FMMessageViewTypeReceive) {
        [self requestReceiveMessage:pageNum];
    } else if (_messageViewType == FMMessageViewTypeSend) {
        [self requestSendMessage:pageNum];
    }
}

- (void)requestSystemMessage:(NSUInteger)pageNum {
    [FMMessageService
            getMessageInfoByPageNO:pageNum
                       AndPageSize:10
                              type:SYSTEMALL
                            result:^(NSArray *array) {
                                [self receiveSystemMessage:pageNum array:array];
                            }];
}

- (void)receiveSystemMessage:(NSUInteger)pageNum array:(NSArray *)array {
    FMMessageList *messageList = [FMMessageList getMessageListWithMessageInfoList:array];
    messageList.totalCount = self.messageInfo.systemCount;
    messageList.nextPage = 10 * pageNum < self.messageInfo.systemCount;
    [self receiveMessage:array.count > 0
             messageList:messageList
                 pageNum:pageNum
                 decList:_systemMessageList
                 decView:_systemMessageView];
}

- (void)requestReceiveMessage:(NSUInteger)pageNum {
    id selfProxy = self.proxyObject;
    [[FMMessageService proxyObject]
            getReceiveMessageList:[NSString stringWithFormat:@"%d", pageNum]
                              ret:^(BOOL isSuccess, FMMessageList *messageList) {
                                  [selfProxy receiveMessage:isSuccess messageList:messageList pageNum:pageNum];
                              }];
}

- (void)receiveMessage:(BOOL)isSuccess messageList:(FMMessageList *)messageList pageNum:(NSUInteger)pageNum {
    self.messageInfo.receiveCount = messageList.totalCount;
    [self receiveMessage:isSuccess
             messageList:messageList
                 pageNum:pageNum
                 decList:_receiveMessageList
                 decView:_receiveMessageView];
}

- (void)requestSendMessage:(NSUInteger)pageNum {
    id selfProxy = self.proxyObject;
    [[FMMessageService proxyObject]
            getSendMessageList:[NSString stringWithFormat:@"%d", pageNum]
                           ret:^(BOOL isSuccess, FMMessageList *messageList) {
                               [selfProxy receiveSendMessage:isSuccess messageList:messageList pageNum:pageNum];
                           }];
}

- (void)receiveSendMessage:(BOOL)isSuccess messageList:(FMMessageList *)messageList pageNum:(NSUInteger)pageNum {
    self.messageInfo.sendCount = messageList.totalCount;
    [self receiveMessage:isSuccess
             messageList:messageList
                 pageNum:pageNum
                 decList:_sendMessageList
                 decView:_sendMessageView];
}

- (void)receiveMessage:(BOOL)isSuccess
           messageList:(FMMessageList *)messageList
               pageNum:(NSUInteger)pageNum
               decList:(FMMessageList *)decList
               decView:(FMMessageView *)messageView {
    if (isSuccess) {
        if (pageNum > 1) {
            [decList.items addObjectsFromArray:messageList.items];
        } else {
            decList.items = [[NSMutableArray alloc] initWithArray:messageList.items];
        }
        decList.nextPage = messageList.nextPage;
        [messageView refreshView:pageNum];
    } else {
        [messageView requestFinish:pageNum > 1];
    }
}

- (void)deleteComment:(FMItemCommentDO *)commentDO {
    FMMessageViewType messageViewType = _messageViewType;
    [FMItemCommentService
            deleteComment:[NSString stringWithFormat:@"%lld", commentDO.commentId]
                   itemId:[NSString stringWithFormat:@"%lld", commentDO.itemId]
                   result:^(BOOL isSuccess, NSString *errMsg) {
                       if (isSuccess) {
                           if (messageViewType == FMMessageViewTypeReceive) {
                               for (FMItemCommentDO *itemCommentDO in _receiveMessageList.items) {
                                   if (commentDO == itemCommentDO) {
                                       [_receiveMessageList.items removeObject:itemCommentDO];
                                       break;
                                   }
                               }
                               self.messageInfo.receiveCount--;
                               [_receiveMessageView refreshView:1];
                           } else if (messageViewType == FMMessageViewTypeSend) {
                               for (FMItemCommentDO *itemCommentDO in _sendMessageList.items) {
                                   if (commentDO == itemCommentDO) {
                                       [_sendMessageList.items removeObject:itemCommentDO];
                                       break;
                                   }
                               }
                               self.messageInfo.sendCount--;
                               [_sendMessageView refreshView:1];
                           }
                       }
                   }];
}

#pragma mark -- scroll event
- (void)$$receiveScroll:(id <TBMBNotification>)notification offset:(NSNumber *)offset {
    [super $$receiveScroll:notification offset:offset];
    if ([self isReceiveNotification]) {
        return;
    }

    CGFloat y = -[offset floatValue];
    CGRect rect = _messageTapView.frame;
    rect.origin.y += y;
    if (rect.origin.y > kNavigationBarHeight) {
        rect.origin.y = kNavigationBarHeight;
    } else if (rect.origin.y < 0) {
        rect.origin.y = 0;
    }
    if (abs((int) y) > 3) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             _messageTapView.frame = rect;
                         }];
    } else {
        _messageTapView.frame = rect;
    }
}

@end