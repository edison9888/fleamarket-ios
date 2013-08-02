// 
// Created by henson on 6/8/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <BlocksKit/UIControl+BlocksKit.h>
#import <MBMvc/TBMBSimpleStaticCommand+TBMBProxy.h>
#import <QuartzCore/QuartzCore.h>
#import <MBMvc/TBMBSimpleInstanceCommand+TBMBProxy.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <BlocksKit/UIActionSheet+BlocksKit.h>
#import <MBMvc/TBMBGlobalFacade.h>
#import <BlocksKit/UIView+BlocksKit.h>
#import <BlocksKit/UIAlertView+BlocksKit.h>
#import "FMSidePanelController.h"
#import "FMItemDetailViewController.h"
#import "FMItemDO.h"
#import "FMItemCommentCell.h"
#import "FMItemCommentDO.h"
#import "FMItemDetailBottomView.h"
#import "FMItemDetailInfoView.h"
#import "FMWebviewController.h"
#import "FMItemBuyViewController.h"
#import "FMItemPostCommentView.h"
#import "FMItemService.h"
#import "FMItemCommentService.h"
#import "NSObject+TBIU_BeanCopy.h"
#import "TBSocialShareBaseModel.h"
#import "TBSocialShareManager.h"
#import "TBSocialShareWeChatModel.h"
#import "FMApplication.h"
#import "FMUser.h"
#import "FMPostViewController.h"
#import "NSString+Helper.h"
#import "FMItemImageViewController.h"
#import "FMCommentDO.h"
#import "FMVoiceService.h"
#import "FMVoiceRecorder.h"
#import "FMVoiceUploadService.h"
#import "FMCommentReplyDO.h"
#import "FMLoginViewController.h"
#import "FMSubscribeService.h"
#import "FMItemShareTextView.h"
#import "FMShareActionSheet.h"
#import "FMStyle.h"
#import "FMVoicePowerView.h"
#import "FMItemCommentPromptView.h"
#import "FMUserTrack.h"
#import "TBSocialShareToSina.h"
#import "TBSocialShareToDouban.h"
#import "TBSocialShareToWeChat.h"

#define FM_GUIDE_DETAIL    @"FM_GUIDE_DETAIL"

typedef NS_ENUM(NSUInteger, kItemDetailCommentType) {
    kItemDetailCommentTypeComment,
    kItemDetailCommentTypeReply,
};

@implementation FMItemDetailViewController {
    UITableView *_tableView;

    FMItemDetailInfoView *_infoView;
    FMItemDetailBottomView *_bottomView;
    FMItemPostCommentView *_postCommentView;
    FMItemCommentPromptView *_commentPromptView;

    NSMutableArray *_comments;
    FMItemCommentDOList *_itemCommentDOList;
    FMItemDetailResponseDO *_itemDetailResponseDO;
    NSUInteger _commentPage;

    UILabel *_moreLabel;
    UIActivityIndicatorView *_indicatorLoading;
    BOOL _isBeginRequestMore;
    BOOL _isLoadingMore;

    kItemDetailCommentType _commentType;
    NSUInteger _commentReplyRow;

    FMVoicePowerView *_voicePowerView;
    BOOL _isVoiceCancel;

    FMItemShareTextView *_weiboShareTextView;
    FMItemShareTextView *_doubanShareTextView;

@private
    FMItemDO *_itemDO;

    __weak UIView *_guideBgView;
}

@synthesize itemDO = _itemDO;

- (id)init {
    self = [super init];
    if (self) {
        self.isScrollToComment = NO;
        _commentPage = 1;
        _commentType = kItemDetailCommentTypeComment;
        _isVoiceCancel = NO;
        _comments = [NSMutableArray array];
    }

    return self;
}

- (id)initWithItemId:(NSString *)itemId {
    self = [self init];
    if (self) {
        self.itemDO = [[FMItemDO alloc] init];
        self.itemDO.id = itemId;
    }

    return self;
}

- (id)initWithItemDO:(FMItemDO *)itemDO {
    self = [self init];
    if (self) {
        self.itemDO = itemDO;
    }

    return self;
}

+ (id)controllerWithItemDO:(FMItemDO *)itemDO {
    return [[self alloc] initWithItemDO:itemDO];
}

- (void)loadView {
    [super loadView];
    self.titleView.hidden = YES;

    CGRect tableRect = {{0, 0}, {FM_SCREEN_WIDTH, FM_SCREEN_HEIGHT - 20}};
    UITableView *tableView = [[UITableView alloc] initWithFrame:tableRect style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.backgroundView = [self tableBackgroundView];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.showsVerticalScrollIndicator = YES;
    tableView.showsHorizontalScrollIndicator = NO;
    tableView.hidden = YES;
    [self.view addSubview:tableView];
    _tableView = tableView;

    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backImage = [UIImage imageNamed:@"item_back_icon.png"];
    [backButton setImage:backImage
                          forState:UIControlStateNormal];
    backButton.frame = CGRectMake(0, 0, 64, 50);
    [backButton addTarget:self action:@selector(backAction)
         forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];

    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *menuImage = [UIImage imageNamed:@"item_menu_icon.png"];
    [menuButton setImage:menuImage
                          forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(menuAction)
         forControlEvents:UIControlEventTouchUpInside];
    menuButton.frame = CGRectMake(FM_SCREEN_WIDTH - 60, 0, 60, 50);
    [self.view addSubview:menuButton];

    _commentPromptView = [[FMItemCommentPromptView alloc] initWithFrame:CGRectMake(0, FM_SCREEN_HEIGHT, FM_SCREEN_WIDTH, 25)];
    _commentPromptView.hidden = YES;
    [self.view addSubview:_commentPromptView];

    _bottomView = [self getBottomView];
    [self.view addSubview:_bottomView];

    _postCommentView = [self getPostCommentView];
    [self.view addSubview:_postCommentView];

    _voicePowerView = [[FMVoicePowerView alloc] initWithFrame:CGRectMake(0, 0, 140, 140)];
}

- (UIImageView *)tableBackgroundView {
    UIImage *backImage = [[UIImage imageNamed:@"item_detail_comment_bg.png"]
            resizableImageWithCapInsets:UIEdgeInsetsMake(290, 0, 0, 0)];
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:backImage];
    backgroundView.frame = CGRectMake(0, 0, FM_SCREEN_WIDTH, 100);
    return backgroundView;
}

