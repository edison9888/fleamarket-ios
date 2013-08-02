//
// Created by yuanxiao on 13-5-28.
// Copyright (c) 2013 Taobao. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "TBSocialShareBaseModel.h"

/**
 微信内容类型
 */
typedef enum{
    TBSocialWXMessageTypeText,      //微信文本内容
    TBSocialWXMessageTypeImage,     //微信图片类型
    TBSocialWXMessageTypeApp,       //微信应用类型
    TBSocialWXMessageTypeWeb,       //微信网页类型
    TBSocialWXMessageTypeOther      //微信其他多媒体类型
} TBSocialWXMessageType;

@interface TBSocialShareWeChatModel : TBSocialShareBaseModel

@property (nonatomic) TBSocialWXMessageType messageType;             //微信类型
@property (nonatomic, copy) NSString *appUrl;                        //分享app的url
@property (nonatomic, copy) NSString *webUrl;                        //分享web的url
@property (nonatomic, copy) NSString *extInfo;                       //第三方程序自定义简单数据，微信终端会回传给第三方程序处理
@property (nonatomic, strong) UIImage *thumbImage;                   //多媒体的缩略图，默认会进行切割100x100，因为缩略图有限制10k
@property (nonatomic, strong) id wxMediaObject;                      //可以自定义微信多媒体类型，可以为WXWebpageObject，WXImageObject，WXMusicObject等

@end