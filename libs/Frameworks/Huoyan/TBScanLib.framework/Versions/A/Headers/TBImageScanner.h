//
//  TBImageScanner.h
//  itf
//
//  Created by qisen tan on 12-3-27.
//  Copyright (c) 2012年 alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBImage.h"
#import "TBSymbolSet.h"

@interface TBImageScanner : NSObject

@property (retain, nonatomic) TBSymbolSet* results;
@property (retain, nonatomic) TBSymbolSet* bigResults;
- (NSInteger) scanImage: (TBImage*)image;

- (NSInteger) scanBigImage: (TBImage*)image;
//- (TBarRet) scanBigImage: (TBImage*)image;

@end