- (FMItemDetailBottomView *)getBottomView {
    __weak FMItemDetailViewController *selfWeak = self;
    CGRect bottomRect = {{0, FM_SCREEN_HEIGHT - kStatusBarHeight - kTabBarHeight - 3}, {FM_SCREEN_WIDTH, kTabBarHeight + 3}};
    FMItemDetailBottomView *bottomView = [[FMItemDetailBottomView alloc] initWithFrame:bottomRect];
    bottomView.backgroundColor = [UIColor clearColor];
    [bottomView setBuyAction:^{
        [selfWeak buyAction];
    }];
    [bottomView setShareAction:^{
        [selfWeak shareAction];
    }];
    [bottomView setOperationAction:^{
        [selfWeak operationAction];
    }];
    return bottomView;
}

- (FMItemPostCommentView *)getPostCommentView {
    CGRect commentRect = {{0, FM_SCREEN_HEIGHT - kStatusBarHeight - kTabBarHeight - 3}, {FM_SCREEN_WIDTH, kTabBarHeight + 3}};
    FMItemPostCommentView *postCommentView = [[FMItemPostCommentView alloc] initWithFrame:commentRect];
    postCommentView.delegate = self;
    postCommentView.hidden = YES;
    __weak FMItemDetailViewController *selfWeak = self;
    [postCommentView.backButton addEventHandler:^(id sender) {
        [selfWeak commentViewBackAction];
    }                          forControlEvents:UIControlEventTouchUpInside];
    [postCommentView setTouchDownAction:^{
        [selfWeak voiceTouchDown];
    }];
    [postCommentView setTouchUpAction:^{
        [selfWeak voiceTouchUp];
    }];
    [postCommentView setTouchDragExitAction:^{
        [selfWeak voiceTouchDragExit];
    }];
    [postCommentView setTouchDragEnterAction:^{
        [selfWeak voiceTouchDragEnter];
    }];
    [postCommentView setTouchEndAction:^{
        [selfWeak voiceTouchEnd];
    }];
    return postCommentView;
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)menuAction {
    [self.fmSidePanelController toggleRightPanel:nil];
}

- (void)commentViewBackAction {
    _postCommentView.hidden = YES;
    _bottomView.hidden = NO;
    [_postCommentView.commentTextField resignFirstResponder];
    _commentType = kItemDetailCommentTypeComment;
    _commentPromptView.hidden = YES;
}

- (void)voiceTouchDown {
    FMNavigationViewController *controller =  (FMNavigationViewController *)self.navigationController;
    controller.isCloseDrag = YES;

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = _voicePowerView;
    hud.userInteractionEnabled = YES;
    __weak FMItemDetailViewController *selfWeak = self;
    [[FMVoiceService proxyObject]
            createVoiceRecorder:^(FMVoiceRecorder *recorder) {
                recorder.powerBlock = ^(CGFloat averagePower, CGFloat peakPower, FMVoiceRecorder *_recorder) {
                    [selfWeak voicePowerAction:averagePower peakPower:peakPower recorder:_recorder];
                };
                recorder.finishBlock = ^(NSData *data, NSString *amrFile, NSTimeInterval recordTime, FMVoiceRecorder *_recorder) {
                    [selfWeak voiceFinish:data amrFile:amrFile recordTime:recordTime recorder:_recorder];
                };
                [recorder record];
            }];
}

- (void)voicePowerAction:(CGFloat)averagePower peakPower:(CGFloat)peakPower recorder:(FMVoiceRecorder *)_recorder {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_recorder.recordTime > 60) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [FMCommon showToast:self.view text:@"亲，语音最多1分钟哦"];
            [[FMVoiceService proxyObject] stopAudioRecorder];
        }
        [_voicePowerView setPower:averagePower peakPower:peakPower];
    });
}

- (void)voiceFinish:(NSData *)data
            amrFile:(NSString *)amrFile
         recordTime:(NSTimeInterval)recordTime
           recorder:(FMVoiceRecorder *)_recorder {
    if (_recorder.recordTime < 1) {
        [FMCommon showToast:self.view text:@"亲，语音太短"];
    } else if (data && !_isVoiceCancel) {
        [self uploadVoice:data];
        return;
    }
    _isVoiceCancel = NO;
    [_recorder deleteArmFile];
}

static NSString *voiceUrl = nil;

- (void)uploadVoice:(NSData *)data {
    [[FMVoiceUploadService proxyObject]
                           uploadVoice:data
                            uploadType:FM_UPLOAD_TYPE_COMMENT
                                result:^(NSString *url, BOOL isSuccess, NSString *error) {
                                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

                                    voiceUrl = url;
                                    if (_commentType == kItemDetailCommentTypeComment) {
                                        FMCommentDO *commentDO = [self _generateCommentDO:nil
                                                                                 voiceUrl:url];
                                        [self publishComment:commentDO];
                                        return;
                                    }

                                    FMCommentReplyDO *commentReplyDO = [self _generateCommentReplyDO:nil
                                                                                            voiceUrl:url];
                                    [self replyComment:commentReplyDO];
                                    return;
                                }
                            onProgress:^(NSUInteger progress) {

                            }];
}

- (void)voiceTouchDragEnter {
    _voicePowerView.powerStatus = kVoicePowerStatusPower;
    _isVoiceCancel = NO;
}

- (void)voiceTouchEnd {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if (_isVoiceCancel) {
        [_voicePowerView setPowerStatus:kVoicePowerStatusPower];
        [self setNavDrag];
    }
}

