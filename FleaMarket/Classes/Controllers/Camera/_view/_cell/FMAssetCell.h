// 
// Created by henson on 6/4/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import <Foundation/Foundation.h>

@interface FMAssetCell : UITableViewCell

- (id)initWithAssets:(NSArray *)assets reuseIdentifier:(NSString *)identifier;

-(void)setAssets:(NSArray *)assets;

-(void)setShowCameraAction:(void (^)(void))block;

@end