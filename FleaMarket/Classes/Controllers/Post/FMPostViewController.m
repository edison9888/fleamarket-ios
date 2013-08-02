// 
// Created by henson on 6/6/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <MBMvc/TBMBSimpleInstanceCommand+TBMBProxy.h>
#import <MBMvc/TBMBSimpleStaticCommand+TBMBProxy.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <MBMvc/TBMBGlobalFacade.h>
#import <iOS_Util/NSObject+TBIU_BeanCopy.h>
#import <BlocksKit/UIAlertView+BlocksKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MBMvc/TBMBDefaultRootViewController+TBMBProxy.h>
#import <BlocksKit/UIActionSheet+BlocksKit.h>
#import "FMPostViewController.h"
#import "FMItemDO.h"
#import "FMVoiceUploadService.h"
#import "FMVoiceRecorder.h"
#import "huoyanViewController.h"
#import "FMItemService.h"
#import "FMPostTextIndicationView.h"
#import "FMPostOptionalInfoView.h"
#import "FMPostRequiredInfoView.h"
#import "FMCameraAlbumViewController.h"
#import "FMCameraTakeController.h"
#import "FMBackCategoryViewController.h"
#import "FMCitySelectionViewController.h"
#import "FMCategory.h"
#import "FMLocationSelectionViewController.h"
#import "NSString+Helper.h"
#import "FMLocation.h"
#import "FMApplication.h"
#import "FMVoicePowerView.h"
#import "NSObject+TBIU_ToJson.h"
#import "FMPostService.h"
#import "FMPostRet.h"
#import "Reachability.h"
#import "FMSetting.h"
#import "FMPostImageView.h"
#import "FMAsset.h"
#import "FMPostImagePreviewController.h"
#import "FMPostTitlePriceView.h"
#import "UIView+BlocksKit.h"
#import "FMPostToolbarView.h"
#import "FMPostImageDO.h"
#import "FMUserTrack.h"
#import "FMItemPostDO.h"
#import "FMPicService.h"
#import "FMVoiceService.h"
#import "FMPostQueue.h"
#import "TBMBDefaultNotification.h"
#import "FMResellViewController.h"
#import "FMTaoBaoTrade.h"

#define kPostItemTitleMaxLength  (30)
#define kItemDefaultCategoryName @"其他闲置"
#define kItemCategoryRootId      (50023878)
#define kReachabilityHost        @"http://www.taobao.com"

#define FM_GUIDE_POST  @"FM_GUIDE_POST"

typedef enum {
    TBA_INIT = 0,
    TBA_UPLOADING,
    TBA_UPLOAD_DONE
} TBAlbumStatus;

@interface FMPostViewController ()

@property(nonatomic) TBAlbumStatus tbAlbumStatus;

@end

@implementation FMPostViewController {
    FMPostToolbarView *_toolbarView;
    FMPostRequiredInfoView *_requiredInfoView;
    FMPostOptionalInfoView *_optionalInfoView;

    UIButton *_hideKeyboardButton;

    FMItemDO *_itemDO;
    NSMutableArray *_imageInfos;

    FMPostType _postType;

    // record voice
    FMVoicePowerView *_voicePowerView;
    BOOL _isVoiceCancel;

    // If post default location is changed
    BOOL _isPostLocationChanged;

    NSString *_requestItemId;
@private
    TBAlbumStatus _tbAlbumStatus;

    __weak UIView *_guideBgView;
}

@synthesize tbAlbumStatus = _tbAlbumStatus;

- (id)init {
    self = [super init];
    if (self) {
        _tbAlbumStatus = TBA_INIT;
        _postType = FMPostTypePost;
        self.isFromQueue = NO;
        _isPostLocationChanged = NO;

        _imageInfos = [NSMutableArray arrayWithCapacity:5];

        _itemDO = [[FMItemDO alloc] init];
        _itemDO.categoryName = kItemDefaultCategoryName;
        _itemDO.categoryId = kItemDefaultCategoryId;
        _itemDO.stuffStatus = 9;
        _itemDO.offline = FMItemTradeTypeAnyway;
    }

    return self;
}

- (id)initWithItemDO:(FMItemDO *)itemDO {
    if (self = [self init]) {
        [_itemDO fromBean:itemDO];
        [self initImageInfo];
        _postType = FMPostTypeEdit;
    }

    return self;
}

- (id)initWithItemId:(NSString *)itemId {
    if (self = [self init]) {
        _postType = FMPostTypeEdit;
        _requestItemId = itemId;
    }

    return self;
}

