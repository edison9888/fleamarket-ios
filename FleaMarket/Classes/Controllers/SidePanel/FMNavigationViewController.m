//
// Created by yuanxiao on 13-4-25.
//
// To change the template use AppCode | Preferences | File Templates.
//



#define KEY_WINDOW  [[UIApplication sharedApplication] keyWindow]
#define FM_NAV_TRANSFORM       0.95
#define FM_NAV_ALPHA           0.40
#define FM_NAV_ANIMATION_TIME  0.35

#import "FMNavigationViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface FMNavigationViewController ()


@property (nonatomic,retain) UIView *backgroundView;
@property (nonatomic,retain) NSMutableArray *screenShotsList;

@end

@implementation FMNavigationViewController {
@private
    BOOL           _isMoving;
    CGPoint        _startTouch;

    UIImageView    *_lastScreenShotView;
    UIView         *_blackMask;

    UIPanGestureRecognizer *_recognizer;
}


@synthesize isCloseDrag = _isCloseDrag;

- (id)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        // Custom initialization

        self.screenShotsList = [[NSMutableArray alloc]initWithCapacity:2];
        self.isCloseDrag = NO;

    }
    return self;
}

- (void)dealloc {
    self.screenShotsList = nil;
    [self.backgroundView removeFromSuperview];
    self.backgroundView = nil;
}

- (void)initLastScreenShotView:(CGPoint)touchPoint {
    _isMoving = YES;
    _startTouch = touchPoint;

    if (!self.backgroundView) {
        CGRect frame = self.view.frame;

        self.backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)];
        [self.view.superview insertSubview:self.backgroundView belowSubview:self.view];
        self.backgroundView.backgroundColor = [UIColor blackColor];
        _blackMask = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)];
        _blackMask.backgroundColor = [UIColor blackColor];
        [self.backgroundView addSubview:_blackMask];
    }

    self.backgroundView.hidden = NO;

    if (_lastScreenShotView)
        [_lastScreenShotView removeFromSuperview];

    UIImage *lastScreenShot = [self.screenShotsList lastObject];
    _lastScreenShotView = [[UIImageView alloc]initWithImage:lastScreenShot];
    [self.backgroundView insertSubview:_lastScreenShotView belowSubview:_blackMask];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _recognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self
                                                         action:@selector(panGestureReceive:)];
    _recognizer.delegate = self;
    [_recognizer delaysTouchesBegan];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (!animated) {
        [super pushViewController:viewController animated:animated];
        [self setPanGestureEnabled];
        return;
    }
    NSDate *date1 = [NSDate date];
    if (self.viewControllers.count >= 1) {
        UIViewController *lastViewController = [self.viewControllers lastObject];
        [self.screenShotsList addObject:[self capture:lastViewController.view]];
    }

    NSDate *date2 = [NSDate date];
    FMLog(@"capture time:%f", [date2 timeIntervalSinceDate:date1]);
    [super pushViewController:viewController animated:NO];

    if (self.viewControllers.count > 1) {
        [self initLastScreenShotView:CGPointZero];
        CGRect frame = self.view.frame;
        frame.origin.x = FM_SCREEN_WIDTH;
        self.view.frame = frame;
        _lastScreenShotView.transform = CGAffineTransformMakeScale(1, 1);
        _blackMask.alpha = 0;
        [UIView animateWithDuration:FM_NAV_ANIMATION_TIME animations:^{
            CGRect rect = self.view.frame;
            rect.origin.x = 0;
            self.view.frame = rect;

            _lastScreenShotView.transform = CGAffineTransformMakeScale(FM_NAV_TRANSFORM, FM_NAV_TRANSFORM);
            _blackMask.alpha = FM_NAV_ALPHA;
        }                completion:^(BOOL finished) {
            [self setPanGestureEnabled];
            self.backgroundView.hidden = YES;
        }];
    }

}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    if (!animated) {
        [super popViewControllerAnimated:animated];
        [self setPanGestureEnabled];
        return nil;
    }
    if (self.viewControllers.count <= 1) {
        return nil;
    }
    [self initLastScreenShotView:CGPointZero];

    _lastScreenShotView.transform = CGAffineTransformMakeScale(FM_NAV_TRANSFORM, FM_NAV_TRANSFORM);
    _blackMask.alpha = FM_NAV_ALPHA;
    [UIView animateWithDuration:FM_NAV_ANIMATION_TIME animations:^{
        CGRect frame = self.view.frame;
        frame.origin.x = FM_SCREEN_WIDTH;
        self.view.frame = frame;

        _lastScreenShotView.transform = CGAffineTransformMakeScale(1, 1);
        _blackMask.alpha = 0;
    } completion:^(BOOL finished) {
        [self popViewControllerHelp];
    }];
    return nil;
}

