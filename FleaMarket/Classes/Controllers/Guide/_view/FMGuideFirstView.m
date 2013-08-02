//
// Created by yuanxiao on 13-7-17.
// Copyright (c) 2013 taobao.com. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "FMGuideFirstView.h"
#import "UIImage+Helper.h"


@implementation FMGuideFirstView {

}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = FMColorWithRed(0xf1, 0xf1, 0xf1);
        UIImage *image = [UIImage imageWithFileName:@"guide0@2x.png"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(
                (frame.size.width - image.size.width) / 2,
                (frame.size.height - image.size.height) / 2,
                image.size.width,
                image.size.height);
        [self addSubview:imageView];
    }

    return self;
}

@end