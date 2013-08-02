//
// Created by yuanxiao on 13-7-4.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <MBMvc/TBMBGlobalFacade.h>
#import "FMMessageView.h"
#import "FMItemCommentDO.h"
#import "FMItemCommentCell.h"
#import "FMMessage.h"
#import "FMSystemMessageCell.h"
#import "FMMessageInfo.h"


@implementation FMMessageView {
@private
    UITableView *_tableView;

    void (^_requestData)(NSUInteger pageNum);
    void (^_deleteComment)(FMItemCommentDO *commentDO);

    NSUInteger _pageNum;

    FMMessageList *_messageList;
    FMMessageViewType _messageViewType;
}

@synthesize messageList = _messageList;

- (id)initWithFrame:(CGRect)frame messageViewType:(FMMessageViewType)messageViewType {
    self = [super initWithFrame:frame];
    if (self) {
        _messageViewType = messageViewType;
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)
                                                              style:UITableViewStylePlain];
        tableView.contentInset = UIEdgeInsetsMake(kMessageTitleHeight, 0, 0, 0);
        tableView.backgroundColor = FMColorWithRed(243, 243, 237);
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.showsVerticalScrollIndicator = NO;
        [self addSubview:tableView];
        _tableView = tableView;

        [self addMoreView:tableView];
        [self addEGORefresh:tableView];
        [self initNoDataLabel:tableView text:[self getNoDataText:messageViewType]];
        [self setMoreViewBGColor:FMColorWithRed(243, 243, 237)];
        _pageNum = 1;
    }
    return self;
}

- (NSString *)getNoDataText:(FMMessageViewType)messageViewType {
    if (messageViewType == FMMessageViewTypeSystem) {
        return @"亲，暂无系统消息";
    } else if (messageViewType == FMMessageViewTypeReceive) {
        return @"亲，你还没有收到留言哦~";
    } else if (messageViewType == FMMessageViewTypeSend) {
        return @"亲，你还没有回复过留言哦~";
    }
    return @"";
}

- (void)setEdit:(BOOL)edit {
    [_tableView setEditing:edit animated:YES];
}

- (void)setRequestBlock:(void(^)(NSUInteger pageNum))block {
    _requestData = block;
}

- (void)setDeleteComment:(void(^)(FMItemCommentDO *commentDO))block {
    _deleteComment = block;
}

- (void)refreshView:(NSUInteger)pageNum {
    [_tableView reloadData];
    [self requestFinish:pageNum > 1];
}

- (void)scrollToHeight:(CGFloat)height {
    if (_tableView.contentSize.height < self.frame.size.height - kMessageTitleHeight) {
        TBMBGlobalSendNotificationForSELWithBody(@selector($$receiveScroll:offset:),
                [NSNumber numberWithFloat:-kNavigationBarHeight - 3]);
    } else {
        [_tableView setContentOffset:CGPointMake(0, -kMessageTitleHeight - height) animated:NO];
    }
}

#pragma mark Table View Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _messageList.items.count;
}

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    return YES;
//}
//
//- (NSString *)                          tableView:(UITableView *)tableView
//titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return @"删除";
//}
//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
//forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        if (_deleteComment) {
//            FMItemCommentDO *commentDO = [_messageList.items objectAtIndex:(NSUInteger)indexPath.row];
//            _deleteComment(commentDO);
//        }
//    }
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_messageViewType == FMMessageViewTypeSystem) {
        static NSString *cellIdentifier = @"messageSystem";
        FMSystemMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[FMSystemMessageCell alloc] initWithStyle:UITableViewCellStyleDefault
                                            reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        FMMessageInfo *messageInfo = [_messageList.items objectAtIndex:(NSUInteger)indexPath.row];
        [cell setCommentDO:messageInfo];
        return cell;
    } else {
        static NSString *cellIdentifier = @"messageComment";
        FMItemCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[FMItemCommentCell alloc] initWithStyle:UITableViewCellStyleDefault
                                            reuseIdentifier:cellIdentifier
                                            commentCellType:FMCommentCellTypeMessage];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }

        [cell setCommentDO:[_messageList.items objectAtIndex:(NSUInteger)indexPath.row]
                serverTime:_messageList.serverTime];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_messageViewType == FMMessageViewTypeSystem) {
        return [FMSystemMessageCell cellHeight:[_messageList.items objectAtIndex:(NSUInteger)indexPath.row]];
    } else {
        return [FMItemCommentCell cellHeight:[_messageList.items objectAtIndex:(NSUInteger)indexPath.row]];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_messageViewType == FMMessageViewTypeSystem) {
        FMMessageInfo *messageInfo = [_messageList.items objectAtIndex:(NSUInteger)indexPath.row];
//        [FMMessageService
//                clearUnreadWithId:messageInfo.id
//                           result:^(NSNumber *result) {
//                               if ([result boolValue]) {
//                                   messageInfo.unread = NO;
//                                   [_tableView beginUpdates];
//                                   [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
//                                                     withRowAnimation:UITableViewRowAnimationFade];
//                                   [_tableView endUpdates];
//                               }
//                           }];
        TBMBGlobalSendNotificationForSELWithBody(@selector($$messagePushTrade:messageInfo:),
                messageInfo);
    } else {
        FMItemCommentDO *itemCommentDO = [_messageList.items objectAtIndex:(NSUInteger)indexPath.row];
        TBMBGlobalSendNotificationForSELWithBody(@selector($$messagePushDetail:itemId:),
                [NSString stringWithFormat:@"%lld", itemCommentDO.itemId]);
    }
}

- (BOOL)hasNextPage {
    return _messageList.nextPage;
}

- (void)requestFinish:(BOOL)isMore {
    [super requestFinish:isMore];
    if (_messageList.items.count == 0) {
        self.noDataLabel.hidden = NO;
    } else {
        self.noDataLabel.hidden = YES;
    }
}

- (void)requestMore {
    if (_requestData) {
        _pageNum++;
        _requestData(_pageNum);
    }
}

- (void)refreshData {
    if (_requestData) {
        _pageNum = 1;
        _requestData(_pageNum);
    }
}

- (void)dealloc {
    FMLog(@"%@ dealloc", NSStringFromClass([self class]));
}

@end