//
// Created by yuanxiao on 13-5-27.
// Copyright (c) 2013 Taobao. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "TBSocialShareToWeChat.h"
#import "WXApi.h"
#import "TBSocialShareWeChatModel.h"
#import "TBSocialShareConfig.h"

#define BUFFER_SIZE 1024 * 100

@interface TBSocialShareToWeChat () <WXApiDelegate>

@end

@implementation TBSocialShareToWeChat {

@private
    enum WXScene _wxScene;
    __weak id<WXApiDelegate> _wxDelegate;
}

@synthesize wxScene = _wxScene;

+ (TBSocialShareToWeChat *)instance {
    static TBSocialShareToWeChat *_instance = nil;
    static dispatch_once_t _oncePredicate_TBSocialShareToWeChat;

    dispatch_once(&_oncePredicate_TBSocialShareToWeChat, ^{
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    });

    return _instance;
}

- (BOOL)handleOpenURL:(NSURL *)url delegate:(id<WXApiDelegate>) delegate {
    _wxDelegate = delegate;
    return [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)isWXAppInstalled {
    return [WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi];
}

- (void)shareContent:(TBSocialShareBaseModel *)baseModel {
    if (![self _isWXAppInstalled]) {
        return;
    }

    TBSocialShareWeChatModel *weChatModel = (TBSocialShareWeChatModel *)baseModel;
    //发送到微信的数据对象
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.scene = _wxScene;
    req.bText = YES;
    req.text  = weChatModel.status;

    //多媒体对象
    WXMediaMessage *message = [WXMediaMessage message];
    message.title           = weChatModel.title;
    message.description     = weChatModel.status;

    if (weChatModel.messageType != TBSocialWXMessageTypeText) {
        if (weChatModel.thumbImage != nil) {
            UIImage *scaleImage = [self imageByScalingAndCroppingFromImage:weChatModel.thumbImage
                                                                      size:CGSizeMake(100, 100)];
            [message setThumbImage:scaleImage];
        }
        else{
            [message setThumbImage:[UIImage imageNamed:@"icon"]];
        }
    }

    if (weChatModel.messageType == TBSocialWXMessageTypeApp) {
        WXAppExtendObject *ext = [WXAppExtendObject object];
        ext.url = weChatModel.appUrl;
        ext.extInfo = weChatModel.extInfo;
        Byte *pBuffer = (Byte *)malloc(BUFFER_SIZE);
        memset(pBuffer, 0, BUFFER_SIZE);
        NSData *data = [NSData dataWithBytes:pBuffer length:BUFFER_SIZE];
        free(pBuffer);
        ext.fileData = data;

        message.mediaObject = ext;
        req.bText = NO;
        req.message = message;
    } else if (weChatModel.messageType == TBSocialWXMessageTypeImage && weChatModel.image) {
        WXImageObject *imageObject = [WXImageObject object];
        [imageObject setImageData:UIImageJPEGRepresentation(weChatModel.image, 0.9)];
        message.mediaObject = imageObject;

        req.bText = NO;
        req.message = message;
    } else if (weChatModel.messageType == TBSocialWXMessageTypeWeb) {
        WXWebpageObject *webObject = [WXWebpageObject object];
        webObject.webpageUrl = weChatModel.webUrl;
        message.mediaObject = webObject;

        req.bText = NO;
        req.message = message;
    } else if (weChatModel.messageType == TBSocialWXMessageTypeOther && weChatModel.wxMediaObject) {
        message.mediaObject = weChatModel.wxMediaObject;

        req.bText = NO;
        req.message = message;
    }

    [WXApi sendReq:req];
}

- (BOOL)_isWXAppInstalled {
    if (![WXApi isWXAppInstalled] || ![WXApi isWXAppSupportApi]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"您的设备没有安装微信"
                                                           delegate:nil
                                                  cancelButtonTitle:@"好"
                                                  otherButtonTitles: nil];
        [alertView show];
        return NO;
    }
    return YES;
}

#pragma mark -- weChat delegate
-(void) onReq:(BaseReq*)req
{
    if (_wxDelegate && [_wxDelegate respondsToSelector:@selector(onReq:)]) {
        [_wxDelegate onReq:req];
    }
    if([req isKindOfClass:[GetMessageFromWXReq class]])
    {
    }
    else if([req isKindOfClass:[ShowMessageFromWXReq class]])
    {
    }
}

-(void) onResp:(BaseResp*)resp
{
    if (_wxDelegate && [_wxDelegate respondsToSelector:@selector(onResp:)]) {
        [_wxDelegate onResp:resp];
    }
    if (self.shareResultDelegate) {
        if ([self.shareResultDelegate respondsToSelector:@selector(socialShareSuccess:result:)]
                && resp.errCode == 0) {
            [self.shareResultDelegate socialShareSuccess:TBSocialShareTypeWeChat result:resp];
        } else if ([self.shareResultDelegate respondsToSelector:@selector(socialShareFailed:error:)]) {
            [self.shareResultDelegate socialShareFailed:TBSocialShareTypeWeChat error:resp];
        }
    }
}

- (UIImage *)imageByScalingAndCroppingFromImage:(UIImage *)sourceImage size:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);

    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;

        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;

        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
        if (widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }

    UIGraphicsBeginImageContext(targetSize); // this will crop

    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;

    [sourceImage drawInRect:thumbnailRect];

    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");

    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

@end