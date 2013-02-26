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

#define ADMOB_PUBLISHER_ID @"a1512b63e1b9dcd"

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
    switch (_categoryTag) {
        case CATEGORY_TAG_TECHNOLOGY:
            newsArray = [NewsParser newsList:URL_TECHNOLOGY];
            break;
            
        default:
            newsArray = [NewsParser newsList:URL_TOP_STORIES];
            break;
    }
    startLoadIndex = 0;
    stopLoadIndex = 10 < newsArray.count ? 10 : newsArray.count;
    
    _singleNewsVCs = [[NSMutableArray alloc] initWithCapacity:newsArray.count];
    
    [self setUpScrollView];
    [self addFirstNewsArticlesToScreen];
    [self addSwipeUpGestureRecognizer];
    [self setUpAdBanner];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    CGRect rect = self.view.frame;
    [self.view setFrame:CGRectMake(rect.origin.x, -(rect.size.height), rect.size.width, rect.size.height)];
    [UIView animateWithDuration:0.3f animations:^{
        self.view.frame = rect;
    }];
}

- (void)setUpScrollView
{
    _rootScrollView.delegate = self;
    [_rootScrollView setCanCancelContentTouches:NO];
    _rootScrollView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    _rootScrollView.clipsToBounds = YES;
    _rootScrollView.scrollEnabled = YES;
    _rootScrollView.pagingEnabled = YES;
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
    NSLog(@"swipe was triggered");
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
    stopLoadIndex = stopLoadIndex + 10 < newsArray.count ? stopLoadIndex + 10 : newsArray.count;
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
        stopLoadIndex = stopLoadIndex + 10 < newsArray.count ? stopLoadIndex + 10 : newsArray.count;
    });
}

- (void)setUpAdBanner
{
    //testbanner
    GADRequest *request = [GADRequest request];
    request.testDevices = [NSArray arrayWithObjects:@"45bb0197558362b5510cb23b37188af6", nil];
    
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
        NSLog(@"start: %d, stop %d",startLoadIndex, stopLoadIndex);
        return;
    }
    float scrollViewWidth = scrollView.frame.size.width;
    float scrollContentSizeWidth = scrollView.contentSize.width;
    float scrollOffset = scrollView.contentOffset.x;
    
    if (scrollOffset + scrollViewWidth == scrollContentSizeWidth)
    {
        NSLog(@"scroll at end");
        [self performSelectorInBackground:@selector(addNewsArticlesToScrollView) withObject:nil];
        NSLog(@"start: %d, stop %d",startLoadIndex, stopLoadIndex);
    }
}

@end
