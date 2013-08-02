//
//  TBSymbolSet.h
//  itf
//
//  Created by qisen tan on 12-3-27.
//  Copyright (c) 2012年 alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
@interface TBSymbolSet : NSObject <NSFastEnumeration>
{
    NSArray* set;
}

@property (readonly, nonatomic) int count;
@property (copy, nonatomic) NSArray* set;

- (id) initWithSet:(NSArray*)inSet;
@end


@interface TBSymbol : NSObject
{
    
}

@property (readonly, nonatomic) NSString* typeName;
@property (readonly, nonatomic) NSString* data;
@property (readonly, nonatomic) int count;
@property (readonly, nonatomic) CGRect bounds;
@property (readonly, nonatomic) int type;
@property (readonly, nonatomic) int subType;

- (id) initWithName:(NSString*)name data:(NSString*)data count:(int)count bound:(CGRect)bounds type:(int)type subType:(int)subType;

@end
