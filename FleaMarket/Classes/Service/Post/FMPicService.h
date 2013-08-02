//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 12-11-15 下午5:12.
//

typedef void (^FM_UPLOAD_PIC_RESULT_BLOCK)(NSString *, BOOL, NSString *);

typedef void (^FM_UPLOAD_PIC_PROGRESS_BLOCK)(NSUInteger);

typedef void (^FM_UPLOAD_PIC_RESULT_GROUP_BLOCK)(NSArray *, NSArray *);

typedef void (^FM_UPLOAD_PIC_PROGRESS_GROUP_BLOCK)(NSUInteger, NSUInteger);

@interface FMPicService : NSObject

+ (void)uploadPicWithUrls:(NSArray *)picUrls
                   result:(FM_UPLOAD_PIC_RESULT_GROUP_BLOCK)result
               onProgress:(FM_UPLOAD_PIC_PROGRESS_GROUP_BLOCK)onProgress;

+ (void)uploadPicWithImages:(NSArray *)images
                     result:(FM_UPLOAD_PIC_RESULT_GROUP_BLOCK)result
                 onProgress:(FM_UPLOAD_PIC_PROGRESS_GROUP_BLOCK)onProgress;

+ (void)uploadPicWithUrl:(NSString *)picUrl
                  result:(FM_UPLOAD_PIC_RESULT_BLOCK)result
              onProgress:(FM_UPLOAD_PIC_PROGRESS_BLOCK)onProgress;

+ (void)uploadImage:(UIImage *)image
             result:(FM_UPLOAD_PIC_RESULT_BLOCK)result
         onProgress:(FM_UPLOAD_PIC_PROGRESS_BLOCK)onProgress;

+ (void)uploadPic:(NSData *)picData
           result:(FM_UPLOAD_PIC_RESULT_BLOCK)result
       onProgress:(FM_UPLOAD_PIC_PROGRESS_BLOCK)onProgress;

@end