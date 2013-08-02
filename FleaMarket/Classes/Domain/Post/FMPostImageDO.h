// 
// Created by henson on 7/21/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>

@interface FMPostImageDO : NSObject

@property(nonatomic, strong) UIImage *image;
@property(nonatomic, strong) NSURL *imageURL;
@property(nonatomic, strong) UIImage *thumbImage;
@property(nonatomic, assign) BOOL isMasterImage;

- (id)initWithImage:(UIImage *)image;

+ (id)objectWithImage:(UIImage *)image;

- (id)initWithImage:(UIImage *)image
         thumbImage:(UIImage *)thumbImage;

+ (id)objectWithImage:(UIImage *)image
           thumbImage:(UIImage *)thumbImage;

- (id)initWithImageURL:(NSURL *)imageURL;

+ (id)objectWithImageURL:(NSURL *)imageURL;

- (BOOL)isUploaded;

@end