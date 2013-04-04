//
//  ArticlesViewController.m
//  KongroNews
//
//  Created by Kent Robin Haugen on 27.03.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import "ArticlesViewController.h"
#import "NewsParser.h"
#import "Constants.h"
#import "NewsParser.h"
#import "SKBounceAnimation.h"
#import "CategoriesViewController.h"
#import "HelpMethods.h"
#import "SVPullToRefresh.h"
#import "SingleArticleViewController.h"
#import "RootViewController.h"
#import "NewsReadingEvent.h"
#import "GeoLocation.h"

@interface ArticlesViewController (){
    NSArray *newsArray;
    UIAlertView *alertViewForDismissingViewController;
    BOOL isAnimating;
}

@end

@implementation ArticlesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initNewsArray];
    [self setUpPageViewController];
    [self addSwipeUpGestureRecognizer];
//    [self addDoubleTapGestureRecognizer];
}

- (void)setUpPageViewController
{
    if (newsArray.count > 0){
        _pageViewController = [[NewsPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:0.0f] forKey:UIPageViewControllerOptionInterPageSpacingKey]];
        
        _pageViewController.delegate = self;
        _pageViewController.dataSource = self;
        NSArray *viewControllers;
        int index = 0;
        SingleArticleViewController *singleArticleViewController = [[SingleArticleViewController alloc] initWithNibName:@"SingleArticleViewController" bundle:nil];
        [singleArticleViewController setNewsArticle:[newsArray objectAtIndex:index]];
        _pageIndex = index;
        viewControllers = [NSArray arrayWithObject:singleArticleViewController];
        [_pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        
        [self addChildViewController:_pageViewController];
        _pageViewController.view.frame = [UIScreen mainScreen].bounds;
        [self.view addSubview:_pageViewController.view];
        [_pageViewController didMoveToParentViewController:self];
        self.view.gestureRecognizers = _pageViewController.gestureRecognizers;
    }
    
}

- (void)initNewsArray
{
    NSArray *similarNews = [NewsParser similarNewsWithUserId:[[UIDevice currentDevice] uniqueDeviceIdentifier] articleId:_newsArticle.articleId location:[[RootViewController lastUpdatedLocation] coordinate]];
    NSMutableArray *allNews = [[NSMutableArray alloc] initWithObjects:_newsArticle, nil];
    [allNews addObjectsFromArray:similarNews];
    newsArray = [NSArray arrayWithArray:allNews];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (_shouldAnimateFromMainView) {
        [self setStartPositionForAnimationForTop];
        [self startBounceInAnimation];
    }
    else if (_shouldAnimateFromWebView) {
        [self setStartPositionForAnimationForBottom];
        [self startBounceInAnimation];
    }
    [SVProgressHUD dismiss];
    _shouldAnimateFromMainView = NO;
    _shouldAnimateFromWebView = NO;
}

- (void)setStartPositionForAnimationForTop
{
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    frame.origin.y = -(frame.size.height);
    self.view.frame = frame;
}

- (void)setStartPositionForAnimationForBottom
{
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    frame.origin.y = (frame.size.height);
    self.view.frame = frame;
}

- (void)startBounceInAnimation
{
    NSString *keyPath = @"position.y";
    CGRect frame = [[UIScreen mainScreen] bounds];
    CGPoint center = CGPointMake(frame.size.width/2, frame.size.height/2);
    id finalValue = [NSNumber numberWithFloat:center.y];
    
    SKBounceAnimation *bounceAnimation = [SKBounceAnimation animationWithKeyPath:keyPath];
    bounceAnimation.fromValue = [NSNumber numberWithFloat:self.view.center.y];
    bounceAnimation.toValue = finalValue;
    bounceAnimation.duration = ANIMATION_DURATION;
    bounceAnimation.numberOfBounces = ANIMATION_NUMBER_OF_BOUNCES;
    bounceAnimation.shouldOvershoot = ANIMATION_SHOULD_OVERSHOOT;
    
    [self.view.layer addAnimation:bounceAnimation forKey:@"someKey"];
    [self.view.layer setValue:finalValue forKeyPath:keyPath];
}

- (void)addSwipeUpGestureRecognizer
{
    UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUpMade:)];
    [swipeGestureRecognizer setNumberOfTouchesRequired:1];
    [swipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionUp];
    swipeGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:swipeGestureRecognizer];
}

