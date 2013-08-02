//
// Created by yuanxiao on 13-5-28.
// Copyright (c) 2013 Taobao. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface TBSocialShareBaseModel : NSObject

@property (nonatomic, copy) NSString *status;              //分享的文字内容，包括分享到微信多媒体的描述部分
@property (nonatomic, strong) UIImage *image;              //分享的image
@property (nonatomic, copy) NSString *title;               //分享的title，主要用于微信，邮件等

@end