//
// Created by henson on 10/29/12.
// 

#import <Foundation/Foundation.h>


@interface FMMessageConfig : NSObject {
    BOOL _isComment;
    BOOL _isTrade;
    BOOL _isActivity;
    BOOL _isSystem;
}
@property(nonatomic) BOOL isComment;
@property(nonatomic) BOOL isTrade;
@property(nonatomic) BOOL isActivity;
@property(nonatomic) BOOL isSystem;

- (id)initWithMessageConfig:(FMMessageConfig *)messageConfig;

@end