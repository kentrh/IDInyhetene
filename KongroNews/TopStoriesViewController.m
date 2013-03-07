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

#define ADMOB_PUBLISHER_ID @"a1512b63e1b9dcd"

#define NUMBER_OF_NEWS_TO_GET 5

@interface TopStoriesViewController (){
    NSArray *newsArray;
    int startLoadIndex;
    int stopLoadIndex;
    MFMailComposeViewController *mailViewController;
    UISwipeGestureRecognizer *swipeGestureRecognizer;
    UIAlertView *alertViewForDismissingViewController;
}

@end

@implementation TopStoriesViewController

- (void)dealloc
{
    newsArray = nil;
    [_singleNewsVCs removeAllObjects];
}

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
    _singleNewsVCs = [[NSMutableArray alloc] initWithCapacity:newsArray.count];
    
    [self setUpScrollView];
    [self addFirstNewsArticlesToScreen];
    [self addSwipeUpGestureRecognizer];
    [self setUpAdBanner];
    [self addTripleTapGestureRecognizer];
}

- (void)initNewsArrayAndUpdate:(BOOL)shouldUpdate
{
    if (_categoryTag == CATEGORY_TAG_FAVORITES) {
        [self loadFavorites];
        startLoadIndex = 0;
        stopLoadIndex = newsArray.count;
        return;
    }
    else {
        newsArray = [NewsParser newsList:_queryUrl shouldUpdate:shouldUpdate];
        if (!newsArray || [newsArray count] == 0){
            alertViewForDismissingViewController = [[UIAlertView alloc] initWithTitle:@"Ingen nyheter" message:@"Kunne ikke hente nyheter, vennligst sjekk nettverkstilkoplingen og prøv på nytt." delegate:self cancelButtonTitle:@"Lukk" otherButtonTitles: nil];
            [alertViewForDismissingViewController show];
        }
    }
    
    startLoadIndex = 0;
    stopLoadIndex = NUMBER_OF_NEWS_TO_GET < newsArray.count ? NUMBER_OF_NEWS_TO_GET : newsArray.count;
}

- (void)viewDidAppear:(BOOL)animated
{
    if (_shouldAnimate) {
        [self setStartPositionForAnimation];
        [self startBounceInAnimation];
    }
    [SVProgressHUD dismiss];
}

- (void)setStartPositionForAnimation
{
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    frame.origin.y = -(frame.size.height);
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

- (void)setUpScrollView
{
    _rootScrollView.delegate = self;
    if (_categoryTag != CATEGORY_TAG_FAVORITES) {
        __weak TopStoriesViewController *tsvc = self;
        [_rootScrollView addPullToRefreshWithActionHandler:^{
            [TestFlight passCheckpoint:@"TopStories update triggered"];
            [tsvc performSelectorInBackground:@selector(updateNews) withObject:nil];
        }];
        [_rootScrollView.pullToRefreshView setArrowColor:[UIColor whiteColor]];
        [_rootScrollView addInfiniteScrollingWithActionHandler:^{
            [tsvc performSelectorInBackground:@selector(addNewsArticlesToScrollView) withObject:nil];
        }];
        [_rootScrollView.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    }
    [_rootScrollView setCanCancelContentTouches:NO];
    _rootScrollView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    _rootScrollView.clipsToBounds = YES;
    _rootScrollView.scrollEnabled = YES;
    _rootScrollView.pagingEnabled = YES;
    _rootScrollView.directionalLockEnabled = YES;
}

- (void)updateNews
{
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self initNewsArrayAndUpdate:YES];
        if([[[[[_singleNewsVCs objectAtIndex:0] newsArticle] link] absoluteString] isEqualToString:[[[newsArray objectAtIndex:0] link]absoluteString]]){
            startLoadIndex = _singleNewsVCs.count;
            stopLoadIndex = _singleNewsVCs.count + NUMBER_OF_NEWS_TO_GET < newsArray.count ? _singleNewsVCs.count + NUMBER_OF_NEWS_TO_GET : newsArray.count;
            [_rootScrollView.pullToRefreshView stopAnimating];
            return;
        }
        for (SingleNewsViewController *snvc in _singleNewsVCs) {
            [snvc.view removeFromSuperview];
        }
        [_singleNewsVCs removeAllObjects];
        for (int i=startLoadIndex; i<stopLoadIndex; i++) {
            SingleNewsViewController *singleNewsController = [[SingleNewsViewController alloc] initWithNibName:@"SingleNewsViewController" bundle:nil];
            [singleNewsController setNewsArticle:[newsArray objectAtIndex:i]];
            [singleNewsController.view setFrame:CGRectMake(i*_rootScrollView.frame.size.width, 0, _rootScrollView.frame.size.width, _rootScrollView.frame.size.height)];
            [singleNewsController setShouldAnimate:NO];
            [singleNewsController setTsvc:self];
            [_singleNewsVCs addObject:singleNewsController];
            [_rootScrollView addSubview:singleNewsController.view];
        }
        [_rootScrollView setContentSize:CGSizeMake(_rootScrollView.frame.size.width * stopLoadIndex, _rootScrollView.frame.size.height)];
        startLoadIndex = stopLoadIndex;
        stopLoadIndex = stopLoadIndex + NUMBER_OF_NEWS_TO_GET < newsArray.count ? stopLoadIndex + NUMBER_OF_NEWS_TO_GET : newsArray.count;
        [_rootScrollView.pullToRefreshView stopAnimating];
    });
}

- (void)addSwipeUpGestureRecognizer
{
    swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeMade:)];
    [swipeGestureRecognizer setNumberOfTouchesRequired:1];
    [swipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.view addGestureRecognizer:swipeGestureRecognizer];
}