- (void)setNavDrag {
    FMNavigationViewController *controller =  (FMNavigationViewController *) self.navigationController;
    controller.isCloseDrag = NO;
}

- (void)voiceTouchDragExit {
    _isVoiceCancel = YES;
    _voicePowerView.powerStatus = kVoicePowerStatusCancel;
}

- (void)voiceTouchUp {
    [[FMVoiceService proxyObject] stopAudioRecorder];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [_voicePowerView setPowerStatus:kVoicePowerStatusPower];
    [self setNavDrag];
}

- (void)buyAction {
    [FMCommon hideKeyboard];

    __weak FMItemDetailViewController *selfWeak = self;
    FMItemBuyViewController *buyViewController = [[FMItemBuyViewController alloc] initWithItemDO:_itemDO];
    buyViewController.isFromTheme = self.isFromTheme;
    UINavigationController *nav = self.navigationController;
    FMUser *loginUser = [FMApplication instance].loginUser;
    if (![loginUser isLogin]) {
        [self dismissModalViewControllerAnimated:NO];
        FMLoginViewController *loginViewController = [[FMLoginViewController alloc] init];
        loginViewController.loginCallback = ^(BOOL isLoginSuccess) {
            if (isLoginSuccess && [selfWeak isSeller]) {
                [selfWeak operationAction];
                return;
            }

            if (isLoginSuccess && nav.topViewController != buyViewController) {
                [nav pushViewController:buyViewController animated:YES];
            }
        };
        UINavigationController *loginNavigationController = [[UINavigationController alloc]
                initWithRootViewController:loginViewController];
        [self.fmSidePanelController presentViewController:loginNavigationController
                                                 animated:YES
                                               completion:nil];
        return;
    }
    [nav pushViewController:buyViewController animated:YES];
    return;
}

- (void)$$loginSuccess:(id <TBMBNotification>)notification {
    [self refreshItemDetailBottomView];
}

- (void)$$logoutDone:(id <TBMBNotification>)notification {
    [self refreshItemDetailBottomView];
}

- (void)refreshItemDetailBottomView {
    [_bottomView setItemDO:_itemDO];
}

- (BOOL)isSeller {
    FMUser *loginUser = [FMApplication instance].loginUser;
    return [loginUser isMyself:_itemDO.userId];
}

- (void)$$itemDetailFavoriteAction:(id <TBMBNotification>)notification
                              item:(FMItemDetailBottomItemView *)favoriteItem {
    if (!self.showing) {
        return;
    }
    [self favoriteAction];
}

- (void)$$itemDetailCommentAction:(id <TBMBNotification>)notification
                             item:(FMItemDetailBottomItemView *)commentItem {
    if (!self.showing) {
        return;
    }

    [self showGuide];

    if ([[FMApplication instance].loginUser isLogin]) {
        [self commentAction];
        return;
    }

    FMLoginViewController *loginViewController = [[FMLoginViewController alloc] init];
    loginViewController.loginCallback = ^(BOOL isLoginSuccess) {
        if (isLoginSuccess) {
            [self commentAction];
        }
    };
    UINavigationController *loginNavigationController = [[UINavigationController alloc]
            initWithRootViewController:loginViewController];
    [self.fmSidePanelController presentViewController:loginNavigationController
                                             animated:YES
                                           completion:nil];
}

- (void)commentAction {
    _bottomView.hidden = YES;
    _postCommentView.hidden = NO;
    [_postCommentView setTextViewPlaceholder:@"输入文字信息"];
    if (!_postCommentView.commentTextField.hidden) {
        [_postCommentView.commentTextField becomeFirstResponder];
    }
    return;
}

- (void)$$editItemDidFinished:(id <TBMBNotification>)notification {
    if (!self.showing) {
        return;
    }
    [self requestItemDO];
}

- (void)$$pushImageDetailViewController:(id <TBMBNotification>)notification page:(NSNumber *)page {
    if (!self.showing) {
        return;
    }
    [FMCommon hideKeyboard];

    CATransition *transition = [CATransition animation];
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    transition.duration = 0.3;
    transition.type = kCATransitionFade;//可更改为其他方式
    [self.navigationController.view.layer addAnimation:transition
                                                forKey:kCATransition];
    FMItemImageViewController *imageViewController = [[FMItemImageViewController alloc] init];
    imageViewController.images = _itemDO.imageUrls;
    [imageViewController scrollToPage:[page intValue]];
    [self.navigationController pushViewController:imageViewController
                                         animated:NO];
}

- (void)favoriteAction {
    if ([[FMApplication instance].loginUser isLogin]) {
        [self requestFavorite];
        return;
    }

    FMLoginViewController *loginViewController = [[FMLoginViewController alloc] init];
    loginViewController.loginCallback = ^(BOOL isLoginSuccess) {
        if (isLoginSuccess) {
            [self requestFavorite];
            return;
        }
    };
    UINavigationController *loginNavigationController = [[UINavigationController alloc]
            initWithRootViewController:loginViewController];
    [self.fmSidePanelController presentViewController:loginNavigationController
                                             animated:YES
                                           completion:nil];
}

- (void)requestFavorite {
    if (_bottomView.isFavorite) {
        [FMSubscribeService unsubscribeItem:_itemDO.id
                                     result:^(BOOL isSuccess) {
                                         if (isSuccess) {
                                             [_bottomView setSubscribed:NO];
                                         }
                                     }];
        return;
    }
    [FMSubscribeService subscribeItem:_itemDO.id
                               result:^(FMSubscribeType subscribeType, NSString *errMsg) {
        if (subscribeType != FMSubscribeTypeFailed) {
            [_bottomView setSubscribed:YES];
            [FMUserTrack ctrlClicked:@"FM_SUBSCRIBE_SUCCESS"];
        }
    }];
    return;
}

- (void)shareAction {
    FMShareActionSheet *shareActionSheet = [[FMShareActionSheet alloc] init];
    [shareActionSheet setClickItemAction:^(FMShareActionSheetItem *item, FMShareActionSheet *actionSheet) {
        [self shareContent:item];
    }];
    [shareActionSheet showInView:self.view];
}

