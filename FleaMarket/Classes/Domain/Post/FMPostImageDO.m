// 
// Created by henson on 7/21/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import "FMPostImageDO.h"

@implementation FMPostImageDO {

@private
    UIImage *_image;
    NSURL *_imageURL;
    UIImage *_thumbImage;
}
@synthesize image = _image;
@synthesize imageURL = _imageURL;
@synthesize thumbImage = _thumbImage;

- (id)init {
    self = [super init];
    if (self) {
        _image = nil;
        _thumbImage = nil;
        _imageURL = nil;
    }

    return self;
}

- (id)initWithImage:(UIImage *)image {
    self = [self init];
    if (self) {
        _image = image;
    }

    return self;
}

+ (id)objectWithImage:(UIImage *)image {
    return [[FMPostImageDO alloc] initWithImage:image];
}

- (id)initWithImage:(UIImage *)image thumbImage:(UIImage *)thumbImage {
    self = [self init];
    if (self) {
        _image = image;
        _thumbImage = thumbImage;
    }

    return self;
}

+ (id)objectWithImage:(UIImage *)image thumbImage:(UIImage *)thumbImage {
    return [[FMPostImageDO alloc] initWithImage:image thumbImage:thumbImage];
}

- (id)initWithImageURL:(NSURL *)imageURL {
    self = [self init];
    if (self) {
        _imageURL = imageURL;
    }

    return self;
}

+ (id)objectWithImageURL:(NSURL *)imageURL {
    return [[FMPostImageDO alloc] initWithImageURL:imageURL];
}

- (BOOL)isUploaded {
    return _imageURL != nil;
}

@end