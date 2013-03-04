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

@interface RootViewController (){
    FrontPageViewController *frontPageViewController;
    CategoriesViewController *categoriesViewController;
}

@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    [self performSelectorInBackground:@selector(addFrontPageViewAndCategoriesView) withObject:nil];
}

- (void)setUpScrollView
{
    _rootScrollView.delegate = self;
    _rootScrollView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    _rootScrollView.clipsToBounds = YES;
    _rootScrollView.pagingEnabled = YES;
    _rootScrollView.scrollEnabled = YES;
    [_rootScrollView setContentSize:CGSizeMake(_rootScrollView.frame.size.width * 2, _rootScrollView.frame.size.height)];
}

- (void)addBackground
{
    int random = (arc4random() % NUMBER_OF_BACKGROUND_IMAGES) + 1;
    UIImage *backgroundImage = [UIImage imageNamed:[NSString stringWithFormat:@"%d", random]];
    _backgroundImageView.image = backgroundImage;
    UIImage *filterImage = [UIImage imageNamed:@"blackFilter"];
    UIImageView *filterView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [filterView setImage:filterImage];
    [_backgroundImageView addSubview:filterView];
}

- (void)addFrontPageViewAndCategoriesView
{
    [SVProgressHUD showWithStatus:[HelpMethods randomLoadText] maskType:SVProgressHUDMaskTypeBlack];
    dispatch_async(dispatch_get_main_queue(), ^{
        frontPageViewController = [[FrontPageViewController alloc] initWithNibName:@"FrontPageViewController" bundle:nil];
        frontPageViewController.parentScrollView = _rootScrollView;
        categoriesViewController = [[CategoriesViewController alloc] initWithNibName:@"CategoriesViewController" bundle:nil];
        categoriesViewController.parentScrollView = _rootScrollView;
        
        [_rootScrollView addSubview:frontPageViewController.view];
        [_rootScrollView addSubview:categoriesViewController.view];
        [SVProgressHUD dismiss];
    });
}

- (void)refreshMainPages
{
    [categoriesViewController.view removeFromSuperview];
    categoriesViewController = nil;
    [frontPageViewController.view removeFromSuperview];
    frontPageViewController = nil;
    [self addFrontPageViewAndCategoriesView];
    
}

- (void)addRefreshGesture
{
    UILongPressGestureRecognizer *doubletouch = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(refreshMainPages)];
    doubletouch.numberOfTouchesRequired = 2;
    [self.view addGestureRecognizer:doubletouch];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