- (void)operationAction {
    __weak FMItemDetailViewController *selfWeak = self;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
                                                             delegate:nil
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"删除宝贝", @"编辑宝贝", nil];
    [actionSheet setHandler:^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"亲，您确定要删除这个宝贝吗？"
                                                           delegate:nil
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"确定", nil];
        [alertView setHandler:^{
            [selfWeak deleteItem];
        } forButtonAtIndex:1];
        [alertView show];
    } forButtonAtIndex:0];

    [actionSheet setHandler:^{
        [selfWeak editItem];
    } forButtonAtIndex:1];

    [actionSheet showInView:self.view];
}

- (void)editItem {
    FMPostViewController *postViewController = [[FMPostViewController alloc] initWithItemDO:_itemDO];
    UINavigationController *postNavigationController = [[UINavigationController alloc] initWithRootViewController:postViewController];
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationFade];
    [self.fmSidePanelController presentViewController:postNavigationController
                                             animated:YES
                                           completion:^{
                                               [self.fmSidePanelController showCenterPanelAnimated:YES];
                                           }];
}

- (void)deleteItem {
    [FMItemService deleteItemById:_itemDO.id result:^(BOOL isSuccess) {
        if (isSuccess) {
            [FMCommon showToast:[UIApplication sharedApplication].keyWindow text:@"亲，宝贝删除成功"];
            TBMBGlobalSendNotificationForSEL(@selector($$itemDeleteDidFinish:));
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        [FMCommon showToast:self.view text:@"亲，宝贝删除失败"];
        return;
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showPageLoadingView];
    [self requestItemDO];
}

- (void)showGuide {
    //guide
    if (![[NSUserDefaults standardUserDefaults] boolForKey:FM_GUIDE_DETAIL]) {
        [_postCommentView switchVoice];
        __weak FMItemDetailViewController *weakSelf = self;
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

        UIImage *guideImage = [UIImage imageWithFileName:@"guide_detail@2x.png"];
        UIImageView *guideImageView = [[UIImageView alloc] initWithFrame:
                CGRectMake((self.view.frame.size.width - guideImage.size.width) / 2, self.view.frame.size.height - guideImage.size.height - 4,
                        guideImage.size.width, guideImage.size.height)];
        guideImageView.image = guideImage;
        [guideBgView addSubview:guideImageView];
    }
}

- (void)touchGuide {
    [_guideBgView removeFromSuperview];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:FM_GUIDE_DETAIL];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
}

- (void)keyboardWillHide:(NSNotification *)aNotification {
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    [[aNotification.userInfo
            objectForKey:UIKeyboardAnimationCurveUserInfoKey]
            getValue:&animationCurve];
    [[aNotification.userInfo
            objectForKey:UIKeyboardAnimationDurationUserInfoKey]
            getValue:&animationDuration];

    [self setKeyboardHeight:0 duration:animationDuration curve:animationCurve];
}

- (void)keyboardWillShow:(NSNotification *)aNotification {
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    [[aNotification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[aNotification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[aNotification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    CGRect keyboardBounds = [self.view convertRect:keyboardEndFrame toView:nil];

    [self setKeyboardHeight:keyboardBounds.size.height duration:animationDuration curve:animationCurve];
}

- (void)setKeyboardHeight:(float)height
                 duration:(NSTimeInterval)duration
                    curve:(UIViewAnimationCurve)curve {
    if (duration > 0.0 && height > 0) {
        [UIView beginAnimations:@"animation" context:nil];
        [UIView setAnimationDuration:duration];
        [UIView setAnimationCurve:curve];
    }

    float h = (height > 0) ? height : 0;
    _tableView.frame = CGRectMake(0, 0, FM_SCREEN_WIDTH, FM_SCREEN_HEIGHT - kStatusBarHeight - h);

    CGRect postCommentRect = _postCommentView.frame;
    postCommentRect.origin.y = FM_SCREEN_HEIGHT - kStatusBarHeight - postCommentRect.size.height - h;
    _postCommentView.frame = postCommentRect;

    if (_commentType == kItemDetailCommentTypeReply && !_commentPromptView.hidden) {
        _commentPromptView.frame = CGRectMake(0, postCommentRect.origin.y - 25 + (height > 0 ? 3 : 6), FM_SCREEN_WIDTH, 25);
    } else {
        _commentPromptView.hidden = YES;
    }

    if (duration > 0.0 && height > 0) {
        [UIView commitAnimations];
    }
}

- (void)dealloc {
    FMLog(@"%@ dealloc", NSStringFromClass([self class]));
    [MBProgressHUD hideAllHUDsForView:[self keyboardKeyWindow]
                             animated:YES];
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
}

- (UIView *)tableViewFooterView:(BOOL)isShowLabel {
    float height = [_itemDO.commentNum intValue] < 1 || !isShowLabel ? 44 : 68;
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, FM_SCREEN_WIDTH, 11.5 + height)];
    footerView.backgroundColor = [UIColor clearColor];

    CGRect moreRect = {{0, 8}, {FM_SCREEN_WIDTH, 20}};
    UILabel *moreLabel = [[UILabel alloc] initWithFrame:moreRect];
    moreLabel.textAlignment = NSTextAlignmentCenter;
    moreLabel.backgroundColor = [UIColor clearColor];
    moreLabel.font = [FMFontSize instance].loadMoreLabelSize;
    moreLabel.textColor = [FMColor instance].loadMoreLabelColor;
    [footerView addSubview:moreLabel];
    _moreLabel = moreLabel;

    UIActivityIndicatorView *indicatorLoading = [[UIActivityIndicatorView alloc]
            initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicatorLoading.frame = CGRectMake(70, 10, 20, 20);
    [footerView addSubview:indicatorLoading];
    _indicatorLoading = indicatorLoading;

    if ([_itemDO.commentNum intValue] < 1 || !isShowLabel) {
        _moreLabel.hidden = YES;
        _indicatorLoading.hidden = YES;
    } else {
        _moreLabel.hidden = NO;
        _indicatorLoading.hidden = NO;
    }

    return footerView;
}

- (UIView *)tableViewHeaderView {
    __weak FMItemDetailViewController *selfWeak = self;

    FMItemDetailInfoView *headerView = [[FMItemDetailInfoView alloc] initWithFrame:CGRectZero];
    headerView.backgroundColor = [UIColor clearColor];
    [headerView setDescriptionTouchAction:^{
        [selfWeak pushDetailDescription];
    }];
    [headerView setBoughtTouchAction:^{
        [selfWeak pushBoughtController];
    }];
    return headerView;
}

- (void)reloadTableHeaderView {
    float viewHeight = [FMItemDetailInfoView viewHeight:_itemDO];
    _infoView.frame = CGRectMake(0, 0, FM_SCREEN_WIDTH, viewHeight);
}

- (void)pushDetailDescription {

    [FMCommon hideKeyboard];

    FMWebViewController *webView = [[FMWebViewController alloc] init];
    webView.url = _itemDO.descriptionInfo;
    webView.webViewType = FMWebViewTypeHTML;
    webView.scaled = _itemDO.containsImage;
    [self.navigationController pushViewController:webView
                                         animated:YES];
    [webView setTitle:@"宝贝详细描述"];
}

- (void)pushBoughtController {

    [FMCommon hideKeyboard];

    FMWebViewController *webView = [[FMWebViewController alloc] init];
    webView.webViewType = FMWebViewTypeRequest;
    webView.url = _itemDO.resellData.shortUrl;
    webView.scaled = YES;
    [self.navigationController pushViewController:webView
                                         animated:YES];
    [webView setTitle:@"购买记录"];
}

#pragma mark - HPGrowingTextView delegate
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height {
    float diff = (growingTextView.frame.size.height - height);

    CGRect r = _postCommentView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    _postCommentView.frame = r;
}

- (FMCommentDO *)_generateCommentDO:(NSString *)text
                           voiceUrl:(NSString *)voiceUrl {
    FMCommentDO *commentDO = [[FMCommentDO alloc] init];
    commentDO.sellerId = [_itemDO.userId longLongValue];
    commentDO.sellerName = _itemDO.userNick;
    commentDO.itemId = _itemDO.id;
    commentDO.title = _itemDO.title;

    if (voiceUrl && [voiceUrl isNotBlank]) {
        commentDO.content = @"[语音]";
        commentDO.voiceUrl = voiceUrl;
    } else {
        commentDO.content = text;
        commentDO.voiceUrl = nil;
    }
    return commentDO;
}

- (FMCommentReplyDO *)_generateCommentReplyDO:(NSString *)text
                                     voiceUrl:(NSString *)voiceUrl {
    FMItemCommentDO *itemCommentDO = [_comments objectAtIndex:_commentReplyRow];

    FMCommentReplyDO *commentReplyDO = [[FMCommentReplyDO alloc] init];
    commentReplyDO.itemId = _itemDO.id;
    commentReplyDO.title = _itemDO.title;
    commentReplyDO.commentId = itemCommentDO.commentId;
    commentReplyDO.sellerId = [_itemDO.userId longLongValue];
    commentReplyDO.sellerName = _itemDO.userNick;
    commentReplyDO.beReplierId = itemCommentDO.reporterId;
    commentReplyDO.beReplierNick = itemCommentDO.reporterNick;

    if (voiceUrl && [voiceUrl isNotBlank]) {
        commentReplyDO.content = @"[语音]";
        commentReplyDO.voiceUrl = voiceUrl;
    } else {
        commentReplyDO.content = text;
        commentReplyDO.voiceUrl = nil;
    }

    return commentReplyDO;
}

- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView {
    if ([growingTextView.text isBlank]) {
        [FMCommon alert:@"" message:@"亲，请输入评论内容"];
        return YES;
    }

    if (_commentType == kItemDetailCommentTypeComment) {
        FMCommentDO *commentDO = [self _generateCommentDO:growingTextView.text
                                                 voiceUrl:nil];
        [self publishComment:commentDO];
        return YES;
    }

    FMCommentReplyDO *commentReplyDO = [self _generateCommentReplyDO:growingTextView.text
                                                            voiceUrl:nil];
    [self replyComment:commentReplyDO];
    return YES;
}

- (void)publishComment:(FMCommentDO *)commentDO {
    [FMItemCommentService publishComment:commentDO
                                  result:^(BOOL isSuccess, FMItemCommentDO *itemCommentDO, NSString *errMsg) {
                                      if (!isSuccess) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              NSString *text = (!errMsg || [errMsg isBlank]) ? @"亲，回复失败" : errMsg;
                                              [FMCommon showToast:self.view text:text];
                                          });
                                          return;
                                      }
                                      [_comments insertObject:itemCommentDO atIndex:0];
                                      _itemDO.commentNum = [NSString stringWithFormat:@"%d", [_itemDO.commentNum intValue] + 1];
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          [FMCommon showToast:self.view text:@"留言成功"];
                                          if (![commentDO hasVoice]) {
                                              _postCommentView.commentTextField.text = @"";
                                              _postCommentView.hidden = YES;
                                              _bottomView.hidden = NO;
                                              [_postCommentView.commentTextField resignFirstResponder];
                                              [FMUserTrack ctrlClicked:@"FM_COMMENT_SUCCESS"];
                                          } else {
                                              [FMUserTrack ctrlClicked:@"FM_COMMENT_SUCCESS_HASVOICE"];
                                          }

                                          _infoView = (FMItemDetailInfoView *) [self tableViewHeaderView];
                                          [_infoView setItemDO:_itemDO serverTime:_itemDetailResponseDO.serverTime];
                                          [self reloadTableHeaderView];
                                          [_tableView setTableHeaderView:_infoView];

                                          [_tableView reloadData];
                                          if ([_comments count] > 1) {
                                              [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                                                atScrollPosition:UITableViewScrollPositionMiddle
                                                                        animated:YES];
                                          }
                                      });
                                  }];
}