- (void)loadView {
    [super loadView];

    self.titleView.hidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];

    // init voice power view
    _voicePowerView = [[FMVoicePowerView alloc] initWithFrame:CGRectMake(0, 0, 140, 140)];

    CGRect requiredInfoRect = {{0, 0}, {FM_SCREEN_WIDTH, FM_SCREEN_HEIGHT - kTabBarHeight}};
    FMPostRequiredInfoView *requiredInfoView = [[FMPostRequiredInfoView alloc] initWithFrame:requiredInfoRect
                                                                                      itemDO:_itemDO
                                                                                isShowResell:_postType == FMPostTypePost];
    requiredInfoView.backgroundColor = [UIColor whiteColor];
    requiredInfoView.contentSize = CGSizeMake(FM_SCREEN_WIDTH, requiredInfoRect.size.height + 0.5);
    requiredInfoView.showsVerticalScrollIndicator = NO;
    requiredInfoView.delegate = self;
    [self.view addSubview:requiredInfoView];
    _requiredInfoView = requiredInfoView;

    CGRect optionalInfoRect = {{0, requiredInfoRect.size.height}, {FM_SCREEN_WIDTH, FM_SCREEN_HEIGHT - kTabBarHeight}};
    FMPostOptionalInfoView *optionalInfoView = [[FMPostOptionalInfoView alloc] initWithFrame:optionalInfoRect itemDO:_itemDO];
    optionalInfoView.backgroundColor = [UIColor whiteColor];
    optionalInfoView.contentSize = CGSizeMake(FM_SCREEN_WIDTH, requiredInfoRect.size.height + 0.5);
    optionalInfoView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:optionalInfoView];
    _optionalInfoView = optionalInfoView;

    CGRect toolbarRect = {{0, FM_SCREEN_HEIGHT - kTabBarHeight - 3}, {FM_SCREEN_WIDTH, 47}};
    FMPostToolbarView *toolbarView = [[FMPostToolbarView alloc] initWithFrame:toolbarRect];
    [self.view addSubview:toolbarView];

    [self initHideKeyboardButton];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (_postType == FMPostTypePost) {
        [self fetchLocationInfo];
    }

    if (_postType == FMPostTypeEdit) {
        if (_requestItemId) {
            [self requestItem:_requestItemId];
        } else {
            [self refreshRequiredInfoView];
        }
    }

    [self showGuide];

    if (_postType == FMPostTypePost) {
        [self performSelector:@selector(hideResellPrompt) withObject:nil afterDelay:1.f];
    }
}

- (void)requestItem:(NSString *)itemId {
    _requiredInfoView.hidden = YES;
    _optionalInfoView.hidden = YES;
    [self showPageLoadingView];
    __weak FMPostViewController *selfWeak = self;
    [FMItemService getItemDetail:itemId result:^(BOOL isSuccess,
            FMItemDetailResponseDO *itemDetailResponseDO, NSString *errMsg) {
        if (!isSuccess) {
            [self removePageLoadingView];
            [self showRefreshPage:^{
                [selfWeak requestItem:itemId];
            }];
            return;
        }
        [self removePageLoadingView];
        _requiredInfoView.hidden = NO;
        _optionalInfoView.hidden = NO;
        [_itemDO fromBean:itemDetailResponseDO.item];
        [self initImageInfo];
        [self refreshRequiredInfoView];
        [self refreshOptionalInfoView];
    }];
}

- (void)hideResellPrompt {
    [_requiredInfoView setResellPromptHidden:YES];
}

- (void)$$postResellActionNotification:(id <TBMBNotification>)notification
                                 order:(FMTaoBaoTradeOrder *)tradeOrder {
    [_requiredInfoView setResellPromptHidden:YES];

    NSString *title = [NSString stringWithFormat:@"[转卖]%@",tradeOrder.title];
    if ([FMCommon textLength:title] > kPostItemTitleMaxLength) {
        NSUInteger index = [self textMaxIndex:title];
        title = [title substringToIndex:index + 1];
    }

    _itemDO.title = title;
    _itemDO.originalPrice = tradeOrder.oriPrice;
    _itemDO.imageUrls = [NSArray arrayWithObjects:tradeOrder.picUrl,nil];
    _itemDO.taoBaoTradeOrder = tradeOrder;

    [_imageInfos removeAllObjects];
    [self initImageInfo];
    [self refreshRequiredInfoView];
    [self refreshOptionalInfoView];
}

- (void)initImageInfo {
    if (!_itemDO.imageUrls) {
        return;
    }

    for (NSUInteger i = 0; i < _itemDO.imageUrls.count; i++) {
        FMPostImageDO *imageInfo = nil;
        if ([[_itemDO.imageUrls objectAtIndex:i] isKindOfClass:[NSURL class]]) {
            imageInfo = [FMPostImageDO objectWithImageURL:[_itemDO.imageUrls objectAtIndex:i]];
        } else {
            imageInfo = [FMPostImageDO objectWithImageURL:[NSURL URLWithString:[_itemDO.imageUrls objectAtIndex:i]]];
        }
        if (i == 0) {
            imageInfo.isMasterImage = YES;
        }
        [_imageInfos addObject:imageInfo];
    }
}

- (void)showGuide {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:FM_GUIDE_POST]) {
        __weak FMPostViewController *weakSelf = self;
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
        NSString *fileName;
        CGFloat xOffset;
        if (IS_IPHONE_5) {
            fileName = @"guide_post_568@2x.png";
            xOffset = 5;
        } else {
            fileName = @"guide_post_480@2x.png";
            xOffset = 2;
        }
        UIImage *guideImage = [UIImage imageWithFileName:fileName];
        UIImageView *guideImageView = [[UIImageView alloc] initWithFrame:
                CGRectMake((guideBgView.frame.size.width - guideImage.size.width) / 2 - xOffset, guideBgView.frame.size.height - guideImage.size.height - 50,
                        guideImage.size.width, guideImage.size.height)];
        guideImageView.image = guideImage;
        [guideBgView addSubview:guideImageView];
    }
}

- (void)touchGuide {
    [_guideBgView removeFromSuperview];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:FM_GUIDE_POST];
}

