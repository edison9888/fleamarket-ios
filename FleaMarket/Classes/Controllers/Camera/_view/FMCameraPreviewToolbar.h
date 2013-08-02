//
//  FMCameraPreviewToolbar.h
//  FleaMarket
//
//  Created by Caiyu on 13-7-22.
//  Copyright (c) 2013年 taobao.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FMCameraPreviewToolbar : UIView

- (void)setRetakePictureAction:(void (^)(void))block;
- (void)setUsePictureAction:(void (^)(void))block;
@end
