// 
// Created by henson on 7/5/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>
#import "FMBaseViewController.h"
#import "FMCameraAlbumPickerController.h"

#define previewSize 5

@interface FMCameraAlbumViewController : UIViewController <UINavigationControllerDelegate>

-(id)initWithSelectedCount:(int)selectedCount;

-(id)initWithPrevieSize:(int)__previewSize;

-(void)setTakenUrls:(NSArray*)takenUrls;

-(void)selectedAssetsDidFinish:(void (^)(NSArray *))block;

@end