- (void)requestPost {
    [FMUserTrack ctrlClicked:@"发布" onPage:self];

    [self saveToPostQueue];

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"发布中ing...";

    long long originalPrice = (long long int) ([_itemDO.originalPrice doubleValue] * 100);
    long long price = (long long int) ([_itemDO.price doubleValue] * 100);
    long long postFee = (long long int) ([_itemDO.postPrice doubleValue] * 100);
    if (_itemDO.offline == FMItemTradeTypeF2F) {
        postFee = 0;
    }

    NSMutableString *itemDescription = [NSMutableString stringWithFormat:@""];
    if (_postType == FMPostTypePost || _itemDO.isDescriptionChanged) {
        [itemDescription appendString:_itemDO.description ? : @""];
        if (itemDescription == nil || [itemDescription isBlank]) {
            [itemDescription appendString:kItemDefaultDescriptionText];
        }
    } else {
        [itemDescription appendString:_itemDO.descriptionInfo ? : kItemDefaultDescriptionText];
    }

    FMItemPostDO *param = [[FMItemPostDO alloc] init];
    param.itemId = _itemDO.id;
    param.area = _itemDO.area;
    param.city = _itemDO.city;
    param.prov = _itemDO.province;
    param.gps = _itemDO.gps;
    param.divisionId = _itemDO.divisionId;
    param.offline = [NSString stringWithFormat:@"%d", _itemDO.offline];
    param.stuffStatus = [NSString stringWithFormat:@"%d", _itemDO.stuffStatus];
    param.categoryId = _itemDO.categoryId;
    param.contacts = [_itemDO.contacts stripStrangeWords];
    param.description = itemDescription;
    param.originalPrice = [NSString stringWithFormat:@"%lld", originalPrice];
    param.phone = _itemDO.phone;
    param.postPrice = [NSString stringWithFormat:@"%lld", postFee];
    param.reservePrice = [NSString stringWithFormat:@"%lld", price];
    param.title = [_itemDO.title stripStrangeWords];
    param.voiceUrl = _itemDO.voiceUrl;
    param.voiceTime = [_itemDO.voiceTime unsignedIntValue];

    if (_itemDO.taoBaoTradeOrder) {
        param.resell = YES;
        param.archive = _itemDO.taoBaoTradeOrder.archive;
        param.orderId = _itemDO.taoBaoTradeOrder.id;
    } else {
        param.resell = _itemDO.resell;
    }

    for (NSUInteger i = 0; i < [_imageInfos count]; i++) {
        FMPostImageDO *photo = [_imageInfos objectAtIndex:i];
        if (photo.isUploaded) {
            if (photo.isMasterImage) {
                [param.mainPic addObject:photo.imageURL.absoluteString];
            } else {
                [param.otherPics addObject:photo.imageURL.absoluteString];
            }
        }
    }

    if ([param.mainPic count] == 0 && [param.otherPics count] > 0) {
        [param.mainPic addObject:[param.otherPics objectAtIndex:0]];
        [param.otherPics removeObjectAtIndex:0];
    }

    FMLOG(@"post parmas:%@", [param toJSONString]);

    void (^success)(FMPostRet *) = ^(FMPostRet *responseData) {
        [self deletePostQueue];
        _itemDO.id = [responseData.itemId stringValue];
        FMLog(@"post success:%@", _itemDO.id);

        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [FMCommon showToast:self.view text:@"发布成功"];
        [FMUserTrack ctrlClicked:@"FM_POST_SUCCESS" onPage:self];
        if (_itemDO.voiceUrl) {
            [FMUserTrack ctrlClicked:@"FM_POST_SUCCESS_HASVOICE" onPage:self];
        } else if (_itemDO.taoBaoTradeOrder) {
            [FMUserTrack ctrlClicked:@"FM_POST_SUCCESS_FROM_TRADE" onPage:self];
        }

        if (_postType == FMPostTypePost) {
            [self dismissViewControllerAnimated:YES completion:^{
                [self postItemDidFinished];
            }];
        } else {
            [self dismissViewControllerAnimated:YES completion:^{
                if (_requestItemId) {
                    TBMBGlobalSendNotificationForSELWithBody(@selector($$editItemDidFinishedWithItemId:itemId:), _requestItemId);
                    return;
                }
                TBMBGlobalSendNotificationForSEL(@selector($$editItemDidFinished:));
                return;
            }];
        }
    };

    void (^failed)(NSString *) = ^(NSString *error) {
        [FMCommon alert:@"" message:error];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (!self.isFromQueue) {
            [self deletePostQueue];
        }
    };

    [FMPostService publishOrUpdateWithPic:param
                                  success:success
                                   failed:failed
                                 progress:NULL];
}

- (void)postItemDidFinished {
    TBMBDefaultNotification *notification = [TBMBDefaultNotification objectWithSEL:@selector($$postItemDidFinished:)
                                                                              body:nil];
    notification.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:_itemDO, @"itemDO", nil];
    TBMBGlobalSendTBMBNotification(notification);
}

- (void)saveToPostQueue {
    NSMutableArray *imageUrl = [[NSMutableArray alloc] initWithCapacity:5];
    for (FMPostImageDO *photoInfo in _imageInfos) {
        if (photoInfo.isUploaded) {
            [imageUrl addObject:photoInfo.imageURL];
        }
    }
    _itemDO.imageUrls = imageUrl;

    _itemDO.isEditItemChanged = NO;
    [[FMPostQueue sharedInstance] putPostQueue:_itemDO];
}

- (void)deletePostQueue {
    [[FMPostQueue sharedInstance] deleteItem:_itemDO];
}

