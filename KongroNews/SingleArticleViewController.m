//
//  SingleArticleViewController.m
//  KongroNews
//
//  Created by Kent Robin Haugen on 27.03.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import "SingleArticleViewController.h"
#import "Colors.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Constants.h"
#import "MapViewController.h"
#import "NSDate+TimeSince.h"
#import "KRHTextView.h"
#import "RootViewController.h"
#import "GeoLocation.h"
#import "NewsReadingEvent.h"

@interface SingleArticleViewController (){
    BOOL isFullScreen;
    UIWindow *textWindow;
    KRHTextView *textView;
    int counter;
    NSDate *timeLoaded;
}
@end

@implementation SingleArticleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self addNotificationObserverFromKRHTextView];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setUpUI];
    [self addDoubleTapGestureRecognizer];
    [self addLongPressGestureRecognizer];
    [self addNotificationObserverFromKRHTextView];
    if ([RootViewController isFirstRun]) {
        [self setUpPopUp];
    }
    
    timeLoaded = [NSDate date];
    
    NSLog(@"number of locations: %d", _newsArticle.locations.count);
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self performSelectorInBackground:@selector(addTimeSpentToEventQueue) withObject:nil];
}

- (void)setUpUI
{
    _titleLabel.text = _newsArticle.title;
    _leadTextLabel.text = _newsArticle.leadText;
    _bodyTextView.text = _newsArticle.bodyText;
    [self trimBodyTextViewText];
    _publisherLabel.text = _newsArticle.publisher;
    _timeSinceLabel.text = [_newsArticle.published timeSinceFromDate];
    NSString *cats = @"";
    for (NSString *cat in _newsArticle.categories) {
        cats  = [cats stringByAppendingString:[NSString stringWithFormat:@"%@ ", cat]];
    }
    _categoryLabel.text = cats;
    
    _mapButton.hidden = _newsArticle.locations.count > 0 ? NO : YES;
    if (_newsArticle.images.count > 0) {
        [_imageView setImageWithURL:[_newsArticle.images objectAtIndex:0]];
        //        [_imageView setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:_newsArticle.imageUrl]]];
        UIView *filterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _imageView.frame.size.width, _imageView.frame.size.height)];
        [filterView setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.3f]];
        [_imageView addSubview:filterView];
    }
    else {
        int random = arc4random() % NUMBER_OF_GRADIENTS;
        CAGradientLayer *gradient;
        switch (random) {
            case 0:
                gradient = [Colors redGradientWithFrame:_imageView.frame];
                break;
            case 1:
                gradient = [Colors greenGradientWithFrame:_imageView.frame];
                break;
            case 2:
                gradient = [Colors blueGradientWithFrame:_imageView.frame];
                break;
            case 3:
                gradient = [Colors purpleGradientWithFrame:_imageView.frame];
                break;
            case 4:
                gradient = [Colors purpleGreenGradientWithFrame:_imageView.frame];
                break;
            default:
                gradient = [Colors blueGradientWithFrame:_imageView.frame];
                break;
        }
        UIImage *placeholderImage = [[UIImage alloc] init];
        [_imageView setImage:placeholderImage];
        [_imageView.layer insertSublayer:gradient atIndex:0];
        UIView *filterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _imageView.frame.size.width, _imageView.frame.size.height)];
        [filterView setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.3f]];
        [_imageView addSubview:filterView];
        
    }
}

- (void)setUpPopUp
{
    CMPopTipView *popTip;
    popTip = [[CMPopTipView alloc] initWithMessage:@"Dra til venstre for å lese relaterte artikler."];
    [popTip setTextColor:[UIColor whiteColor]];
    [popTip setTextFont:[UIFont fontWithName:BUTTON_FONT_TYPE size:BUTTON_FONT_SIZE]];
    [popTip setBackgroundColor:[Colors help]];
    [popTip setDismissTapAnywhere:YES];
    [popTip setDelegate:self];
    [popTip presentPointingAtView:_bodyTextView inView:self.view animated:YES];
    counter = 0;
}

- (void)trimBodyTextViewText
{
    if (IS_IPHONE_5) {
        if (_bodyTextView.text.length > 700) {
            NSString *text = [_bodyTextView.text substringToIndex:700];
            _bodyTextView.text = [NSString stringWithFormat:@"%@%@", text, @"..."];
        }
    }
    else {
        if (_bodyTextView.text.length > 500) {
            NSString *text = [_bodyTextView.text substringToIndex:500];
            _bodyTextView.text = [NSString stringWithFormat:@"%@%@", text, @"..."];
        }
    }
    
}

- (void)addNotificationObserverFromKRHTextView
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideLargeTextView) name:@"KRHTextViewPinchActionTriggered" object:nil];
}

- (void)addLongPressGestureRecognizer
{
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    longPress.delegate = self;
    longPress.numberOfTouchesRequired = 1;
    longPress.minimumPressDuration = 0.5f;
    [self.view addGestureRecognizer:longPress];
}

- (IBAction)longPressAction:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self showLargeTextView];
    }
}

