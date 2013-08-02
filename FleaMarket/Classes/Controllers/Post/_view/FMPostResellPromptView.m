// 
// Created by henson on 7/31/13.
// Copyright (c) 2012 Taobao, inc. All rights reserved.
// 

#import "FMPostResellPromptView.h"

@implementation FMPostResellPromptView {

}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = FMColorWithRed(233, 233, 233);

        UIImage *image = [UIImage imageNamed:@"post_resell_prompt_icon.png"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(83, 21, image.size.width, image.size.height);
        [self addSubview:imageView];

        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(113, 21, 150, 20)];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.textColor = FMColorWithRed(130, 130, 130);
        textLabel.text = @"转卖已买到的宝贝";
        textLabel.font = FMFont(NO, 15);
        [self addSubview:textLabel];
    }

    return self;
}

@end