- (void)fetchLocationInfo {
    FMLocation *location = [FMApplication instance].location;
    if (location.locationId || [location.locationId longLongValue] > 0) {
        [self setItemLocationInfo:location];
        return;
    }

    [[FMApplication instance] updateLocationWithBlock:^(TBIULocationManager *manager, CLLocation *newLocation, CLLocation *oldLocation) {

    }                                      errorBlock:^(TBIULocationManager *manager, NSError *error) {
        if (error) {
            FMLog(@"location update error");
        }
    }];
    return;
}

- (void)$$updateLocationSuccessNotification:(id <TBMBNotification>)notification
                                   location:(FMLocation *)location {
    if (!self.showing) {
        return;
    }
    [self setItemLocationInfo:location];
}

- (void)$$postResellPushNotification:(id <TBMBNotification>)notification {
    FMResellViewController *resellViewController = [[FMResellViewController alloc] init];
    [self.navigationController pushViewController:resellViewController animated:YES];
}

- (void)setItemLocationInfo:(FMLocation *)location {
    _itemDO.province = location.province;
    _itemDO.city = location.city;
    _itemDO.area = location.area;
    _itemDO.divisionId = [NSString stringWithFormat:@"%@", location.locationId];
    return;
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
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void)dealloc {
    FMLog(@"dealloc %@", [self description]);
}

- (void)leftAction:(id)sender {
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)$$postToolbarCloseNotification:(id <TBMBNotification>)notification {
    [FMCommon hideKeyboard];

    if (_postType == FMPostTypePost && [self isPostEmpty]) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }

    if (_postType == FMPostTypeEdit && !_itemDO.isEditItemChanged) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }

    NSString *message = @"亲，您需要保存此次宝贝到发布队列吗？";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"保存", nil];
    [alert  setHandler:^{
        [self saveToPostQueue];
        [self dismissViewControllerAnimated:YES completion:nil];
    } forButtonAtIndex:1];
    [alert  setHandler:^{
        [self dismissViewControllerAnimated:YES completion:nil];
    } forButtonAtIndex:0];
    [alert show];
}

- (void)$$postToolbarPostNotification:(id <TBMBNotification>)notification {
    if (_requiredInfoView.hidden) {
        [FMCommon alert:@"" message:@"亲，请重新刷新界面"];
        return;
    }

    __weak FMPostViewController *selfWeak = self;

    if (_imageInfos.count == 0) {
        [FMCommon alert:@"" message:@"亲，至少要有一张图片才能发布哦"];
        return;
    }

    if ((_itemDO.title == nil) || [_itemDO.title isBlank]) {
        [FMCommon alert:@"" message:@"亲，请输入宝贝标题"];
        return;
    }

    if ([FMCommon textLength:_itemDO.title] > kPostItemTitleMaxLength) {
        [FMCommon alert:@"" message:@"亲，宝贝标题不能超过30个汉字哦"];
        return;
    }

    if ([_itemDO.price doubleValue] == 0.0) {
        [FMCommon alert:@"" message:@"亲，请输入宝贝价格"];
        return;
    }

    if ((_itemDO.phone.length > 0) && [_itemDO.phone length] != 11) {
        [FMCommon alert:@"" message:@"亲，手机号码只能是11位数字哦"];
        return;
    }

    if (([_itemDO.categoryId longValue] == kItemCategoryRootId)
            || ([_itemDO.categoryId intValue] == 0)) {
        [FMCommon alert:@"" message:@"亲，请选择宝贝类别"];
        return;
    }

//    if ((_itemDO.province == nil) || (_itemDO.province.length == 0)
//            || (_itemDO.city == nil) || (_itemDO.city.length == 0)
//            || (_itemDO.area == nil) || (_itemDO.area.length == 0)) {
//        [FMCommon alert:@"" message:@"请选择宝贝所在位置"];
//        return;
//    }

    if (_itemDO.description.length > 10000) {
        [FMCommon alert:@"" message:@"亲，您的描述太长了，最多2000个汉字"];
        return;
    }


    BOOL isPostItemInWifi = ![self isReachableViaWiFi] && [FMApplication instance].setting.isPostItemInWifi;
    BOOL isNotUploadDone = ![self isAllUploadDone];
    NSString *message = nil;
    if (isPostItemInWifi || isNotUploadDone) {
        if ([self isAllUploadFailed]) {
            [FMCommon alert:@"" message:@"没有图片上传成功，至少需要一张上传成功的图片"];
            return;
        }

        if (isPostItemInWifi && isNotUploadDone) {
            message = @"亲，目前您不在WIFI环境下，且有图片未上传成功，现在发布会丢弃此图片，要继续发布宝贝吗？";
        } else if (isPostItemInWifi) {
            message = @"亲，目前您不在WIFI环境下，要继续发布宝贝吗？";
        } else {
            message = @"亲，有图片未上传成功，现在发布会丢弃此图片，要继续发布宝贝吗？";
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"继续", nil];
        [alert  setHandler:^{
            [selfWeak requestPost];
        } forButtonAtIndex:1];
        [alert show];
        return;
    }

    [FMCommon hideKeyboard];
    [self requestPost];
}

- (BOOL)isReachableViaWiFi {
    Reachability *reachability = [Reachability reachabilityWithHostname:kReachabilityHost];
    return [reachability isReachableViaWiFi];
}

