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

#define ADMOB_PUBLISHER_ID @"a1512b63e1b9dcd"

#define NUMBER_OF_NEWS_TO_GET 5

@interface TopStoriesViewController (){
    NSArray *newsArray;
    int startLoadIndex;
    int stopLoadIndex;
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
    
    [self initNewsArray];
    _singleNewsVCs = [[NSMutableArray alloc] initWithCapacity:newsArray.count];
    
    [self setUpScrollView];
    [self addFirstNewsArticlesToScreen];
    [self addSwipeUpGestureRecognizer];
    [self setUpAdBanner];
}

- (void)initNewsArray
{
    switch (_categoryTag) {
        case CATEGORY_TAG_TECHNOLOGY:
            newsArray = [NewsParser newsList:URL_TECHNOLOGY];
            break;
        case CATEGORY_TAG_SCIENCE:
            newsArray = [NewsParser newsList:URL_SCIENCE];
            break;
        case CATEGORY_TAG_SPORT:
            newsArray = [NewsParser newsList:URL_SPORT];
            break;
        case CATEGORY_TAG_ECONOMY:
            newsArray = [NewsParser newsList:URL_ECONOMY];
            break;
        case CATEGORY_TAG_ENTERTAINMENT:
            newsArray = [NewsParser newsList:URL_ENTERTAINMENT];
            break;
        case CATEGORY_TAG_ENGINE:
            newsArray = [NewsParser newsList:URL_ENGINE];
            break;
        case CATEGORY_TAG_FAVORITES:
            [self loadFavorites];
            break;
        default:
            newsArray = [NewsParser newsList:URL_TOP_STORIES];
            break;
    }
    startLoadIndex = 0;
    stopLoadIndex = NUMBER_OF_NEWS_TO_GET < newsArray.count ? NUMBER_OF_NEWS_TO_GET : newsArray.count;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self setStartPositionForAnimation];
    [self startBounceInAnimation];
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
    [_rootScrollView setCanCancelContentTouches:NO];
    _rootScrollView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    _rootScrollView.clipsToBounds = YES;
    _rootScrollView.scrollEnabled = YES;
    _rootScrollView.pagingEnabled = YES;
    _rootScrollView.directionalLockEnabled = YES;
}

- (void)addSwipeUpGestureRecognizer
{
    UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeMade:)];
    [swipeGestureRecognizer setNumberOfTouchesRequired:1];
    [swipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.view addGestureRecognizer:swipeGestureRecognizer];
}

- (void)swipeMade:(UISwipeGestureRecognizer*)swipeGesture
{
    if (swipeGesture.direction == UISwipeGestureRecognizerDirectionUp) {
        CGRect rect = self.view.frame;
        [UIView animateWithDuration:0.3f animations:^{
            [self.view setFrame:CGRectMake(rect.origin.x, -(rect.size.height), rect.size.width, rect.size.height)];
        } completion:^(BOOL finished) {
            [self dismissViewControllerAnimated:NO completion:nil];
        }];
    }
}

- (void)addFirstNewsArticlesToScreen
{
    for (int i=startLoadIndex; i<stopLoadIndex; i++) {
        SingleNewsViewController *singleNewsController = [[SingleNewsViewController alloc] initWithNibName:@"SingleNewsViewController" bundle:nil];
        [singleNewsController setNewsArticle:[newsArray objectAtIndex:i]];
        [singleNewsController.view setFrame:CGRectMake(i*_rootScrollView.frame.size.width, 0, _rootScrollView.frame.size.width, _rootScrollView.frame.size.height)];
        [singleNewsController setShouldAnimate:NO];
        [singleNewsController setParentScrollView:_rootScrollView];
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
            [singleNewsController setParentScrollView:_rootScrollView];
            [_singleNewsVCs addObject:singleNewsController];
            [_rootScrollView addSubview:singleNewsController.view];
        }
        [_rootScrollView setContentSize:CGSizeMake(_rootScrollView.frame.size.width * stopLoadIndex, _rootScrollView.frame.size.height)];
        startLoadIndex = stopLoadIndex;
        stopLoadIndex = stopLoadIndex + NUMBER_OF_NEWS_TO_GET < newsArray.count ? stopLoadIndex + NUMBER_OF_NEWS_TO_GET : newsArray.count;
        [SVProgressHUD dismiss];
    });
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
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ingen artikler lagret" message:@"Ingen artikler er lagt til i favoritter. Dette kan gjøres ved å holde nede på en artikkel og trykke på stjerneikonet." delegate:self cancelButtonTitle:@"Lukk" otherButtonTitles:nil];
        [alertView show];
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
        return;
    }
    float scrollViewWidth = scrollView.frame.size.width;
    float scrollContentSizeWidth = scrollView.contentSize.width;
    float scrollOffset = scrollView.contentOffset.x;
    
    if (scrollOffset + scrollViewWidth == scrollContentSizeWidth)
    {
        NSString *status = [HelpMethods randomLoadText];
        [SVProgressHUD showWithStatus:status maskType:SVProgressHUDMaskTypeBlack];
        [self performSelectorInBackground:@selector(addNewsArticlesToScrollView) withObject:nil];
    }
}

@end
