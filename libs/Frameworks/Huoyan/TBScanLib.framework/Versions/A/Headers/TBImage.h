//
//  TBImage.h
//  itf
//
//  Created by qisen tan on 12-3-27.
//  Copyright (c) 2012年 alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "tbItf.h"

@interface TBImage : NSObject {
    CFDataRef dataRef;
}

@property (readonly, nonatomic) TBarImage* tbImg;
- (id) initWithCGImage: (CGImageRef) image size:(CGSize)size;

@end