- (BOOL)isAllUploadDone {
    for (FMPostImageDO *photo in _imageInfos) {
        if (!photo.isUploaded) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)isAllUploadFailed {
    for (FMPostImageDO *photo in _imageInfos) {
        if (photo.isUploaded) {
            return NO;
        }
    }
    return YES;
}

- (void)$$postImageViewTouch:(id <TBMBNotification>)notification index:(NSNumber *)index {
    FMPostImagePreviewController *previewController = [[FMPostImagePreviewController alloc] init];
    previewController.imageInfos = _imageInfos;
    previewController.index = [index unsignedIntValue];
    [previewController setPostImagePreviewDismiss:^{
        [self refreshRequiredInfoView];
    }];
    [previewController setDeleteDismiss:^(NSUInteger idx) {
        [self previewImageDeleteAction:idx];
    }];
    [self.navigationController presentViewController:previewController animated:YES completion:nil];
}

- (void)previewImageDeleteAction:(NSUInteger)index {
    if ([_imageInfos count] > 1) {
        FMPostImageDO *imageDO = [_imageInfos objectAtIndex:index];
        if (imageDO.isMasterImage) {
            NSUInteger masterIndex = (index + 1 < [_imageInfos count] - 1) ? index + 1 : 0;
            FMPostImageDO *nextImageDO = [_imageInfos objectAtIndex:masterIndex];
            nextImageDO.isMasterImage = YES;
        }
    }
    [_imageInfos removeObjectAtIndex:index];
    [self refreshRequiredInfoView];
}

- (void)$$postCategoryNotification:(id <TBMBNotification>)notification {
    if (!self.showing) {
        return;
    }
    FMBackCategoryViewController *backCategoryViewController = [[FMBackCategoryViewController alloc] init];
    [backCategoryViewController setCategoryDidSelect:^(NSArray *array) {
        _itemDO.isEditItemChanged = YES;
        FMCategory *category = [array lastObject];
        _itemDO.categoryName = category.name;
        _itemDO.categoryId = category.id;
        _itemDO.isUserCategory = YES;
    }];
    [self.navigationController pushViewController:backCategoryViewController animated:YES];
}

- (void)$$postLocationNotification:(id <TBMBNotification>)notification {
    NSString *province = _itemDO.province ?: @"";
    NSString *city = _itemDO.city ?: @"";
    NSString *area = _itemDO.area ?: @"";

    FMLocationFilterDO *filterDO = [[FMLocationFilterDO alloc] init];
    filterDO.province = [province isNotBlank] ? province : nil;
    filterDO.city = [city isNotBlank] ? city : nil;
    filterDO.area = [area isNotBlank] ? area : nil;
    FMLocationSelectionViewController *locationSelectionViewController = [[FMLocationSelectionViewController alloc]
            initWithFilterDO:filterDO];
    locationSelectionViewController.viewDO.style = FMLocSelectionCtrStyleLocationLimit;
    [locationSelectionViewController setDidSelectAction:^(FMLocationFilterDO *locationFilterDO) {
        _isPostLocationChanged = YES;
        _itemDO.isEditItemChanged = YES;

        _itemDO.province = locationFilterDO.province;
        _itemDO.city = locationFilterDO.city;
        _itemDO.area = locationFilterDO.area;
        _itemDO.divisionId = [NSString stringWithFormat:@"%@", locationFilterDO.locationID];
    }];
    locationSelectionViewController.from = kFMPostCitySelectionFromPost;
    [self.navigationController pushViewController:locationSelectionViewController animated:YES];
}

- (void)$$postImageTakeImage:(id <TBMBNotification>)notification {
    [self hideKeyboard];

    if ([_imageInfos count] >= 5) {
        [FMCommon showToast:self.view text:@"亲，宝贝图片最多5张哦"];
        return;
    }

    __weak FMPostViewController *selfWeak = self;
    UIActionSheet *actionSheet = [UIActionSheet actionSheetWithTitle:@""];
    [actionSheet addButtonWithTitle:@"从相册中选取" handler:^{
        [selfWeak presentAlbumPickerController];
    }];
    [actionSheet addButtonWithTitle:@"拍照" handler:^{
        [selfWeak presentTakingCameraController];
    }];
    [actionSheet setCancelButtonWithTitle:@"取消" handler:nil];
    [actionSheet showInView:self.view];
}

- (void)presentAlbumPickerController {
    FMCameraAlbumViewController *albumViewController = [[FMCameraAlbumViewController alloc] initWithSelectedCount:[_imageInfos count]];
    [albumViewController selectedAssetsDidFinish:^(NSArray * assets) {
        [self postImagePickerDidFinishedWithAssets:assets];
    }];
    [self.navigationController presentViewController:albumViewController
                                            animated:YES
                                          completion:nil];
}

- (void)presentTakingCameraController {
    FMCameraTakeController *cameraTakeController = [[FMCameraTakeController alloc] initWithSelectedCount:[_imageInfos count]];
    cameraTakeController.from = FMCameraFromPost;
    cameraTakeController.delegate = self;
    [cameraTakeController selectedAssetsDidFinish:^(NSArray * assets) {
        [self postImagePickerDidFinishedWithAssets:assets];
    }];
    UINavigationController *cameraNaviController = [[UINavigationController alloc] initWithRootViewController:cameraTakeController];
    cameraNaviController.navigationBar.hidden = YES;
    cameraNaviController.wantsFullScreenLayout = YES;
    [self.navigationController presentViewController:cameraNaviController
                                            animated:YES
                                          completion:nil];
}

- (void)postImagePickerDidFinishedWithAssets:(NSArray *)images {
    _itemDO.isEditItemChanged = YES;
    for (id obj in images) {
        if ([obj isKindOfClass:[FMAsset class]]) {
            FMAsset *asset = (FMAsset *) obj;
            ALAssetRepresentation *rep = [asset.asset defaultRepresentation];
            UIImage *image = [UIImage imageWithCGImage:rep.fullResolutionImage];
            FMPostImageDO *postImageDO = [FMPostImageDO objectWithImage:[image resetSquareImage:CGSizeMake(image.size.width/2.f, image.size.width/2.f)]
                                                             thumbImage:[UIImage imageWithCGImage:asset.asset.thumbnail]];
            [_imageInfos addObject:postImageDO];
        }
    }
    if (_imageInfos.count > 0 && ![self hasMasterImage]) {
        FMPostImageDO *postImageDO = [_imageInfos objectAtIndex:0];
        postImageDO.isMasterImage = YES;
    }
    [self refreshRequiredInfoView];
    [self uploadToTBAlbum];
}

- (void)$$postImagePickerDidFinishedNotification:(id <TBMBNotification>)notification images:(NSArray *)images {
    _itemDO.isEditItemChanged = YES;
    for (id obj in images) {
        if ([obj isKindOfClass:[FMAsset class]]) {
            FMAsset *asset = (FMAsset *) obj;
            ALAssetRepresentation *rep = [asset.asset defaultRepresentation];
            UIImage *image = [UIImage imageWithCGImage:rep.fullResolutionImage];
            FMPostImageDO *postImageDO = [FMPostImageDO objectWithImage:[image resetSquareImage:CGSizeMake(image.size.width, image.size.width)]
                                                             thumbImage:[UIImage imageWithCGImage:asset.asset.thumbnail]];
            [_imageInfos addObject:postImageDO];
        }
    }
    if (_imageInfos.count > 0 && ![self hasMasterImage]) {
        FMPostImageDO *postImageDO = [_imageInfos objectAtIndex:0];
        postImageDO.isMasterImage = YES;
    }
    [self refreshRequiredInfoView];
    [self uploadToTBAlbum];
}

- (BOOL)hasMasterImage {
    if ([_imageInfos count] < 1) {
        return NO;
    }

    BOOL hasMaster = NO;
    for (NSUInteger i = 0; i < [_imageInfos count]; i++) {
        FMPostImageDO *imageDO = [_imageInfos objectAtIndex:i];
        if (imageDO.isMasterImage) {
            hasMaster = YES;
            break;
        }
    }

    return hasMaster;
}

- (void)refreshRequiredInfoView {
    [_requiredInfoView.postImageView setImages:_imageInfos];
    [_requiredInfoView refreshView];
}

- (void)refreshOptionalInfoView {
    [_optionalInfoView refreshView];
}

#pragma mark - upload images
- (void)uploadToTBAlbum {
    NSArray *tbPhotoInfos = _imageInfos;
    NSMutableArray *picUrls = [[NSMutableArray alloc] initWithCapacity:[tbPhotoInfos count]];
    NSMutableArray *uploadIdx = [[NSMutableArray alloc] initWithCapacity:[tbPhotoInfos count]];
    for (NSUInteger i = 0; i < [tbPhotoInfos count]; i++) {
        FMPostImageDO *photo = [tbPhotoInfos objectAtIndex:i];
        if (!photo.isUploaded && photo.image) {
            [picUrls addObject:photo.image];
            [uploadIdx addObject:[NSNumber numberWithUnsignedInteger:i]];
        }
    }
    NSUInteger totalUploadingPicCount = [picUrls count];
    if (totalUploadingPicCount == 0) {
        return;
    }

    self.tbAlbumStatus = TBA_UPLOADING;
    [FMPicService uploadPicWithImages:picUrls
                               result:^(NSArray *urls, NSArray *errors) {
                                   NSUInteger doneNum = 0;
                                   NSUInteger failedNum = 0;
                                   NSString *errorMessage;
                                   NSMutableArray *successUrls = [NSMutableArray arrayWithCapacity:5];
                                   for (NSUInteger idx = 0; idx < [urls count]; idx++) {
                                       NSString *url = [urls objectAtIndex:idx];
                                       if ([url isNotBlank]) {
                                           NSNumber *tbPhotoIdx = [uploadIdx objectAtIndex:idx];
                                           FMPostImageDO *tbPhoto = [tbPhotoInfos objectAtIndex:[tbPhotoIdx unsignedIntegerValue]];
                                           tbPhoto.imageURL = [NSURL URLWithString:url];
                                           doneNum++;
                                           [successUrls addObject:url];
                                       } else {
                                           failedNum++;
                                           if ([[errors objectAtIndex:idx] isNotBlank]) {
                                               errorMessage = [errors objectAtIndex:idx];
                                           }
                                       }
                                   }

//                                 NSString *message = [NSString stringWithFormat:@"成功上传%d张照片!%@",
//                                                                                doneNum,
//                                                                                (failedNum > 0 ?
//                                                                                        [NSString stringWithFormat:@"失败%d张照片!",
//                                                                                                                   failedNum] : @"")];
                                   self.tbAlbumStatus = TBA_UPLOAD_DONE;
                                   if ([errorMessage isNotBlank]) {
                                       [FMCommon alert:@"" message:errorMessage];
                                   }
                               }
                           onProgress:^(NSUInteger idx, NSUInteger percent) {
                               CGFloat iProgress = [[NSString stringWithFormat:@"%.2f", percent / 100.f] floatValue];
                               NSNumber *tbPhotoIdx = [uploadIdx objectAtIndex:idx];
                               [_requiredInfoView.postImageView setProgress:iProgress index:(NSUInteger) [tbPhotoIdx intValue]];
                           }];
}

#pragma mark - bar code scan
- (void)$$postBarCodeScanNotification:(id <TBMBNotification>)notification {
    __weak FMPostViewController *selfWeak = self;
    huoyanViewController *huoyan = [[huoyanViewController alloc] init];
    [huoyan setDidFindBarCode:^(NSString *code) {
        [selfWeak requestBarCodeSearch:code];
    }];
    [self.navigationController presentViewController:huoyan
                                            animated:YES
                                          completion:nil];
}

- (void)requestBarCodeSearch:(NSString *)code {
    [FMItemService barCodeSearch:code result:^(BOOL isSuccess, id data, NSString *string) {
        if (isSuccess) {
            NSArray *cardList = [data objectForKey:@"cardList"];
            if (!cardList || [cardList count] < 1) {
                [FMCommon showToast:self.view text:@"亲，暂无与条码匹配的宝贝哦"];
                return;
            }
            NSString *title = nil;
            for (id obj in cardList) {
                NSString *cardNo = [obj objectForKey:@"cardNo"];
                if (cardNo && [cardNo intValue] == 1) {
                    title = [[obj objectForKey:@"title"] copy];
                    continue;
                }
            }
            if (title) {
                if ([FMCommon textLength:title] > kPostItemTitleMaxLength) {
                    NSUInteger index = [self textMaxIndex:title];
                    title = [title substringToIndex:index + 1];
                }
                [_requiredInfoView setTitleText:title];
                _itemDO.title = title;
                return;
            }
            [FMCommon showToast:self.view text:@"亲，暂无与条码匹配的宝贝哦"];
            return;
        }
        if (string && [string length] > 0) {
            [FMCommon showToast:self.view text:string];
            return;
        }
        [FMCommon showToast:self.view text:@"系统忙，请稍后再试"];
    }];
}

#pragma mark - record voice
- (void)$$postVoiceTouchDownNotification:(id <TBMBNotification>)notification {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.yOffset = -120;
    hud.margin = 10;
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = _voicePowerView;
    hud.userInteractionEnabled = YES;
    __weak FMPostViewController *selfWeak = self;
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
    });
    [_voicePowerView setPower:averagePower peakPower:peakPower];
}

