//
// Created by yuanxiao on 12-11-1.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import <QuartzCore/QuartzCore.h>
#import "FMItemImageViewController.h"
#import "FMImageScrollView.h"
#import "TBMBBind.h"
#import "FMImageView.h"
#import "FMCommon.h"

@interface FMItemImageViewController ()

- (void)initImagesScrollView;

@end

@implementation FMItemImageViewController {
@private
    UIScrollView        *_imageScrollView;
    NSString            *_titleText;
    int                 _count;
    int                 _page;
    NSArray             *_images;
    NSInteger           _lastPage;
    BOOL                _isNeedLoad;
    CGFloat             _lastPosition;
}

@synthesize images = _images;
@synthesize titleText = _titleText;


- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView {
    [super loadView];
    self.titleView.hidden = YES;
    _imageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, FM_SCREEN_HEIGHT - 20)];
	_imageScrollView.contentSize = CGSizeMake(320, FM_SCREEN_HEIGHT - 20 - 44);
	_imageScrollView.showsHorizontalScrollIndicator = NO;
    TBMBAutoNilDelegate(UIScrollView *, _imageScrollView, delegate, self);
	_imageScrollView.scrollEnabled = YES;
	_imageScrollView.pagingEnabled = YES;
	_imageScrollView.backgroundColor = [UIColor whiteColor];

    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    tap1.numberOfTapsRequired = 1;
    tap1.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:tap1];

    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    tap2.numberOfTapsRequired = 2;
    tap2.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:tap2];
    [tap1 requireGestureRecognizerToFail:tap2];

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    longPress.minimumPressDuration = 2;
    [self.view addGestureRecognizer:longPress];

    [self initImagesScrollView];

    [self initTitle];
}

- (void)initImagesScrollView {
    _count = [_images count];
	_imageScrollView.contentSize = CGSizeMake(_count * 320, FM_SCREEN_HEIGHT - 20);
    CGRect rect = CGRectMake(0, 0, 320, FM_SCREEN_HEIGHT - 20);
	for (NSUInteger i = 0; i < [_images count]; i++) {
        if (![[_images objectAtIndex:i] isKindOfClass:[NSString class]]) {
            return;
        }
        
        NSString *url = [_images objectAtIndex:i];
        FMImageScrollView *scrollView = [[FMImageScrollView alloc] initWithFrame:rect];
        rect.origin.x += 320;
        scrollView.imageUrl = url;
        scrollView.tag = 10000 + i;
		
		[_imageScrollView addSubview:scrollView];
	}
    [self showNext:NO prev:NO];
	[_imageScrollView scrollRectToVisible:CGRectMake(0 + 320 * _page, 0, 320, FM_SCREEN_HEIGHT - 20 - 44) animated:NO];
    [self.view addSubview:_imageScrollView];
}

- (void)initTitle {
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(260, 15, 65, 30)];
    [self.view addSubview:titleView];
    UILabel *currentView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 29, 30)];
    currentView.font = [UIFont boldSystemFontOfSize:26.f];
    currentView.backgroundColor = [UIColor clearColor];
    self.titleText = [NSString stringWithFormat:@"0%d", _page + 1];
    TBMBBindObjectStrong(tbKeyPath(self, titleText), currentView, ^(UILabel *host, id old, id new) {
        host.text = new;
    });
    [titleView addSubview:currentView];

    UILabel *totalView = [[UILabel alloc] initWithFrame:CGRectMake(29, 3, 25, 30)];
    totalView.font = [UIFont systemFontOfSize:16.f];
    totalView.backgroundColor = [UIColor clearColor];
    totalView.text = [NSString stringWithFormat:@"/0%d", [_images count]];
    [titleView addSubview:totalView];
    titleView.hidden = YES;
    [self performSelector:@selector(titleAnimation:) withObject:titleView afterDelay:0.5];
}