- (void)showLargeTextView
{
    isFullScreen = YES;
    CGRect screen = [[UIScreen mainScreen] bounds];
    screen.origin.x = screen.size.width/2;
    screen.origin.y = screen.size.height/2;
    screen.size.height = 0.0f;
    screen.size.width = 0.0f;
    
    textWindow = [[UIWindow alloc] initWithFrame:screen];
    textWindow.center = screen.origin;
    [textWindow setWindowLevel:UIWindowLevelAlert];
    [textWindow setHidden:NO];
    textView = [[KRHTextView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
    textView.text = _newsArticle.bodyText;
    
    [textWindow addSubview:textView];
    [textWindow makeKeyAndVisible];
    
    [UIView animateWithDuration:0.5f animations:^{
        textWindow.frame = [[UIScreen mainScreen] bounds];
        textView.frame = [[UIScreen mainScreen] bounds];
    }];
    
}

- (void)hideLargeTextView
{
    isFullScreen = NO;
    CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    [ani setDuration:0.5];
    [ani setDelegate:self];
    [ani setRepeatCount:1];
    [ani setFromValue:[NSNumber numberWithFloat:1.0]];
    [ani setToValue:[NSNumber numberWithFloat:0.0]];
    [ani setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[textWindow layer] addAnimation:ani forKey:@"zoom"];
}

- (void)addDoubleTapGestureRecognizer
{
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    doubleTap.delegate = self;
    [self.view addGestureRecognizer:doubleTap];
}

- (IBAction)doubleTapAction:(id)sender
{
    if (_newsArticle.locations.count > 0) {
        [self performSelectorInBackground:@selector(addViewedMapToEventQueue) withObject:nil];
        [self showMapView];
    }
}

- (void)showMapView
{
    MapViewController *mapViewController = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
    [mapViewController setNewsArticle:_newsArticle];
    [self presentViewController:mapViewController animated:YES completion:nil];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag && !isFullScreen) {
        [textView removeFromSuperview];
        [textWindow removeFromSuperview];
        textView = nil;
        textWindow = nil;
    }
}

- (void)addTimeSpentToEventQueue
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *GUID = [[NSUUID UUID] UUIDString];
        NSString *artId = [NSString stringWithFormat:@"%d", _newsArticle.articleId];
        CLLocation *location = [RootViewController lastUpdatedLocation];
        GeoLocation *geoLocation = [[GeoLocation alloc] initWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
        float seconds = fabsf([timeLoaded timeIntervalSinceNow]);
        NSString *secondsUsed = [NSString stringWithFormat:@"%f", seconds];
        NewsReadingEvent *event = [[NewsReadingEvent alloc] initWithGlobalIdentifier:GUID articleId:artId userId:[[UIDevice currentDevice] uniqueDeviceIdentifier] eventType:NewsReadingEventTimeSpentArticleView timeStamp:[NSDate date] geoLocation:geoLocation properties:[[NSDictionary alloc] initWithObjectsAndKeys:secondsUsed, @"duration", nil]];
        [NewsReadingEvent addEventToQueue:event];
    });
}

- (void)addViewedMapToEventQueue
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *GUID = [[NSUUID UUID] UUIDString];
        NSString *artId = [NSString stringWithFormat:@"%d", _newsArticle.articleId];
        CLLocation *location = [RootViewController lastUpdatedLocation];
        GeoLocation *geoLocation = [[GeoLocation alloc] initWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
        NewsReadingEvent *event = [[NewsReadingEvent alloc] initWithGlobalIdentifier:GUID articleId:artId userId:[[UIDevice currentDevice] uniqueDeviceIdentifier] eventType:NewsReadingEventViewedMap timeStamp:[NSDate date] geoLocation:geoLocation properties:nil];
        [NewsReadingEvent addEventToQueue:event];
    });
}

#pragma mark - CMPopTipViewDelegate Methods
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    CMPopTipView *popTip = [[CMPopTipView alloc] init];
    [popTip setTextColor:[UIColor whiteColor]];
    [popTip setTextFont:[UIFont fontWithName:BUTTON_FONT_TYPE size:BUTTON_FONT_SIZE]];
    [popTip setBackgroundColor:[Colors help]];
    [popTip setDismissTapAnywhere:YES];
    [popTip setDelegate:self];
    
    if (counter == 0) {
        
        [popTip setMessage:@"Hold nede én finger på teksten for å lese hele artikkelteksten. Hold nede én finger igjen for å lukke artikkelteksten."];
        [popTip presentPointingAtView:_bodyTextView inView:self.view animated:YES];
        counter++;
    }
    else if (counter == 1) {
        [popTip setMessage:@"Dobbeltklikk med én finger for å vise hvor nyheten omhandler på kart. Dobbelklikk på kartet for å lukke det igjen."];
        [popTip presentPointingAtView:_bodyTextView inView:self.view animated:YES];
        counter++;
    }
    else if (counter == 2) {
        [popTip setMessage:@"Dra opp for å gå tilbake til forrige skjerm."];
        [popTip presentPointingAtView:_bodyTextView inView:self.view animated:YES];
        [RootViewController setIsFirstRun:NO];
        counter++;

    }
}

- (IBAction)mapButtonAction:(UIButton *)sender {
    if (_newsArticle.locations.count > 0) {
        [self performSelectorInBackground:@selector(addViewedMapToEventQueue) withObject:nil];
        [self showMapView];
    }
}
@end