- (void)voiceFinish:(NSData *)data
            amrFile:(NSString *)amrFile
         recordTime:(NSTimeInterval)recordTime
           recorder:(FMVoiceRecorder *)_recorder {
    if (_recorder.recordTime < 1) {
        [FMCommon showToast:self.view text:@"亲，语音太短"];
    } else if (data && !_isVoiceCancel) {
        _itemDO.isEditItemChanged = YES;
        _itemDO.voiceTime = [NSNumber numberWithDouble:recordTime];
        [self uploadVoice:data];
        return;
    }
    _isVoiceCancel = NO;
    [_recorder deleteArmFile];
}

- (void)$$postVoiceTouchUpNotification:(id <TBMBNotification>)notification {
    [[FMVoiceService proxyObject] stopAudioRecorder];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [_voicePowerView setPowerStatus:kVoicePowerStatusPower];
}

- (void)$$postVoiceTouchDragExitNotification:(id <TBMBNotification>)notification {
    _isVoiceCancel = YES;
    _voicePowerView.powerStatus = kVoicePowerStatusCancel;
}

- (void)$$postVoiceTouchDragEnterNotification:(id <TBMBNotification>)notification {
    _voicePowerView.powerStatus = kVoicePowerStatusPower;
    _isVoiceCancel = NO;
}