- (void)replyComment:(FMCommentReplyDO *)commentReplyDO {
    [FMItemCommentService replyComment:commentReplyDO
                                result:^(BOOL isSuccess, FMItemCommentDO *itemCommentDO, NSString *errMsg) {
                                    if (!isSuccess) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            NSString *text = (!errMsg || [errMsg isBlank]) ? @"亲，回复失败" : errMsg;
                                            [FMCommon showToast:self.view text:text];
                                        });
                                        return;
                                    }
                                    [_comments insertObject:itemCommentDO atIndex:0];
                                    _itemDO.commentNum = [NSString stringWithFormat:@"%d", [_itemDO.commentNum intValue] + 1];
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [FMCommon showToast:self.view text:@"亲，回复成功"];
                                        if (![commentReplyDO hasVoice]) {
                                            _postCommentView.commentTextField.text = @"";
                                            _postCommentView.hidden = YES;
                                            _bottomView.hidden = NO;
                                            [_postCommentView.commentTextField resignFirstResponder];
                                            _commentPromptView.hidden = YES;
                                        }

                                        _commentType = kItemDetailCommentTypeComment;
                                        _infoView = (FMItemDetailInfoView *) [self tableViewHeaderView];
                                        [_infoView setItemDO:_itemDO serverTime:_itemDetailResponseDO.serverTime];
                                        [self reloadTableHeaderView];
                                        [_tableView setTableHeaderView:_infoView];

                                        [_tableView reloadData];
                                        if ([_comments count] > 1) {
                                            [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                                              atScrollPosition:UITableViewScrollPositionMiddle
                                                                      animated:YES];
                                        }
                                    });
                                }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    FMItemCommentDO *itemCommentDO = [_comments objectAtIndex:(NSUInteger) indexPath.row];
    return [FMItemCommentCell cellHeight:itemCommentDO];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_comments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ItemDetailCommentCell";
    FMItemCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[FMItemCommentCell alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier:cellIdentifier
                                        commentCellType:FMCommentCellTypeDetail];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    FMItemCommentDO *itemCommentDO = [_comments objectAtIndex:(NSUInteger) indexPath.row];
    [cell setCommentDO:itemCommentDO serverTime:_itemCommentDOList.serverTime];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = (NSUInteger) indexPath.row;
    FMItemCommentDO *itemCommentDO = [_comments objectAtIndex:row];

    FMUser *user = [FMApplication instance].loginUser;
    if ([user isLogin]) {
        if ([user isMyself:[NSString stringWithFormat:@"%lld", itemCommentDO.reporterId]]) {
           [self commentActionSheet:row];
            return;
        }
        [self replyCommentAction:row];
        return;
    }

    FMLoginViewController *loginViewController = [[FMLoginViewController alloc] init];
    loginViewController.loginCallback = ^(BOOL isLoginSuccess) {
        if (isLoginSuccess) {
            if ([user isMyself:[NSString stringWithFormat:@"%lld", itemCommentDO.reporterId]]) {
                [self commentActionSheet:row];
                return;
            }
            [self replyCommentAction:row];
            return;
        }
    };
    UINavigationController *loginNavigationController = [[UINavigationController alloc]
            initWithRootViewController:loginViewController];
    [self.fmSidePanelController presentViewController:loginNavigationController
                                             animated:YES
                                           completion:nil];
}

