//
//  NSArray-Blocks.m
//  Handy codebits
//
//  Created by Sijawusz Pur Rahnama on 15/11/09.
//  Copyleft 2009 Sijawusz Pur Rahnama. Some rights reserved.
//

#import "NSArray-Blocks.h"

static NSComparisonResult sortUsingBlock(id arg1, id arg2, NSComparisonResult (^block)(id, id)) {
    return block(arg1, arg2);
}

@implementation NSArray (Blocks)

- (BOOL) all:(BOOL (^)(id))block {
    BOOL truth = YES;
    for (id obj in self) {
        truth = truth && block(obj);
    }
    return truth;
}

- (BOOL) every:(BOOL (^)(id))block {
    return [self all:block];
}

- (BOOL) any:(BOOL (^)(id))block {
    BOOL truth = NO;
    for (id obj in self) {
        truth = truth || block(obj);
    }
    return truth;
}

- (BOOL) some:(BOOL (^)(id))block {
    return [self any:block];
}

- (void) each:(void (^)(id))block {
    for (id obj in self) {
        block(obj);
    }
}

//- (NSArray *) sort:(NSComparisonResult (^)(id, id))block {
//    return [self sortedArrayUsingFunction:&sortUsingBlock context:block];
//}

- (id) find:(BOOL (^)(id))block {
    for (id obj in self) {
        if (block(obj)) return obj;
    }
    return nil;
}

- (id) detect:(BOOL (^)(id))block {
    return [self find:block];
}

- (NSArray *) select:(BOOL (^)(id))block {
    NSMutableArray *new = [NSMutableArray array];
    for (id obj in self) {
        if (block(obj)) [new addObject:obj];
    }
    return new;
}

- (NSArray *) findAll:(BOOL (^)(id))block {
    return [self select:block];
}

- (NSArray *) filter:(BOOL (^)(id))block {
    return [self select:block];
}

- (NSArray *) reject:(BOOL (^)(id))block {
    NSMutableArray *new = [NSMutableArray array];
    for (id obj in self) {
        if (!block(obj)) [new addObject:obj];
    }
    return new;
}

- (NSArray *) partition:(BOOL (^)(id))block {
    NSMutableArray *ayes = [NSMutableArray array];
    NSMutableArray *noes = [NSMutableArray array];
    for (id obj in self) {
        if (block(obj)) {
            [ayes addObject:obj];
        } else {
            [noes addObject:obj];
        }
    }
    return [NSArray arrayWithObjects:ayes, noes, nil];
}

- (NSArray *) map:(id (^)(id))block {
    NSMutableArray *new = [NSMutableArray arrayWithCapacity:[self count]];
    for (id obj in self) {
        id newObj = block(obj);
        [new addObject:newObj ? newObj : [NSNull null]];
    }
    return new;
}

- (NSArray *) collect:(id (^)(id))block {
    return [self map:block];
}

- (NSArray *) unique{
    NSMutableArray *new = [NSMutableArray array];
    for (id obj in self) {
        if ([new containsObject:obj] == NO) {
            [new addObject:obj];
        }
    }
    return new;
}

-(NSArray *)unique:(BOOL (^)(id,id))block{
    NSMutableArray *new = [NSMutableArray array];
    for (id obj in self) {
        if (![new find:^BOOL(id obj1){
            return block(obj,obj1);
        }]){
            [new addObject:obj];
        }
    }
    return new;
}
@end