- (void)$$postVoiceTouchEndNotification:(id <TBMBNotification>)notification {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if (_isVoiceCancel) {
        [_voicePowerView setPowerStatus:kVoicePowerStatusPower];
    }
}

- (void)$$postDeleteVoiceNotification:(id <TBMBNotification>)notification {
    //TODO delete arm
    _itemDO.isEditItemChanged = YES;
    _itemDO.voiceUrl = nil;
}

- (void)initHideKeyboardButton {
    if (_hideKeyboardButton) {
        [_hideKeyboardButton removeFromSuperview];
        _hideKeyboardButton = nil;
    }

    CGRect keyboardRect = {{FM_SCREEN_WIDTH - 52, FM_SCREEN_HEIGHT + 31}, {42, 31}};
    _hideKeyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _hideKeyboardButton.frame = keyboardRect;
    [_hideKeyboardButton addTarget:self
                            action:@selector(hideKeyboard)
                  forControlEvents:UIControlEventTouchUpInside];
    [_hideKeyboardButton setBackgroundImage:[UIImage imageNamed:@"keyboard_hide_icon.png"]
                                   forState:UIControlStateNormal];
    [self.view addSubview:_hideKeyboardButton];
}

- (void)hideKeyboardButton:(NSTimeInterval)animationDuration {
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         _hideKeyboardButton.frame = CGRectMake(FM_SCREEN_WIDTH - 52, FM_SCREEN_HEIGHT + 31,
                                 42, 31
                         );
                     }
                     completion:^(BOOL finished) {
                         _hideKeyboardButton.hidden = YES;
                     }];
}

- (void)showKeyboardButton:(NSTimeInterval)animationDuration
                  keyboard:(CGRect)keyboardBounds {
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         _hideKeyboardButton.hidden = NO;
                         _hideKeyboardButton.frame = CGRectMake(FM_SCREEN_WIDTH - 52,
                                 self.view.frame.size.height - keyboardBounds.size.height - 31,
                                 42, 31
                         );
                     }
                     completion:nil];
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

    TBMBGlobalSendNotificationForSEL(@selector($$postKeyboardWillHideNotification:));
    [self hideKeyboardButton:animationDuration];
}

