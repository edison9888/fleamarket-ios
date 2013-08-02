//
// Created by yuanxiao on 12-12-26.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "SDWebImageManager.h"
#import "FMImageView.h"
#import "DACircularProgressView.h"

#define FMWebPSuffix   @"_.webp"

static BOOL DEFAULT_USE_WEBP = YES;
static BOOL DEFAULT_USE_ANIMATION = YES;

@implementation FMImageView {
@private
    BOOL _needlessAnimation;

    DACircularProgressView *_progressView;

    id <SDWebImageOperation> _operation;

    NSUInteger _requestCount;
}

@synthesize needlessAnimation = _needlessAnimation;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _requestCount = 0;
    }

    return self;
}


+ (void)setUseWebP:(BOOL)yesOrNO {
    DEFAULT_USE_WEBP = yesOrNO;
}

+ (void)setUseAnimation:(BOOL)yesOrNO {
    DEFAULT_USE_ANIMATION = yesOrNO;
}

- (void)setFMImageWithURL:(NSString *)url {
    [self setFMImageWithURL:url
             imageScaleType:FMImageScaleNone];
}

- (void)setFMImageWithURL:(NSString *)url
           imageScaleType:(FMImageScaleType)scaleType {
    [self setFMImageWithURL:url
             imageScaleType:scaleType
           placeholderImage:nil];
}

- (void)setFMImageWithURL:(NSString *)url
           imageScaleType:(FMImageScaleType)scaleType
         placeholderImage:(UIImage *)placeholder {
    [self setFMImageWithURL:url
             imageScaleType:scaleType
           placeholderImage:placeholder
                    options:0];
}

- (void)setFMImageWithURL:(NSString *)url
           imageScaleType:(FMImageScaleType)scaleType
         placeholderImage:(UIImage *)placeholder
                  options:(SDWebImageOptions)options {
    [self setFMImageWithURL:url
             imageScaleType:scaleType
           placeholderImage:placeholder
                    options:options
                 isProgress:NO
                    success:nil
                    failure:nil];
}

- (void)setFMImageWithURL:(NSString *)url
           imageScaleType:(FMImageScaleType)scaleType
                  success:(void (^)(UIImage *image, FMImageView *))success
                  failure:(void (^)(NSError *error, FMImageView *))failure {
    [self setFMImageWithURL:url
             imageScaleType:scaleType
           placeholderImage:nil
                    success:success
                    failure:failure];
}

- (void)setFMImageWithURL:(NSString *)url
           imageScaleType:(FMImageScaleType)scaleType
         placeholderImage:(UIImage *)placeholder
                  success:(void (^)(UIImage *image, FMImageView *))success
                  failure:(void (^)(NSError *error, FMImageView *))failure {
    [self setFMImageWithURL:url
             imageScaleType:scaleType
           placeholderImage:placeholder
                    options:0
                    success:success
                    failure:failure];
}

- (void)setFMImageWithURL:(NSString *)url
           imageScaleType:(FMImageScaleType)scaleType
         placeholderImage:(UIImage *)placeholder
                  options:(SDWebImageOptions)options
                  success:(void (^)(UIImage *image, FMImageView *))success
                  failure:(void (^)(NSError *error, FMImageView *))failure {
    [self setFMImageWithURL:url
             imageScaleType:scaleType
           placeholderImage:placeholder
                    options:options
                 isProgress:NO
                    success:success
                    failure:failure];
}

- (void)setFMImageWithURL:(NSString *)url
           imageScaleType:(FMImageScaleType)scaleType
         placeholderImage:(UIImage *)placeholder
                  options:(SDWebImageOptions)options
               isProgress:(BOOL)isProgress
                  success:(void (^)(UIImage *image, FMImageView *))success
                  failure:(void (^)(NSError *error, FMImageView *))failure {
    [self setFMImageWithURL:url
             imageScaleType:scaleType
                     isWebP:NO
           placeholderImage:placeholder
                    options:options
                 isProgress:isProgress
                    success:success
                    failure:failure];
}

- (void)setFMImageWithURL:(NSString *)url
           imageScaleType:(FMImageScaleType)scaleType
                   isWebP:(BOOL)isWebP
         placeholderImage:(UIImage *)placeholder
                  options:(SDWebImageOptions)options
               isProgress:(BOOL)isProgress
                  success:(void (^)(UIImage *image, FMImageView *))success
                  failure:(void (^)(NSError *error, FMImageView *))failure {
    if (!url)
        return;
    _requestCount++;
    [self cancelCurrentImageLoad];
    self.image = placeholder;
    NSString *__url = [NSString stringWithFormat:@"%@%@%@",
                                     url,
                                     [self getImageScaleWithType:scaleType],
                                     isWebP ? FMWebPSuffix : @""];
    NSURL *nsUrl = [[NSURL alloc] initWithString:__url];
    __weak FMImageView *wself = self;
    SDWebImageCompletedWithFinishedBlock finishedBlock = ^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong FMImageView *sself = wself;
            if (!sself)
                return;

            if (!image && _requestCount <= 2) {
                [sself setFMImageWithURL:url
                          imageScaleType:scaleType
                                  isWebP:NO
                        placeholderImage:placeholder
                                 options:options
                              isProgress:isProgress
                                 success:success
                                 failure:failure];
                return;
            }
            _requestCount = 0;
            [sself updateImage:image];

            if (finished && success) {
                success(image, sself);
            }
            if (!finished && failure) {
                failure(error, sself);
            }
        }
        );
    };
    SDWebImageDownloaderProgressBlock progressBlock = nil;
    if (isProgress) {
        [_progressView removeFromSuperview];
        if (!_progressView) {
            _progressView = [[DACircularProgressView alloc] initWithFrame:
                    CGRectMake((self.frame.size.width - 40) / 2, (self.frame.size.height - 40) / 2, 40, 40)];
        }
        [self addSubview:_progressView];
        progressBlock = ^(NSUInteger receivedSize, long long int expectedSize) {
            [wself updateProgress:(float) receivedSize / (float) expectedSize];
        };
    }

    _operation = [SDWebImageManager.sharedManager
            downloadWithURL:nsUrl
                    options:options
                   progress:progressBlock
                  completed:finishedBlock];
}