- (void)setCloseSwipeEnabled:(BOOL)isEnabled
{
    swipeGestureRecognizer.enabled = isEnabled;
}

- (void)swipeMade:(UISwipeGestureRecognizer*)swipeGesture
{
    if (swipeGesture.direction == UISwipeGestureRecognizerDirectionUp) {
        [self closeViewSliding];
    }
}

- (void)addTripleTapGestureRecognizer
{
    UITapGestureRecognizer *tripleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToNewest)];
    tripleTap.numberOfTouchesRequired = 1;
    tripleTap.numberOfTapsRequired = 3;
    [self.view addGestureRecognizer:tripleTap];
}

- (void)goToNewest
{
    [_rootScrollView setContentOffset:CGPointZero animated:YES];
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

- (void)addFirstNewsArticlesToScreen
{
    for (int i=startLoadIndex; i<stopLoadIndex; i++) {
        SingleNewsViewController *singleNewsController = [[SingleNewsViewController alloc] initWithNibName:@"SingleNewsViewController" bundle:nil];
        [singleNewsController setNewsArticle:[newsArray objectAtIndex:i]];
        [singleNewsController.view setFrame:CGRectMake(i*_rootScrollView.frame.size.width, 0, _rootScrollView.frame.size.width, _rootScrollView.frame.size.height)];
        [singleNewsController setShouldAnimate:NO];
        [singleNewsController setTsvc:self];
        [_singleNewsVCs addObject:singleNewsController];
        [_rootScrollView addSubview:singleNewsController.view];
    }
    [_rootScrollView setContentSize:CGSizeMake(_rootScrollView.frame.size.width * stopLoadIndex, _rootScrollView.frame.size.height)];
    startLoadIndex = stopLoadIndex;
    stopLoadIndex = stopLoadIndex + NUMBER_OF_NEWS_TO_GET < newsArray.count ? stopLoadIndex + NUMBER_OF_NEWS_TO_GET : newsArray.count;
}

- (void)addNewsArticlesToScrollView
{
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        for (int i=startLoadIndex; i<stopLoadIndex; i++) {
            SingleNewsViewController *singleNewsController = [[SingleNewsViewController alloc] initWithNibName:@"SingleNewsViewController" bundle:nil];
            [singleNewsController setNewsArticle:[newsArray objectAtIndex:i]];
            [singleNewsController.view setFrame:CGRectMake(i*_rootScrollView.frame.size.width, 0, _rootScrollView.frame.size.width, _rootScrollView.frame.size.height)];
            [singleNewsController setShouldAnimate:NO];
            [singleNewsController setTsvc:self];
            [_singleNewsVCs addObject:singleNewsController];
            if (i==startLoadIndex){
                CGRect frame = singleNewsController.view.frame;
                frame.origin.x += frame.size.width;
                singleNewsController.view.frame = frame;
                [_rootScrollView addSubview:singleNewsController.view];
                frame.origin.x -= frame.size.width;
                [UIView animateWithDuration:0.3f animations:^{
                    singleNewsController.view.frame = frame;
                }];
            }
            else {
                [_rootScrollView addSubview:singleNewsController.view];
            }
        }
        [_rootScrollView setContentSize:CGSizeMake(_rootScrollView.frame.size.width * stopLoadIndex, _rootScrollView.frame.size.height)];
        startLoadIndex = stopLoadIndex;
        stopLoadIndex = stopLoadIndex + NUMBER_OF_NEWS_TO_GET < newsArray.count ? stopLoadIndex + NUMBER_OF_NEWS_TO_GET : newsArray.count;
        [_rootScrollView.infiniteScrollingView stopAnimating];
    });
}

- (void)setUpAdBanner
{
    //testbanner
    GADRequest *request = [GADRequest request];
//    request.testDevices = [NSArray arrayWithObjects:@"45bb0197558362b5510cb23b37188af6", GAD_SIMULATOR_ID, nil];
    
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

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (startLoadIndex == stopLoadIndex)
    {
        [_rootScrollView setShowsInfiniteScrolling:NO];
        return;
    }
//    float scrollViewWidth = scrollView.frame.size.width;
//    float scrollContentSizeWidth = scrollView.contentSize.width;
//    float scrollOffset = scrollView.contentOffset.x;
//    
//    if (scrollOffset + scrollViewWidth == scrollContentSizeWidth)
//    {
//        NSString *status = [HelpMethods randomLoadText];
//        [SVProgressHUD showWithStatus:status maskType:SVProgressHUDMaskTypeBlack];
//        [self performSelectorInBackground:@selector(addNewsArticlesToScrollView) withObject:nil];
//    }
}

#pragma mark - MFMailComposerDelegate and methods

- (void)presentMailComposerWithNews:(News *)newsArticle
{
    if ([MFMailComposeViewController canSendMail])
    {
        mailViewController = [[MFMailComposeViewController alloc] init];
        [mailViewController setMailComposeDelegate:self];
        [mailViewController setSubject:@"Interessant artikkel jeg fant via nyhetene for iPhone"];
        [mailViewController setMessageBody:[NSString stringWithFormat:@"%@ \n\n %@", newsArticle.title, [newsArticle.link absoluteString]] isHTML:NO];
        [self presentViewController:mailViewController animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Send mail" message:@"Ingen mailkonto er lagt inn på enheten. Registrer en mailkonto og prøv igjen." delegate:nil cancelButtonTitle:@"Lukk" otherButtonTitles: nil];
        [alertView show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:^{
//        _shouldAnimate = YES;
    }];
}

#pragma mark - UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self closeViewSliding];
}

@end
