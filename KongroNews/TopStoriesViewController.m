//
//  TopStoriesViewController.m
//  KongroNews
//
//  Created by Kent Robin Haugen on 18.02.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import "TopStoriesViewController.h"
#import "NewsParser.h"
#import "Constants.h"
#import "SingleNewsViewController.h"
#import "NewsParser.h"
#import "SKBounceAnimation.h"
#import "CategoriesViewController.h"
#import "HelpMethods.h"
#import "SVPullToRefresh.h"
#import "ArticlesViewController.h"
#import "RootViewController.h"
#import "GeoLocation.h"
#import "NewsReadingEvent.h"

@interface TopStoriesViewController (){
    NSArray *newsArray;
    UIAlertView *alertViewForDismissingViewController;
    BOOL isAnimating;
}

@end

@implementation TopStoriesViewController

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
    
    [self initNewsArrayAndUpdate:NO];
    [self setUpPageViewController];
    [self addSwipeUpGestureRecognizer];
    [self addSwipeDownGestureRecognizer];
    [self addDoubleTapGestureRecognizer];
}

- (void)setUpPageViewController
{
    if (newsArray.count > 0){
        _pageViewController = [[NewsPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:0.0f] forKey:UIPageViewControllerOptionInterPageSpacingKey]];
        
        _pageViewController.delegate = self;
        _pageViewController.dataSource = self;
        NSArray *viewControllers;
        SingleNewsViewController *singleNewsVC = [[SingleNewsViewController alloc] initWithNibName:@"SingleNewsViewController" bundle:nil];
        int index = [self getStartIndex];
        [singleNewsVC setNewsArticle:[newsArray objectAtIndex:index]];
        [singleNewsVC setPageIndex:index+1];
        _pageIndex = index;
        viewControllers = [NSArray arrayWithObject:singleNewsVC];
        [_pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        
        [self addChildViewController:_pageViewController];
        _pageViewController.view.frame = [UIScreen mainScreen].bounds;
        [self.view addSubview:_pageViewController.view];
        [_pageViewController didMoveToParentViewController:self];
        self.view.gestureRecognizers = _pageViewController.gestureRecognizers;
    }
    
}

- (int)getStartIndex
{
    if (_query) return 0;
    int previousArticleId = [NewsParser lastViewedArticleByCategory:_category];
    if (previousArticleId != 0){
        for (int i=0; i<newsArray.count; i++) {
            News *news = (News *)[newsArray objectAtIndex:i];
            if (previousArticleId == news.articleId) {
                return i;
            }
        }
    }
    return 0;
}

- (void)updateData
{
    [SVProgressHUD showWithStatus:@"Oppdaterer" maskType:SVProgressHUDMaskTypeBlack];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self initNewsArrayAndUpdate:YES];
        if (newsArray.count > 0) {
            for (UIView *view in self.view.subviews) {
                [view removeFromSuperview];
            }
            [NewsParser setLastViewedArticleByCategory:_category lastViewedArticleId:0];
            [_pageViewController removeFromParentViewController];
            _pageViewController = nil;
            [self setUpPageViewController];
            [self addSwipeUpGestureRecognizer];
            [self addSwipeDownGestureRecognizer];
            [self addDoubleTapGestureRecognizer];
            [SVProgressHUD dismiss];
        }
        
    });
}

- (void)initNewsArrayAndUpdate:(BOOL)shouldUpdate
{
    if ([_category isEqualToString:CATEGORY_FAVORITE_NEWS]) {
        [self loadFavorites];
        return;
    }
    else if([_category isEqualToString:CATEGORY_RELEVANT_NEWS]) {
        newsArray = [NewsParser relevantNewsWithUserId:[[UIDevice currentDevice] uniqueDeviceIdentifier] location:[[RootViewController lastUpdatedLocation] coordinate] shouldUpdate:shouldUpdate];
    }
    else if(_query.length > 0) {
        newsArray = [NewsParser relevantNewsWithUserId:[[UIDevice currentDevice] uniqueDeviceIdentifier] location:[[RootViewController lastUpdatedLocation] coordinate] query:_query];
    }
    else {
        newsArray = [NewsParser relevantNewsWithUserId:[[UIDevice currentDevice] uniqueDeviceIdentifier] location:[[RootViewController lastUpdatedLocation] coordinate] category:_category shouldUpdate:shouldUpdate];
    }
    if (!newsArray || [newsArray count] == 0){
        alertViewForDismissingViewController = [[UIAlertView alloc] initWithTitle:@"Ingen nyheter" message:@"Fant ingen nyheter!" delegate:self cancelButtonTitle:@"Lukk" otherButtonTitles: nil];
        [alertViewForDismissingViewController show];
    }
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
    _shouldAnimateFromWebView = NO;
    _shouldAnimateFromMainView = NO;
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

- (void)addSwipeDownGestureRecognizer
{
    UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDownMade:)];
    [swipeGestureRecognizer setNumberOfTouchesRequired:1];
    [swipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionDown];
    swipeGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:swipeGestureRecognizer];
}

- (void)swipeDownMade:(UISwipeGestureRecognizer*)swipeGesture
{
    if (!isAnimating) [self showFullArticleView];
}