- (void)cancelCurrentImageLoad {
    [_operation cancel];
}

- (NSString *)getImageScaleWithType:(FMImageScaleType)scaleType {
    NSString *strScale = nil;
    switch (scaleType) {
        case FMImageScaleNone:
            strScale = @"";
            break;

        case FMImageScale40x40:
            strScale = @"_40x40.jpg";
            break;

        case FMImageScale60x60:
            strScale = @"_60x60.jpg";
            break;

        case FMImageScale70x70:
            strScale = @"_70x70.jpg";
            break;

        case FMImageScale80x80:
            strScale = @"_80x80.jpg";
            break;

        case FMImageScale120x120:
            strScale = @"_120x120.jpg";
            break;

        case FMImageScale160x160:
            strScale = @"_160x160.jpg";
            break;

        case FMImageScale200x200:
            strScale = @"_200x200.jpg";
            break;

        case FMImageScale320x320:
            strScale = @"_320x320.jpg";
            break;

        case FMImageScale640x640:
            strScale = @"_640x640.jpg";
            break;

        case FMImageScale960x960:
            strScale = @"_960x960.jpg";
            break;

        default:
            strScale = @"";
            break;
    }
    return strScale;
}

- (void)updateProgress:(float)per {
    dispatch_async(dispatch_get_main_queue(), ^{
        float __per = per;
        if (__per <= 0) {
            return;
        }
        else if (per > 1) {
            __per = 1.0;
        }
        [_progressView setProgress:__per];
    });
}

- (void)updateImage:(UIImage *)image {
    if (!image) {
        return;
    }
    [_progressView removeFromSuperview];
    self.image = image;
    if (!_needlessAnimation && DEFAULT_USE_ANIMATION) {
        self.alpha = 0;
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.alpha = 1.0;
                         }];
    }
}

@end


@implementation FMImageView (WebP)

- (void)setWebPImageWithURL:(NSString *)url
             imageScaleType:(FMImageScaleType)scaleType {
    [self setWebPImageWithURL:url
               imageScaleType:scaleType
             placeholderImage:nil];
}

- (void)setWebPImageWithURL:(NSString *)url
             imageScaleType:(FMImageScaleType)scaleType
           placeholderImage:(UIImage *)placeholder {
    [self setWebPImageWithURL:url
               imageScaleType:scaleType
             placeholderImage:placeholder
                   isProgress:NO];
}

- (void)setWebPImageWithURL:(NSString *)url
             imageScaleType:(FMImageScaleType)scaleType
           placeholderImage:(UIImage *)placeholder
                 isProgress:(BOOL)isProgress {
    [self setFMImageWithURL:url
             imageScaleType:scaleType
                     isWebP:DEFAULT_USE_WEBP
           placeholderImage:placeholder
                    options:0
                 isProgress:isProgress
                    success:nil
                    failure:nil];
}

- (void)setWebPImageWithURL:(NSString *)url
             imageScaleType:(FMImageScaleType)scaleType
                    success:(void (^)(UIImage *image, FMImageView *))success
                    failure:(void (^)(NSError *error, FMImageView *))failure {
    [self setWebPImageWithURL:url
               imageScaleType:scaleType
             placeholderImage:nil
                      success:success
                      failure:failure];
}

- (void)setWebPImageWithURL:(NSString *)url
             imageScaleType:(FMImageScaleType)scaleType
           placeholderImage:(UIImage *)placeholder
                    success:(void (^)(UIImage *image, FMImageView *))success
                    failure:(void (^)(NSError *error, FMImageView *))failure {
    [self setWebPImageWithURL:url
               imageScaleType:scaleType
             placeholderImage:placeholder
                      options:0
                      success:success
                      failure:failure];
}

- (void)setWebPImageWithURL:(NSString *)url
             imageScaleType:(FMImageScaleType)scaleType
           placeholderImage:(UIImage *)placeholder
                    options:(SDWebImageOptions)options
                    success:(void (^)(UIImage *image, FMImageView *))success
                    failure:(void (^)(NSError *error, FMImageView *))failure {
    [self setFMImageWithURL:url
             imageScaleType:scaleType
           placeholderImage:placeholder
                    options:options
                 isProgress:NO
                    success:success
                    failure:failure];
}

- (void)setWebPImageWithURL:(NSString *)url
             imageScaleType:(FMImageScaleType)scaleType
           placeholderImage:(UIImage *)placeholder
                 isProgress:(BOOL)isProgress
                    success:(void (^)(UIImage *image, FMImageView *))success
                    failure:(void (^)(NSError *error, FMImageView *))failure; {
    [self setFMImageWithURL:url
             imageScaleType:scaleType
                     isWebP:DEFAULT_USE_WEBP
           placeholderImage:placeholder
                    options:0
                 isProgress:isProgress
                    success:success
                    failure:failure];
}

@end