- (void)commentActionSheet:(NSUInteger)row {
    __weak FMItemDetailViewController *selfWeak = self;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
                                                             delegate:nil
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:@"删除留言"
                                                    otherButtonTitles:@"回复留言", nil];
    [actionSheet setHandler:^{
        [selfWeak requestDeleteComment:row];
    }      forButtonAtIndex:0];
    [actionSheet setHandler:^{
        [selfWeak replyCommentAction:row];
    }      forButtonAtIndex:1];
    [actionSheet showInView:self.view];
}

- (void)replyCommentAction:(NSUInteger)row {
    _commentType = kItemDetailCommentTypeReply;
    _commentReplyRow = row;

    FMItemCommentDO *itemCommentDO = [_comments objectAtIndex:row];
    [self showReplyCommentTextView:itemCommentDO];

    if ([_comments count] > 0) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]
                          atScrollPosition:UITableViewScrollPositionMiddle
                                  animated:YES];
    }

    return;
}

- (void)showReplyCommentTextView:(FMItemCommentDO *)itemCommentDO {
    NSString *promptText = [NSString stringWithFormat:@"回复 %@", itemCommentDO.reporterNick];
    [_commentPromptView setText:promptText];
    _commentPromptView.hidden = NO;
    [FMCommon hideKeyboard];

    [_postCommentView showTextView];
//    NSString *placeholderText = [NSString stringWithFormat:@"回复%@", itemCommentDO.reporterNick];
//    [_postCommentView setTextViewPlaceholder:placeholderText];
    _bottomView.hidden = YES;
    _postCommentView.hidden = NO;
}

- (void)requestItemDO {
    __weak FMItemDetailViewController *selfWeak = self;
    [FMItemService getItemDetail:_itemDO.id result:^(BOOL isSuccess, FMItemDetailResponseDO *itemDetailResponseDO, NSString *errMsg) {
        if (!isSuccess) {
            if (errMsg && [errMsg isNotBlank]) {
                [FMCommon showToast:self.view text:errMsg];
            }
            _bottomView.hidden = YES;
            [self showRefreshPage:^{
                [selfWeak requestItemDO];
            }];
            return;
        }
        _itemDetailResponseDO = itemDetailResponseDO;
        FMItemDO *itemDO = itemDetailResponseDO.item;
        NSString *serverTime = itemDetailResponseDO.serverTime;

        [_itemDO fromBean:itemDO];

        dispatch_async(dispatch_get_main_queue(), ^{
            _bottomView.hidden = NO;
            _bottomView.isFavorite = _itemDO.subscribed;

            _infoView = (FMItemDetailInfoView *) [self tableViewHeaderView];
            [_infoView setItemDO:itemDO serverTime:serverTime];
            [self reloadTableHeaderView];
            [_tableView setTableHeaderView:_infoView];

            [_bottomView setItemDO:itemDO];
            if ([itemDO.commentNum intValue] < 1) {
                [self setTableViewHeaderView];
            }
            [_tableView reloadData];
            [self removePageLoadingView];
            _tableView.hidden = NO;
        });

        if ([itemDO.commentNum intValue] < 1) {
            return;
        }

        [self requestItemComments:NO];
    }];
}