- (void)showFullArticleView
{
    News *newsArticle = [newsArray objectAtIndex:_pageIndex];
    
    [TestFlight passCheckpoint:@"TopStoriesView: Show full article swipe."];
    [self performSelectorInBackground:@selector(addOpenedArticleToEventQueue:) withObject:[NSNumber numberWithInt:newsArticle.articleId]];
    
    _shouldAnimateFromMainView = NO;
    _shouldAnimateFromWebView = YES;
    NSString *status = [HelpMethods randomLoadText];
    [SVProgressHUD showWithStatus:status maskType:SVProgressHUDMaskTypeBlack];
    CGRect rect = self.view.frame;
    [UIView animateWithDuration:0.3f animations:^{
        [self.view setFrame:CGRectMake(rect.origin.x, rect.size.height, rect.size.width, rect.size.height)];
    } completion:^(BOOL finished) {
        ArticlesViewController *articlesViewController = [[ArticlesViewController alloc] initWithNibName:@"ArticlesViewController" bundle:nil];
        [articlesViewController setNewsArticle:newsArticle];
        [articlesViewController setShouldAnimateFromMainView:YES];
        [self presentViewController:articlesViewController animated:NO completion:nil];
    }];
}

- (void)addOpenedArticleToEventQueue:(id)obj
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSNumber *intValue = (NSNumber *)obj;
        int articleId = [intValue intValue];
        NSString *GUID = [[NSUUID UUID] UUIDString];
        NSString *artId = [NSString stringWithFormat:@"%d", articleId];
        CLLocation *location = [RootViewController lastUpdatedLocation];
        GeoLocation *geoLocation = [[GeoLocation alloc] initWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
        NewsReadingEvent *event = [[NewsReadingEvent alloc] initWithGlobalIdentifier:GUID articleId:artId userId:[[UIDevice currentDevice] uniqueDeviceIdentifier] eventType:NewsReadingEventOpenedArticleView timeStamp:[NSDate date] geoLocation:geoLocation properties:nil];
        [NewsReadingEvent addEventToQueue:event];
    });
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
    [TestFlight passCheckpoint:@"TopStoriesView: Update called."];
    [self performSelectorInBackground:@selector(updateData) withObject:nil];
}

- (void)closeViewSliding
{
    if (newsArray.count > 0 && !_query) {
        News *news = [newsArray objectAtIndex:_pageIndex];
        [NewsParser setLastViewedArticleByCategory:_category lastViewedArticleId:news.articleId];
    }
    
    CGRect rect = self.view.frame;
    [UIView animateWithDuration:0.3f animations:^{
        [self.view setFrame:CGRectMake(rect.origin.x, -(rect.size.height), rect.size.width, rect.size.height)];
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (void)loadFavorites
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"starredArticles"];
    if (data) {
        newsArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if (newsArray.count > 0){
            return;
        }
    }
    if (newsArray.count == 0 || !data) {
        alertViewForDismissingViewController = [[UIAlertView alloc] initWithTitle:@"Ingen artikler lagret" message:@"Ingen artikler er lagt til i favoritter. Dette kan gjøres ved å holde nede på en artikkel og trykke på stjerneikonet." delegate:self cancelButtonTitle:@"Lukk" otherButtonTitles:nil];
        [alertViewForDismissingViewController show];
    }
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

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:@"Ingen artikler lagret"] || [alertView.title isEqualToString:@"Ingen nyheter"]) {
        [self closeViewSliding];
    }
    else if ([alertView.title isEqualToString:@"Gå til artikkelside"]) {
        if (alertView.cancelButtonIndex == buttonIndex) {
            return;
        }
        else {
            int index =  [[[alertView textFieldAtIndex:0] text] intValue];
            if (index > 0 && index <= newsArray.count) {
                UIPageViewControllerNavigationDirection direction = index > _pageIndex ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
                _pageIndex = index-1;
                SingleNewsViewController *snvc = [[SingleNewsViewController alloc] initWithNibName:@"SingleNewsViewController" bundle:nil];
                [snvc setNewsArticle:[newsArray objectAtIndex:index-1]];
                [snvc setPageIndex:index];
                [_pageViewController setViewControllers:[NSArray arrayWithObject:snvc] direction:direction animated:YES completion:nil];
            }
        }

    }
}

#pragma mark - PageViewControllerDelegate and Datasource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    SingleNewsViewController *currentSingleNewsVC = (SingleNewsViewController *)viewController;
    NSUInteger currentIndex = [newsArray indexOfObject:currentSingleNewsVC.newsArticle];
    if (currentIndex == 0) {
        return nil;
    }
    else{
        SingleNewsViewController *prevVC = [[SingleNewsViewController alloc] initWithNibName:@"SingleNewsViewController" bundle:nil];
        [prevVC setNewsArticle:[newsArray objectAtIndex:currentIndex - 1]];
        [prevVC setPageIndex:currentIndex];
        return prevVC;
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    SingleNewsViewController *currentSingleNewsVC = (SingleNewsViewController *)viewController;
    NSUInteger currentIndex = [newsArray indexOfObject:currentSingleNewsVC.newsArticle];
    if (currentIndex == newsArray.count - 1) {
        return nil;
    }
    else{
        SingleNewsViewController *nextVC = [[SingleNewsViewController alloc] initWithNibName:@"SingleNewsViewController" bundle:nil];
        [nextVC setNewsArticle:[newsArray objectAtIndex:currentIndex + 1]];
        [nextVC setPageIndex:currentIndex+2];
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
        SingleNewsViewController *snvc = (SingleNewsViewController *)[[pageViewController viewControllers] lastObject];
        _pageIndex = [snvc pageIndex] - 1;
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
