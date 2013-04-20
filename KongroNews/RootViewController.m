//
//  RootViewController.m
//  KongroNews
//
//  Created by Kent Robin Haugen on 24.02.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import "RootViewController.h"
#import "FrontPageViewController.h"
#import "CategoriesViewController.h"
#import "Constants.h"
#import "HelpMethods.h"
#import "SettingsViewController.h"
#import "SVPullToRefresh.h"
#import "GeoLocation.h"

@interface RootViewController (){
    FrontPageViewController *frontPageViewController;
    CategoriesViewController *categoriesViewController;
    SettingsViewController *settingsViewController;
}

@end

@implementation RootViewController

static bool isFirstRun;
static CLLocation *lastUpdatedLocation;

+ (BOOL)isFirstRun
{
    return isFirstRun;
}

+ (void)setIsFirstRun:(BOOL)firstRun
{
    isFirstRun = firstRun;
}

+ (CLLocation *)lastUpdatedLocation
{
    return lastUpdatedLocation;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        [locationManager startUpdatingLocation];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self addBackground];
    [self setUpScrollView];
    [self addRefreshGesture];
    [self setIsFirstRun];
    [self performSelectorInBackground:@selector(addFrontPageView) withObject:nil];
}

- (void)setIsFirstRun
{
    NSString *isFirst = [[NSUserDefaults standardUserDefaults] objectForKey:@"firstRun"];
    if (!isFirst) {
        isFirstRun = YES;
        [[NSUserDefaults standardUserDefaults] setObject:@"firstRun" forKey:@"firstRun"];
    }
}

- (void)setUpScrollView
{
    _rootScrollView.delegate = self;
    _rootScrollView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    _rootScrollView.clipsToBounds = YES;
    _rootScrollView.pagingEnabled = YES;
    _rootScrollView.scrollEnabled = YES;
    [_rootScrollView setContentSize:CGSizeMake(_rootScrollView.frame.size.width * 2, _rootScrollView.frame.size.height)];
    __weak RootViewController *rvc = self;
    [_rootScrollView addPullToRefreshWithActionHandler:^{
        [rvc performSelectorInBackground:@selector(updateFrontPageNews) withObject:nil];
    }];
    [_rootScrollView.pullToRefreshView setArrowColor:[UIColor whiteColor]];
}

- (void)updateFrontPageNews
{
    [frontPageViewController.activityIndicator startAnimating];
    [frontPageViewController updateFrontPageNews];
}

- (void)addBackground
{
    int random = (arc4random() % NUMBER_OF_BACKGROUND_IMAGES) + 1;
    UIImage *backgroundImage = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg", random]];
    _backgroundImageView.image = backgroundImage;
    UIImage *filterImage;
    if (IS_IPHONE_5) filterImage = [UIImage imageNamed:@"blackFilter5"];
    else filterImage = [UIImage imageNamed:@"blackFilter"];
    UIImageView *filterView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [filterView setImage:filterImage];
    [_backgroundImageView addSubview:filterView];
}

- (void)addFrontPageView
{
#warning PROBABLY NULL POINTER HERE
    [SVProgressHUD showWithStatus:[HelpMethods randomLoadText] maskType:SVProgressHUDMaskTypeBlack];
    if (!lastUpdatedLocation) {
        NSData *locationData = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_PREVIOUS_LOCATION];
        if (locationData) {
            CLLocation *storedLocation = [NSKeyedUnarchiver unarchiveObjectWithData:locationData];
            lastUpdatedLocation = storedLocation;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        frontPageViewController = [[FrontPageViewController alloc] initWithNibName:@"FrontPageViewController" bundle:nil];
        frontPageViewController.parentScrollView = _rootScrollView;
        [self addChildViewController:frontPageViewController];
        [_rootScrollView addSubview:frontPageViewController.view];
        [SVProgressHUD dismiss];
        [self addCategoryView];
    });
}

- (void)addCategoryView
{
    categoriesViewController = [[CategoriesViewController alloc] initWithNibName:@"CategoriesViewController" bundle:nil];
    categoriesViewController.parentScrollView = _rootScrollView;
    [self addChildViewController:categoriesViewController];
    [_rootScrollView addSubview:categoriesViewController.view];
}

- (void)refreshMainPages
{

    for (UIView *view in _rootScrollView.subviews) {
        [view removeFromSuperview];
    }
    categoriesViewController = nil;
    frontPageViewController = nil;
    __weak RootViewController *rvc = self;
    [_rootScrollView addPullToRefreshWithActionHandler:^{
        [rvc performSelectorInBackground:@selector(updateFrontPageNews) withObject:nil];
    }];
    [self addFrontPageView];
    
}

- (void)addRefreshGesture
{
    UILongPressGestureRecognizer *doubletouch = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(refreshMainPages)];
    doubletouch.numberOfTouchesRequired = 3;
    [self.view addGestureRecognizer:doubletouch];
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

#pragma mark - CLLocationManagerDelegate methods
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    lastUpdatedLocation = [locations lastObject];
}

@end