- (void)requestItemComments:(BOOL)isRequestMore {
    [FMItemCommentService getComments:_itemDO.id
                                 page:[NSString stringWithFormat:@"%d", _commentPage]
                               result:^(BOOL isSuccess, FMItemCommentDOList *itemCommentDOList, NSString *errMsg) {
                                   if (isSuccess) {
                                       _itemCommentDOList = itemCommentDOList;
                                       if (!isRequestMore) {
                                           [_comments removeAllObjects];
                                       }
                                       [_comments addObjectsFromArray:itemCommentDOList.items];
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           [_tableView reloadData];
                                           [self setTableViewHeaderView];
                                           if (!isRequestMore) {
                                               [self scrollToComment];
                                           }
                                       });
                                       _commentPage++;
                                       if (isRequestMore) {
                                           [self finishRequestMore];
                                       }
                                       return;
                                   }
                               }];
}

- (void)requestDeleteComment:(NSUInteger)row {
    FMItemCommentDO *itemCommentDO = [_comments objectAtIndex:row];
    NSString *commentId = [NSString stringWithFormat:@"%lld", itemCommentDO.commentId];
    [FMItemCommentService deleteComment:commentId
                                 itemId:_itemDO.id
                                 result:^(BOOL isSuccess, NSString *errMsg) {
                                     if (isSuccess) {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             [_comments removeObjectAtIndex:row];
                                             [_tableView reloadData];
                                             [FMCommon showToast:self.view text:@"亲，留言删除成功"];
                                         });
                                         return;
                                     }

                                     if (!errMsg || [errMsg isNotBlank]) {
                                         errMsg = @"亲，系统忙，请稍后再试";
                                     }
                                     [FMCommon showToast:self.view text:errMsg];
                                 }];
}

- (void)scrollToComment {
    if (!self.isScrollToComment) {
        return;
    }

    if ([_comments count] > 0) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:NO];
    }
    return;
}

- (void)setTableViewHeaderView {
    if (_tableView.tableFooterView) {
        return;
    }
    _tableView.tableFooterView = [self tableViewFooterView:YES];
}

- (void)shareContent:(FMShareActionSheetItem *)itemView {
    if (itemView.type == kFMShareTypeWeibo) {
        if (![[TBSocialShareManager instance] isLoginWithShareType:TBSocialShareTypeSina]) {
            [[TBSocialShareManager instance] loginWithShareType:TBSocialShareTypeSina delegate:self];
            return;
        }
        [self showWeiboShareView];
        return;
    } else if (itemView.type == kFMShareTypeWeiXin) {
        [self shareContentWeiXin:itemView.type];
    } else if (itemView.type == kFMShareTypeWeiXinFriend) {
        [self shareContentWeiXin:itemView.type];
    } else if (itemView.type == kFMShareTypeDouban) {
        if (![[TBSocialShareManager instance] isLoginWithShareType:TBSocialShareTypeDouban]) {
            [[TBSocialShareManager instance] loginWithShareType:TBSocialShareTypeDouban delegate:self];
            return;
        }
        [self showDoubanShareView];
    }
}

- (void)showWeiboShareView {
    __weak FMItemDetailViewController *selfWeak = self;
    if (!_weiboShareTextView) {
        _weiboShareTextView = [[FMItemShareTextView alloc] initWithFrame:self.view.frame];
        _weiboShareTextView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        _weiboShareTextView.type = kShareTypeWeibo;
        [_weiboShareTextView setItemDO:_itemDO];
        [_weiboShareTextView shareWeiboAction:^(UITextView *textView, FMItemShareTextView *view) {
            [selfWeak shareWeiboContent:textView.text];
        }];
    }
    [self.view addSubview:_weiboShareTextView];
    [_weiboShareTextView setFocus];
}

- (void)showDoubanShareView {
    __weak FMItemDetailViewController *selfWeak = self;
    if (!_doubanShareTextView) {
        _doubanShareTextView = [[FMItemShareTextView alloc] initWithFrame:self.view.frame];
        _doubanShareTextView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        _doubanShareTextView.type = kShareTypeDouban;
        [_doubanShareTextView setItemDO:_itemDO];
        [_doubanShareTextView shareWeiboAction:^(UITextView *textView, FMItemShareTextView *view) {
            [selfWeak shareDoubanContent:textView.text];
        }];
    }
    [self.view addSubview:_doubanShareTextView];
    [_doubanShareTextView setFocus];
}

- (void)shareWeiboContent:(NSString *)shareContent {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[self keyboardKeyWindow]
                                              animated:YES];
    hud.labelText = @"分享中...";
    hud.userInteractionEnabled = NO;
    TBSocialShareManager *socialShareManager = [TBSocialShareManager instance];
    TBSocialShareBaseModel *baseModel = [[TBSocialShareBaseModel alloc] init];
    baseModel.status = shareContent;
    baseModel.image = [self getShareImage:self.view];
    [socialShareManager shareContent:baseModel shareType:TBSocialShareTypeSina delegate:self];
}

