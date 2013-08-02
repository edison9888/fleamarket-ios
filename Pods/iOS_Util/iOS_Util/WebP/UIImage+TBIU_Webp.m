//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-5 下午1:30.
//


#import <objc/runtime.h>
#import "UIImage+TBIU_WebP.h"
#import "WebP/decode.h"

static const int kWPUseThreads = 1;

@implementation UIImage (TBIU_WebP)


+ (void)supportWebP {
    static dispatch_once_t _oncePredicate_UIImage;
    dispatch_once(&_oncePredicate_UIImage, ^{
        Class class = [UIImage class];
        Method originalMethod = class_getInstanceMethod(class, @selector(initWithData:));
        Method newMethod = class_getInstanceMethod(class, @selector(initWithNewData:));
        method_exchangeImplementations(originalMethod, newMethod);
    }
    );
}


- (id)initWithNewData:(NSData *)data {
    id image = [self initWithNewData:data];
    if (!image) {
        image = [UIImage decodeWebPFromData:data];
    }
    return image;
}


static void FreeImageData(void *info, const void *data, size_t size);

//webP解码
+ (UIImage *)decodeWebPFromData:(NSData *)myData {
    WebPDecoderConfig _config;
    if (!WebPInitDecoderConfig(&_config)) {
        return nil;
    }
    if (WebPGetFeatures([myData bytes], [myData length], &_config.input) != VP8_STATUS_OK) {
        return nil;
    }

    _config.output.colorspace = MODE_rgbA;
    _config.options.use_threads = kWPUseThreads;
    WebPDecoderConfig *config = &_config;
    // Decode the WebP image data into a RGBA value array.
    if (WebPDecode([myData bytes], [myData length], config) != VP8_STATUS_OK) {
        return nil;
    }

    int width = config->input.width;
    int height = config->input.height;
    if (config->options.use_scaling) {
        width = config->options.scaled_width;
        height = config->options.scaled_height;
    }

    // Construct a UIImage from the decoded RGBA value array.
    CGDataProviderRef provider =
            CGDataProviderCreateWithData(NULL, config->output.u.RGBA.rgba,
                    config->output.u.RGBA.size, FreeImageData
            );
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    CGImageRef imageRef =
            CGImageCreate(width, height, 8, 32, 4 * width, colorSpaceRef, bitmapInfo,
                    provider, NULL, NO, renderingIntent
            );

    CGColorSpaceRelease(colorSpaceRef);
    CGDataProviderRelease(provider);

    UIImage *newImage = [[UIImage alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);

    return newImage;
}

// Callback for CGDataProviderRelease
static void FreeImageData(void *info, const void *data, size_t size) {
    free((void *) data);
}


@end