- (void)swipeUpMade:(UISwipeGestureRecognizer*)swipeGesture
{
    if (!isAnimating) [self closeViewSliding];
}

- (void)addDoubleTapGestureRecognizer
{
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
    doubleTap.numberOfTouchesRequired = 1;
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];
}

- (void)doubleTapAction:(UITapGestureRecognizer *)tap
{
    
}

- (void)closeViewSliding
{
    CGRect rect = self.view.frame;
    [UIView animateWithDuration:0.3f animations:^{
        [self.view setFrame:CGRectMake(rect.origin.x, -(rect.size.height), rect.size.width, rect.size.height)];
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)setUserInteractionEnabledAgain
{
    isAnimating = NO;
    [self.view setUserInteractionEnabled:YES];
}

- (void)addViewedRelatedArticleToEventQueue:(id)relatedArticleId
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSNumber *relatedArtId = (NSNumber *)relatedArticleId;
        NSString *GUID = [[NSUUID UUID] UUIDString];
        NSString *artId = [NSString stringWithFormat:@"%d", _newsArticle.articleId];
        NSString *similarArtId = [NSString stringWithFormat:@"%d", [relatedArtId intValue]];
        CLLocation *location = [RootViewController lastUpdatedLocation];
        GeoLocation *geoLocation = [[GeoLocation alloc] initWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
        NewsReadingEvent *event = [[NewsReadingEvent alloc] initWithGlobalIdentifier:GUID articleId:artId userId:[[UIDevice currentDevice] uniqueDeviceIdentifier] eventType:NewsReadingEventViewedSimilarArticle timeStamp:[NSDate date] geoLocation:geoLocation properties:[[NSDictionary alloc] initWithObjectsAndKeys:similarArtId, @"similarArticleId", nil]];
        [NewsReadingEvent addEventToQueue:event];
    });
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:@"Ingen artikler lagret"] || [alertView.title isEqualToString:@"Ingen nyheter"]) {
        [self closeViewSliding];
    }
}

#pragma mark - PageViewControllerDelegate and Datasource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    SingleArticleViewController *currentSingleNewsVC = (SingleArticleViewController *)viewController;
    NSUInteger currentIndex = [newsArray indexOfObject:currentSingleNewsVC.newsArticle];
    if (currentIndex == 0) {
        return nil;
    }
    else{
        SingleArticleViewController *prevVC = [[SingleArticleViewController alloc] initWithNibName:@"SingleArticleViewController" bundle:nil];
        [prevVC setNewsArticle:[newsArray objectAtIndex:currentIndex - 1]];
        return prevVC;
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    SingleArticleViewController *currentSingleNewsVC = (SingleArticleViewController *)viewController;
    NSUInteger currentIndex = [newsArray indexOfObject:currentSingleNewsVC.newsArticle];
    if (currentIndex == newsArray.count - 1) {
        return nil;
    }
    else{
        SingleArticleViewController *nextVC = [[SingleArticleViewController alloc] initWithNibName:@"SingleArticleViewController" bundle:nil];
        [nextVC setNewsArticle:[newsArray objectAtIndex:currentIndex + 1]];
        return nextVC;
    }
    
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

#pragma mark - UIPageViewControllerDelegate methods

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    [self.view setUserInteractionEnabled:NO];
    isAnimating = YES;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (finished){
        [self setUserInteractionEnabledAgain];
    }
    if (completed) {
        SingleArticleViewController *snvc = (SingleArticleViewController *)[[pageViewController viewControllers] lastObject];
        if (_newsArticle.articleId != snvc.newsArticle.articleId) {
            [self performSelectorInBackground:@selector(addViewedRelatedArticleToEventQueue:) withObject:[NSNumber numberWithInt:snvc.newsArticle.articleId]];
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
    {
        UIPanGestureRecognizer *panGestureRecognizer = (UIPanGestureRecognizer *) otherGestureRecognizer;
        CGPoint distance = [panGestureRecognizer translationInView:self.view];
        [panGestureRecognizer cancelsTouchesInView];
        if (distance.x > 0 && abs(distance.y) < abs(distance.x)) { // right
            return NO;
        } else if (distance.x < 0 && abs(distance.y) < abs(distance.x)) { //left
            return NO;
        }
        if (distance.y > 0 && abs(distance.y) > abs(distance.x)) { // down
            return YES;
        } else if (distance.y < 0 && abs(distance.y) > abs(distance.x)) { //up
            return YES;
        }
        
    }
    return NO;
}
@end
