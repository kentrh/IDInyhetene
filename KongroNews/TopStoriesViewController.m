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
#import "WebViewController.h"

#define ADMOB_PUBLISHER_ID @"a1512b63e1b9dcd"

@interface TopStoriesViewController (){
    NSArray *newsArray;
    UIAlertView *alertViewForDismissingViewController;
    BOOL animationIsFinished;
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
    [self setUpAdBanner];
//    [self setUpPullToRefresh];
    
}

- (void)setUpPageViewController
{
    _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    _pageViewController.delegate = self;
    _pageViewController.dataSource = self;
    NSArray *viewControllers;
    if (newsArray.count > 0){
        SingleNewsViewController *singleNewsVC = [[SingleNewsViewController alloc] initWithNibName:@"SingleNewsViewController" bundle:nil];
        [singleNewsVC setNewsArticle:[newsArray objectAtIndex:0]];
        [singleNewsVC setPageIndex:1];
        _pageIndex = 0;
        viewControllers = [NSArray arrayWithObject:singleNewsVC];
    }
    [_pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:_pageViewController];
    _pageViewController.view.frame = CGRectMake(0, 0, 320, 430);
    [self.view addSubview:_pageViewController.view];
    [_pageViewController didMoveToParentViewController:self];
    self.view.gestureRecognizers = _pageViewController.gestureRecognizers;
}

- (void)setUpPullToRefresh
{
    UIScrollView *pullToRefreshView = [[UIScrollView alloc] initWithFrame:_pageViewController.view.frame];
    pullToRefreshView.contentSize = _pageViewController.view.frame.size;
    __weak TopStoriesViewController *tsvc = self;
    [pullToRefreshView addPullToRefreshWithActionHandler:^{
        [tsvc performSelectorInBackground:@selector(updateData) withObject:nil];
    }];
    [_pageViewController.view addSubview:pullToRefreshView];
}

- (void)updateData
{
    dispatch_async(dispatch_get_main_queue(), ^{
//        News *currentFirst = [newsArray objectAtIndex:0];
        [self initNewsArrayAndUpdate:YES];
        if (newsArray.count > 0) {
//            News *newCurrent = [newsArray objectAtIndex:0];
//            if ([currentFirst.link.absoluteString isEqualToString:newCurrent.link.absoluteString]) {
//                [SVProgressHUD dismiss];
//                return;
//            }
            SingleNewsViewController *snvc = [[SingleNewsViewController alloc] initWithNibName:@"SingleNewsViewController" bundle:nil];
            [snvc setNewsArticle:[newsArray objectAtIndex:0]];
            [snvc setPageIndex:1];
            _pageIndex = 0;
            [_pageViewController setViewControllers:[NSArray arrayWithObject:snvc] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
            [SVProgressHUD dismiss];
        }
        
    });
}

- (void)initNewsArrayAndUpdate:(BOOL)shouldUpdate
{
    if (_categoryTag == CATEGORY_TAG_FAVORITES) {
        [self loadFavorites];
        return;
    }
    else {
        newsArray = [NewsParser newsList:_queryUrl shouldUpdate:shouldUpdate];
        if (!newsArray || [newsArray count] == 0){
            alertViewForDismissingViewController = [[UIAlertView alloc] initWithTitle:@"Ingen nyheter" message:@"Fant ingen nyheter!" delegate:self cancelButtonTitle:@"Lukk" otherButtonTitles: nil];
            [alertViewForDismissingViewController show];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    if (_shouldAnimateFromMainView) {
        [self setStartPositionForAnimationForTop];
    }
    else if (_shouldAnimateFromWebView) {
        [self setStartPositionForAnimationForBottom];
    }
    [self startBounceInAnimation];
    [SVProgressHUD dismiss];
    animationIsFinished = YES;
}

- (void)setStartPositionForAnimationForTop
{
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    frame.origin.y = -(frame.size.height);
    if (_categoryTag) {
        frame.origin.x = frame.size.width;
    }
    self.view.frame = frame;
}

- (void)setStartPositionForAnimationForBottom
{
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    frame.origin.y = (frame.size.height);
    if (_categoryTag) {
        frame.origin.x = frame.size.width;
    }
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
        [TestFlight passCheckpoint:@"SingleNews show web article swipe"];
        _shouldAnimateFromMainView = NO;
        _shouldAnimateFromWebView = YES;
        NSString *status = [HelpMethods randomLoadText];
        [SVProgressHUD showWithStatus:status maskType:SVProgressHUDMaskTypeBlack];
        CGRect rect = self.view.frame;
        [UIView animateWithDuration:0.3f animations:^{
            [self.view setFrame:CGRectMake(rect.origin.x, rect.size.height, rect.size.width, rect.size.height)];
        } completion:^(BOOL finished) {
            WebViewController *webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
            [webViewController setNews:[newsArray objectAtIndex:_pageIndex]];
            [self presentViewController:webViewController animated:NO completion:nil];
        }];
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
    [self closeViewSliding];
}

- (void)addDoubleTapGestureRecognizer
{
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToNewest:)];
    doubleTap.numberOfTouchesRequired = 1;
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];
}

