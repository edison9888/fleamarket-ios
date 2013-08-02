//
// Created by yuanxiao on 12-12-26.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import <Foundation/Foundation.h>
#import "SDWebImageManager.h"

typedef enum {
    FMImageScaleNone,
    FMImageScale40x40,
    FMImageScale60x60,
    FMImageScale70x70,
    FMImageScale80x80,
    FMImageScale120x120,
    FMImageScale160x160,
    FMImageScale200x200,
    FMImageScale320x320,
    FMImageScale640x640,
    FMImageScale960x960
} FMImageScaleType;


@interface FMImageView : UIImageView

@property (nonatomic, assign)BOOL needlessAnimation;

+ (void)setUseWebP:(BOOL)yesOrNO;

+ (void)setUseAnimation:(BOOL)yesOrNO;

- (void)setFMImageWithURL:(NSString *)url;

- (void)setFMImageWithURL:(NSString *)url
           imageScaleType:(FMImageScaleType)scaleType;

- (void)setFMImageWithURL:(NSString *)url
           imageScaleType:(FMImageScaleType)scaleType
         placeholderImage:(UIImage *)placeholder;

- (void)setFMImageWithURL:(NSString *)url
           imageScaleType:(FMImageScaleType)scaleType
         placeholderImage:(UIImage *)placeholder
                  options:(SDWebImageOptions)options;

- (void)setFMImageWithURL:(NSString *)url
           imageScaleType:(FMImageScaleType)scaleType
                  success:(void (^)(UIImage *image, FMImageView *))success
                  failure:(void (^)(NSError *error, FMImageView *))failure;

- (void)setFMImageWithURL:(NSString *)url
           imageScaleType:(FMImageScaleType)scaleType
         placeholderImage:(UIImage *)placeholder
                  success:(void (^)(UIImage *image, FMImageView *))success
                  failure:(void (^)(NSError *error, FMImageView *))failure;

- (void)setFMImageWithURL:(NSString *)url
           imageScaleType:(FMImageScaleType)scaleType
         placeholderImage:(UIImage *)placeholder
                  options:(SDWebImageOptions)options
                  success:(void (^)(UIImage *image, FMImageView *))success
                  failure:(void (^)(NSError *error, FMImageView *))failure;

- (void)setFMImageWithURL:(NSString *)url
           imageScaleType:(FMImageScaleType)scaleType
         placeholderImage:(UIImage *)placeholder
                  options:(SDWebImageOptions)options
               isProgress:(BOOL)isProgress
                  success:(void (^)(UIImage *image, FMImageView *))success
                  failure:(void (^)(NSError *error, FMImageView *))failure;

- (void)cancelCurrentImageLoad;

@end

@interface FMImageView (WebP) <SDWebImageManagerDelegate>

- (void)setWebPImageWithURL:(NSString *)url
             imageScaleType:(FMImageScaleType)scaleType;

- (void)setWebPImageWithURL:(NSString *)url
             imageScaleType:(FMImageScaleType)scaleType
           placeholderImage:(UIImage *)placeholder;

- (void)setWebPImageWithURL:(NSString *)url
             imageScaleType:(FMImageScaleType)scaleType
           placeholderImage:(UIImage *)placeholder
                 isProgress:(BOOL)isProgress;

- (void)setWebPImageWithURL:(NSString *)url
             imageScaleType:(FMImageScaleType)scaleType
                    success:(void (^)(UIImage *image, FMImageView *))success
                    failure:(void (^)(NSError *error, FMImageView *))failure;

- (void)setWebPImageWithURL:(NSString *)url
             imageScaleType:(FMImageScaleType)scaleType
           placeholderImage:(UIImage *)placeholder
                    success:(void (^)(UIImage *image, FMImageView *))success
                    failure:(void (^)(NSError *error, FMImageView *))failure;

- (void)setWebPImageWithURL:(NSString *)url
             imageScaleType:(FMImageScaleType)scaleType
           placeholderImage:(UIImage *)placeholder
                    options:(SDWebImageOptions)options
                    success:(void (^)(UIImage *image, FMImageView *))success
                    failure:(void (^)(NSError *error, FMImageView *))failure;

- (void)setWebPImageWithURL:(NSString *)url
             imageScaleType:(FMImageScaleType)scaleType
           placeholderImage:(UIImage *)placeholder
                 isProgress:(BOOL)isProgress
                    success:(void (^)(UIImage *image, FMImageView *))success
                    failure:(void (^)(NSError *error, FMImageView *))failure;

@end