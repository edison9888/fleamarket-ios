//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-9-12 下午3:00.
//


#import <Foundation/Foundation.h>


@interface PostData : NSObject

@property(copy, nonatomic) NSString *fileName;
@property(copy, nonatomic) NSString *contentType;
@property(strong, nonatomic) NSData *fileData;
@end