- (void)goToNewest:(UITapGestureRecognizer *)tap
{
//    [SVProgressHUD showWithStatus:@"Oppdaterer" maskType:SVProgressHUDMaskTypeBlack];
//    [self performSelectorInBackground:@selector(updateData) withObject:nil];
    alertViewForDismissingViewController = [[UIAlertView alloc] initWithTitle:@"Gå til artikkelside" message:[NSString stringWithFormat:@"Må være mellom 1 og %d.",[newsArray count]] delegate:self cancelButtonTitle:@"Avbryt" otherButtonTitles:@"Gå", nil];
    [alertViewForDismissingViewController setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[alertViewForDismissingViewController textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDecimalPad];
    [alertViewForDismissingViewController show];    
}

- (void)closeViewSliding
{
//    if (animationIsFinished) {
        CGRect rect = self.view.frame;
        [UIView animateWithDuration:0.3f animations:^{
            [self.view setFrame:CGRectMake(rect.origin.x, -(rect.size.height), rect.size.width, rect.size.height)];
        } completion:^(BOOL finished) {
            [self dismissViewControllerAnimated:NO completion:nil];
        }];
//    }
}

- (void)setUpAdBanner
{
    //testbanner
    GADRequest *request = [GADRequest request];
    request.testDevices = [NSArray arrayWithObjects:@"45bb0197558362b5510cb23b37188af6", GAD_SIMULATOR_ID, nil];
    
    _adBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner origin:CGPointMake(self.view.frame.origin.x, self.view.frame.size.height)];
    _adBannerView.delegate = self;
    _adBannerView.adUnitID = ADMOB_PUBLISHER_ID;
    _adBannerView.rootViewController = self;
    [self.view addSubview:_adBannerView];
    [_adBannerView loadRequest:request];
    
}

- (void)adViewDidReceiveAd:(GADBannerView *)view
{
    [UIView animateWithDuration:0.3f animations:^{
        CGRect rect = [[UIScreen mainScreen] bounds];
        _adBannerView.frame = CGRectMake(rect.origin.x, rect.size.height - _adBannerView.frame.size.height, _adBannerView.frame.size.width, _adBannerView.frame.size.height);
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
    if (animationIsFinished) {
        SingleNewsViewController *currentSingleNewsVC = (SingleNewsViewController *)viewController;
        NSUInteger currentIndex = [newsArray indexOfObject:currentSingleNewsVC.newsArticle];
        if (currentIndex == 0) {
            animationIsFinished = YES;
            return nil;
        }
        else{
            SingleNewsViewController *prevVC = [[SingleNewsViewController alloc] initWithNibName:@"SingleNewsViewController" bundle:nil];
            [prevVC setNewsArticle:[newsArray objectAtIndex:currentIndex - 1]];
            [prevVC setPageIndex:currentIndex];
            animationIsFinished = NO;
            return prevVC;
        }
    }
    else return nil;

}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    if (animationIsFinished) {
        SingleNewsViewController *currentSingleNewsVC = (SingleNewsViewController *)viewController;
        NSUInteger currentIndex = [newsArray indexOfObject:currentSingleNewsVC.newsArticle];
        if (currentIndex == newsArray.count - 1) {
            animationIsFinished = YES;
            return nil;
        }
        else{
            SingleNewsViewController *nextVC = [[SingleNewsViewController alloc] initWithNibName:@"SingleNewsViewController" bundle:nil];
            [nextVC setNewsArticle:[newsArray objectAtIndex:currentIndex + 1]];
            [nextVC setPageIndex:currentIndex+2];
            animationIsFinished = NO;
            return nextVC;
        }
    }
    else return nil;
    
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return newsArray.count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (finished){
        animationIsFinished = YES;
    }
    if (completed) {
        SingleNewsViewController *snvc = (SingleNewsViewController *) [[pageViewController childViewControllers] lastObject];
        _pageIndex = [snvc pageIndex] - 1;
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}
@end
