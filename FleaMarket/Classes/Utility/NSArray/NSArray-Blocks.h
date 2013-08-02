//
//  NSArray-Blocks.h
//  Handy codebits
//
//  Created by Sijawusz Pur Rahnama on 15/11/09.
//  Copyleft 2009 Sijawusz Pur Rahnama. Some rights reserved.
//

#import <Foundation/Foundation.h>

static NSComparisonResult sortUsingBlock(id arg1, id arg2, NSComparisonResult (^block)(id, id));

@interface NSArray (Blocks)

- (BOOL) all:(BOOL (^)(id))block;
- (BOOL) every:(BOOL (^)(id))block; /// @ref self::all()
- (BOOL) any:(BOOL (^)(id))block;
- (BOOL) some:(BOOL (^)(id))block; /// @ref self::any()

- (void) each:(void (^)(id))block;

//- (NSArray *) sort:(NSComparisonResult (^)(id, id))block;
- (id) find:(BOOL (^)(id))block;
- (id) detect:(BOOL (^)(id))block; /// @ref self::find()
- (NSArray *) select:(BOOL (^)(id))block;
- (NSArray *) findAll:(BOOL (^)(id))block; /// @ref self::select()
- (NSArray *) filter:(BOOL (^)(id))block; /// @ref self::select()
- (NSArray *) reject:(BOOL (^)(id))block;
- (NSArray *) partition:(BOOL (^)(id))block;
- (NSArray *) map:(id (^)(id))block;
- (NSArray *) collect:(id (^)(id))block; /// @ref self::map()

//added by Caiyu
- (NSArray *) unique;
-(NSArray *)unique:(BOOL (^)(id,id))block;
@end