- (void)popViewControllerHelp {
    [self.screenShotsList removeLastObject];
    [super popViewControllerAnimated:NO];

    CGRect frame = self.view.frame;
    frame.origin.x = 0;
    self.view.frame = frame;

    if (self.viewControllers.count <= 1) {
        [self.screenShotsList removeAllObjects];
        [self.backgroundView removeFromSuperview];
        self.backgroundView = nil;
    }
    self.backgroundView.hidden = YES;
    [self setPanGestureEnabled];
}

- (void)setPanGestureEnabled {
    if ([[self.viewControllers lastObject] conformsToProtocol:@protocol(FMNeedClosePanGestureProtocol)]) {
        [self.view removeGestureRecognizer:_recognizer];
    } else {
        [self.view addGestureRecognizer:_recognizer];
    }
}

// get the current view screen shot
- (UIImage *)capture:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];

    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (void)moveViewWithX:(float)x {
    x = x > FM_SCREEN_WIDTH ? FM_SCREEN_WIDTH : x;
    x = x < 0 ? 0 : x;

    CGRect frame = self.view.frame;
    frame.origin.x = x;
    self.view.frame = frame;

    float scale = (x / 6400) + FM_NAV_TRANSFORM;
    float alpha = FM_NAV_ALPHA - (x / 800);

    _lastScreenShotView.transform = CGAffineTransformMakeScale(scale, scale);
    _blackMask.alpha = alpha;

}

#pragma mark - Gesture Recognizer -
- (void)panGestureReceive:(UIPanGestureRecognizer *)recognizer {
    if (self.viewControllers.count <= 1)
        return;

    CGPoint touchPoint = [recognizer locationInView:KEY_WINDOW];

    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self initLastScreenShotView:touchPoint];
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (touchPoint.x - _startTouch.x > 50) {
            [UIView animateWithDuration:0.3 animations:^{
                [self moveViewWithX:FM_SCREEN_WIDTH];
            } completion:^(BOOL finished) {
                [self popViewControllerHelp];
                _isMoving = NO;
            }];
        }
        else {
            [UIView animateWithDuration:0.3 animations:^{
                [self moveViewWithX:0];
            } completion:^(BOOL finished) {
                _isMoving = NO;
                self.backgroundView.hidden = YES;
            }];
        }
        return;

    } else if (recognizer.state == UIGestureRecognizerStateCancelled) {
        [UIView animateWithDuration:0.3 animations:^{
            [self moveViewWithX:0];
        } completion:^(BOOL finished) {
            _isMoving = NO;
            self.backgroundView.hidden = YES;
        }];
        return;
    }

    if (_isMoving) {
        [self moveViewWithX:touchPoint.x - _startTouch.x];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    UIPanGestureRecognizer *panGestureRecognizer = (UIPanGestureRecognizer *)gestureRecognizer;
    CGPoint translatedPoint = [panGestureRecognizer translationInView:self.view];

    if (self.isCloseDrag) {
        return NO;
    }

    if (translatedPoint.x < 0 || translatedPoint.y != 0) {
        return NO;
    }
    return YES;
}

@end