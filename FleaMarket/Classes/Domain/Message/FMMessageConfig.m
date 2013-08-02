//
// Created by henson on 10/29/12.
// 

#import "FMMessageConfig.h"


@implementation FMMessageConfig {

}

@synthesize isComment = _isComment;
@synthesize isTrade = _isTrade;
@synthesize isActivity = _isActivity;
@synthesize isSystem = _isSystem;

- (id)init {
    self = [super init];
    if (self) {
        self.isComment = YES;
        self.isTrade = YES;
        self.isActivity = YES;
        self.isSystem = YES;
    }

    return self;
}

- (id)initWithMessageConfig:(FMMessageConfig *)messageConfig {
    self = [self init];
    if (self) {
        if (messageConfig) {
            self.isComment = messageConfig.isComment;
            self.isTrade = messageConfig.isTrade;
            self.isActivity = messageConfig.isActivity;
            self.isSystem = messageConfig.isSystem;
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeBool:_isComment forKey:@"isComment"];
    [aCoder encodeBool:_isTrade forKey:@"isTrade"];
    [aCoder encodeBool:_isActivity forKey:@"isActivity"];
    [aCoder encodeBool:_isSystem forKey:@"isSystem"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _isComment = [aDecoder decodeBoolForKey:@"isComment"];
        _isTrade = [aDecoder decodeBoolForKey:@"isTrade"];
        _isActivity = [aDecoder decodeBoolForKey:@"isActivity"];
        _isSystem = [aDecoder decodeBoolForKey:@"isSystem"];
    }
    return self;
}

@end