- (void)keyboardWillShow:(NSNotification *)aNotification {
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    [[aNotification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[aNotification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[aNotification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    CGRect keyboardBounds = [self.view convertRect:keyboardEndFrame toView:nil];

    TBMBGlobalSendNotificationForSELWithBody(@selector($$postKeyboardWillShowNotification:height:),
            [NSNumber numberWithFloat:keyboardBounds.size.height]);
    [self showKeyboardButton:animationDuration keyboard:keyboardBounds];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _requiredInfoView) {
        if (scrollView.contentOffset.y > 30) {
            [_requiredInfoView setTextIndicationState:FMPostIndicationStateDone];
        } else {
            [_requiredInfoView setTextIndicationState:FMPostIndicationStateNormal];
        }
        return;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == _requiredInfoView) {
        if (scrollView.contentOffset.y > 30) {
            [self hideKeyboard];
            [UIView animateWithDuration:0.5
                             animations:^{
                                 _requiredInfoView.frame = CGRectMake(0, -1 * (FM_SCREEN_HEIGHT - kTabBarHeight), FM_SCREEN_WIDTH, FM_SCREEN_HEIGHT - kTabBarHeight);
                                 _optionalInfoView.frame = CGRectMake(0, 0, FM_SCREEN_WIDTH, FM_SCREEN_HEIGHT - kTabBarHeight);
                             }
                             completion:nil];

        }
        return;
    }
}

- (void)$$postOptionalViewEndDraggingNotification:(id <TBMBNotification>)notification {
    [self hideKeyboard];
    [UIView animateWithDuration:0.5
                     animations:^{
                         _requiredInfoView.frame = CGRectMake(0, 0, FM_SCREEN_WIDTH, FM_SCREEN_HEIGHT - kTabBarHeight);
                         _optionalInfoView.frame = CGRectMake(0, FM_SCREEN_HEIGHT - kTabBarHeight, FM_SCREEN_WIDTH, FM_SCREEN_HEIGHT - kTabBarHeight);
                     }
                     completion:nil];
}

- (void)uploadVoice:(NSData *)data {
    [[FMVoiceUploadService proxyObject]
                           uploadVoice:data
                            uploadType:FM_UPLOAD_TYPE_POST
                                result:^(NSString *url, BOOL isSuccess, NSString *error) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                        _itemDO.voiceUrl = url;
                                    });
                                }
                            onProgress:^(NSUInteger progress) {

                            }];
}

- (void)hideKeyboard {
    [FMCommon hideKeyboard];
}

- (void)$$postGuessCategory:(id <TBMBNotification>)notification {
    if (_itemDO.isUserCategory) {
        return;
    }
    NSDictionary *dic = notification.userInfo;
    NSString *title = [dic objectForKey:kFMPostTitleTextField];
    NSString *price = [dic objectForKey:kFMPostPriceTextField];
    if (title == nil || [title isBlank]) {
        return;
    }

    long long int priceValue = 0;
    if ([price doubleValue] > 0) {
        priceValue = (long long int) ([price doubleValue] * 100);
    }

    FMPostViewController *selfProxy = self.proxyObject;
    [[FMPostService proxyObject]
            guessCategoryInfo:title
                        price:[NSString stringWithFormat:@"%lld", priceValue]
                       result:^(BOOL b, FMCategoryList *categoryList, NSString *msg) {
                           if (b) {
                               [selfProxy updateCategory:categoryList.items];
                           }
                       }];
}

- (void)updateCategory:(NSArray *)categories {
    if (_itemDO.isUserCategory) {
        return;
    }
    FMCategory *category = [categories lastObject];

    _itemDO.categoryId = category.id;
    _itemDO.categoryName = category.name;
}

- (BOOL)isPostEmpty {
    if ([_itemDO.title isNotBlank]) {
        return NO;
    }

    if ([_itemDO.price isNotBlank]) {
        return NO;
    }

    if ([_itemDO.originalPrice isNotBlank]) {
        return NO;
    }

    if ([_imageInfos count] > 0) {
        return NO;
    }

    if ([_itemDO.voiceUrl isNotBlank]) {
        return NO;
    }

    if (![_itemDO.categoryId isEqualToString:kItemDefaultCategoryId]) {
        return NO;
    }

    if (_itemDO.stuffStatus != 9) {
        return NO;
    }

    if (_itemDO.offline != FMItemTradeTypeAnyway) {
        return NO;
    }

    if ([_itemDO.postPrice isNotBlank]) {
        return NO;
    }

    if (_isPostLocationChanged) {
        return NO;
    }

    if ([_itemDO.contacts isNotBlank]) {
        return NO;
    }

    if ([_itemDO.phone isNotBlank]) {
        return NO;
    }

    if ([_itemDO.description isNotBlank]) {
        return NO;
    }

    return YES;
}

- (NSUInteger)textMaxIndex:(NSString *)content {
    float len = 0.f;
    NSUInteger index = 0;
    for (NSUInteger i = 0; i < [content length]; i++) {
        unichar c = [content characterAtIndex:i];
        if (isalnum(c) || isspace(c)) {
            len += 0.5;
        } else {
            len += 1.0;
        }

        if (len > kPostItemTitleMaxLength) {
            index = i - 1;
            break;
        }

        if (len == kPostItemTitleMaxLength) {
            index = i;
            break;
        }
    }
    return index;
}

@end