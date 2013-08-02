//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-9-12 下午3:00.
//


#import "PostData.h"


@implementation PostData {

@private
    NSString *_fileName;
    NSString *_contentType;
    NSData *_fileData;
}
@synthesize fileName = _fileName;
@synthesize contentType = _contentType;
@synthesize fileData = _fileData;


@end