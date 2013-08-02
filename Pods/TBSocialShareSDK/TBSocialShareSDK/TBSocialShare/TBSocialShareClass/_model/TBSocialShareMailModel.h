//
// Created by yuanxiao on 13-5-30.
// Copyright (c) 2013 Taobao. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "TBSocialShareBaseModel.h"


@interface TBSocialShareMailModel : TBSocialShareBaseModel


@property (nonatomic, copy) NSString *suggestionMail;    //收件人
@property (nonatomic, copy) NSString *appVersion;
@property (nonatomic, copy) NSString *currentTTID;
@property (nonatomic, copy) NSData *attachment;           //文件数据
@property (nonatomic, copy) NSString *fileName;           //文件名字

@end