- (void)titleAnimation:(UIView *)titleView {
    titleView.hidden = NO;
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];

    positionAnimation.duration = 0.5f;
    CGMutablePathRef path = CGPathCreateMutable();
    //移动到开始坐标
    CGPathMoveToPoint(path, NULL, titleView.frame.origin.x + titleView.frame.size.width/2, 0);
    //添加路劲坐标点   先移动到 靠近位置
    CGPathAddLineToPoint(path, NULL, titleView.frame.origin.x + titleView.frame.size.width/2, titleView.frame.origin.y + titleView.frame.size.height/2 - 10);
    //移动到  超出位置  看起来有反弹效果
    CGPathAddLineToPoint(path, NULL, titleView.frame.origin.x + titleView.frame.size.width/2, titleView.frame.origin.y + titleView.frame.size.height/2 + 15);
    //最终的坐标
    CGPathAddLineToPoint(path, NULL, titleView.frame.origin.x + titleView.frame.size.width/2, titleView.frame.origin.y + titleView.frame.size.height/2);
    positionAnimation.path = path;
    CGPathRelease(path);
    positionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [titleView.layer addAnimation:positionAnimation forKey:@"move"];
}

- (void)tapGesture:(UITapGestureRecognizer *)sender {
    if (sender.numberOfTapsRequired == 1) {
        CATransition *transition = [CATransition animation];
        transition.duration = 0.3;
        transition.type = kCATransitionFade;//可更改为其他方式
        transition.subtype = kCATransitionFade;//可更改为其他方式
        [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
        [self.navigationController popViewControllerAnimated:NO];
    } else if (sender.numberOfTapsRequired == 2) {
        FMImageScrollView *view = (FMImageScrollView *) [_imageScrollView viewWithTag:10000 + _page];
        CGFloat zs = view.zoomScale;
        zs = (zs == 1.0) ? 2.0 : 1.0;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        view.zoomScale = zs;
        [UIView commitAnimations];
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)gesture {
    if ([gesture state] == UIGestureRecognizerStateBegan) {
        FMImageScrollView *view = (FMImageScrollView *) [_imageScrollView viewWithTag:10000 + _page];
        UIImage *image = [view.imageView image];
        if (image) {
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        [FMCommon showToast:self.view text:@"保存图片到相册失败"];
    } else{
        [FMCommon showToast:self.view text:@"保存图片到相册成功"];
    }
}

#pragma mark  UIScrollView Delegate
//ScrollView 划动的动画结束后调用.
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	CGFloat pageWidth = scrollView.frame.size.width;
	NSInteger page = (NSInteger)floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	
	if (_lastPage != page)
	{
        FMImageScrollView *view = (FMImageScrollView *)[_imageScrollView viewWithTag:10000 + _lastPage];
		view.zoomScale = 1.0;
        _lastPage = page;
	}
	_page = page;
    self.titleText = [NSString stringWithFormat:@"0%d", _page + 1];
}


- (void)scrollToPage:(int)page {
	_page = page;
    [_imageScrollView scrollRectToVisible:CGRectMake(0 + 320 * page, 0, 320, FM_SCREEN_HEIGHT - 20) animated:NO];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _isNeedLoad = YES;
}

- (void)showNext:(BOOL)bNext prev:(BOOL)bPrev {
    NSInteger page = _page;
    if (bNext) {
        page += 1;
    }
    if (bPrev) {
        page -= 1;
    }
    FMImageScrollView *view = (FMImageScrollView *)[_imageScrollView viewWithTag:10000 + page];
    if (view) {
        [view downLoad];
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat currentPosition = scrollView.contentOffset.x;
    if (_lastPosition == 0 || !_isNeedLoad) {
        _lastPosition = currentPosition;
        return;
    }
    if (currentPosition > _lastPosition) {
        [self showNext:YES prev:NO];
        _isNeedLoad = NO;
    }
    else if (currentPosition < _lastPosition) {
        [self showNext:NO prev:YES];
        _isNeedLoad = NO;
    }

    _lastPosition = currentPosition;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    _imageScrollView.delegate = nil;
    FMLog(@"dealloc %@", [self description]);
}

@end