- (void)shareDoubanContent:(NSString *)shareContent {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[self keyboardKeyWindow]
                                              animated:YES];
    hud.labelText = @"分享中...";
    hud.userInteractionEnabled = NO;
    TBSocialShareManager *socialShareManager = [TBSocialShareManager instance];
    TBSocialShareBaseModel *baseModel = [[TBSocialShareBaseModel alloc] init];
    baseModel.status = shareContent;
    baseModel.image = [self getShareImage:self.view];
    [socialShareManager shareContent:baseModel shareType:TBSocialShareTypeDouban delegate:self];
}

- (void)shareContentWeiXin:(kFMShareType)type {
    TBSocialShareType shareType = TBSocialShareTypeWeChat;
    TBSocialShareWeChatModel *weChat = [[TBSocialShareWeChatModel alloc] init];
    weChat.messageType = TBSocialWXMessageTypeWeb;
    if (type == kFMShareTypeWeiXinFriend) {
        shareType = TBSocialShareTypeWeChatFriend;
    }
    weChat.title = [[FMApplication instance].loginUser.id isEqualToString:_itemDO.userId]
            ? @"亲,来看看我的宝贝吧!"
            : @"这个宝贝不错吧!";;
    weChat.thumbImage = [self getShareImage:self.view];
    weChat.status = _itemDO.title;
    weChat.webUrl = _itemDO.wxurl ? : APP_STORE_DOWNLOAD_URL;;
    [[TBSocialShareManager instance] shareContent:weChat
                                        shareType:shareType
                                         delegate:self];
}

- (UIImage *)getShareImage:(UIView *)view {
    FMItemDetailInfoView *headerView = (FMItemDetailInfoView *)_tableView.tableHeaderView;
    return [headerView getFirstImage];
}

- (UIWindow *)keyboardKeyWindow {
    if ([[[UIApplication sharedApplication] windows] count] > 1) {
        return [[[UIApplication sharedApplication] windows] objectAtIndex:1];
    }
    return [UIApplication sharedApplication].keyWindow;
}

#pragma mark -- share delegate
- (void)loginSuccess:(TBSocialShareType)shareType {
    if (shareType == TBSocialShareTypeSina) {
        [self showWeiboShareView];
        return;
    }

    if (shareType == TBSocialShareTypeDouban) {
        [self showDoubanShareView];
        return;
    }
}

- (void)loginFailed:(TBSocialShareType)shareType error:(NSError *)error {
    if (shareType == TBSocialShareTypeSina) {
        [FMCommon showToast:self.view text:@"微博认证失败"];
        return;
    }

    if (shareType == TBSocialShareTypeDouban) {
        [FMCommon showToast:self.view text:@"豆瓣认证失败"];
        return;
    }
}

- (void)socialShareSuccess:(TBSocialShareType)shareType result:(id)result {
    [MBProgressHUD hideAllHUDsForView:[self keyboardKeyWindow]
                             animated:YES];
    if (shareType == TBSocialShareTypeSina) {
        [_weiboShareTextView removeFromSuperview];
        _weiboShareTextView = nil;
        [FMUserTrack ctrlClicked:@"FM_SHARE_SINA"
                          onPage:[TBSocialShareToSina instance]];
    } else if (shareType == TBSocialShareTypeDouban) {
        [_doubanShareTextView removeFromSuperview];
        _doubanShareTextView = nil;
        [FMUserTrack ctrlClicked:@"FM_SHARE_DOUBAN"
                          onPage:[TBSocialShareToDouban instance]];
    } else if (shareType == TBSocialShareTypeWeChat)  {
        [FMUserTrack ctrlClicked:@"FM_SHARE_WECHAT"
                          onPage:[TBSocialShareToWeChat instance]];
    }  else if (shareType == TBSocialShareTypeWeChatFriend)  {
        [FMUserTrack ctrlClicked:@"FM_SHARE_WECHAT_FRIEND"
                          onPage:[TBSocialShareToWeChat instance]];
    }
    [FMCommon showToast:self.view text:@"分享成功"];
}

- (void)socialShareFailed:(TBSocialShareType)shareType  error:(id)error {
    [MBProgressHUD hideAllHUDsForView:[self keyboardKeyWindow]
                             animated:YES];
    [FMCommon showToast:self.view text:@"分享失败"];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self scrollViewForMore:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!_isLoadingMore && _isBeginRequestMore && [self hasNextPage]) {
        _isLoadingMore = YES;
        _isBeginRequestMore = NO;
        _moreLabel.text = @"加载中...";
        [_indicatorLoading startAnimating];
        _indicatorLoading.hidden = NO;
        [self requestItemComments:YES];
    }
}

- (void)scrollViewForMore:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y + scrollView.frame.size.height <= scrollView.contentSize.height +
            30 && scrollView.contentOffset.y > 0.0f) {
        _isBeginRequestMore = NO;
        if (!_isLoadingMore) {
            [self resetMoreText];
        }
    } else if (scrollView.contentOffset.y > 0.0f && scrollView.contentOffset.y + (scrollView.frame.size.height) >
            scrollView.contentSize.height + 30) {
        if ([self hasNextPage]) {
            if (!_isLoadingMore) {
                _moreLabel.text = @"松开加载更多";
            }
            _isBeginRequestMore = YES;
        }
    }
}

- (void)resetMoreText {
    if ([self hasNextPage]) {
        _indicatorLoading.hidden = YES;
        _moreLabel.text = @"上拉加载更多";
        return;
    }
    _moreLabel.text = @"已加载全部";
    _moreLabel.hidden = YES;
    _indicatorLoading.hidden = YES;
    CGRect footerRect = _tableView.tableFooterView.frame;
    footerRect.size.height = 11.5 + 44;
    _tableView.tableFooterView.frame = footerRect;
    _tableView.tableFooterView = [self tableViewFooterView:NO];
    return;
}

- (void)finishRequestMore {
    _isLoadingMore = NO;
    [_indicatorLoading stopAnimating];
    [self resetMoreText];
    return;
}

- (BOOL)hasNextPage {
    if (!_itemCommentDOList) {
        return NO;
    }
    return _itemCommentDOList.nextPage;
}

@end