//
//  CategoriesViewController.m
//  KongroNews
//
//  Created by Kent Robin Haugen on 24.02.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import "CategoriesViewController.h"
#import "Constants.h"
#import "Colors.h"
#import "TopStoriesViewController.h"
#import "SKBounceAnimation.h"
#import "HelpMethods.h"

#define BUTTON_WIDTH 280.0f
#define BUTTON_HEIGHT 50.0f
#define BUTTON_Y 20.0f
#define BUTTON_X 20.0f
#define BUTTON_VERTICAL_SPACING 20.0f
#define BUTTON_FONT_TYPE @"AmericanTypewriter"
#define BUTTON_FONT_SIZE 18.0f

@interface CategoriesViewController ()

@end

@implementation CategoriesViewController

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
    [self addCategoryButtons];
    [self setStartPositionForAnimation];
}

- (void)viewDidAppear:(BOOL)animated
{
    _parentScrollView.scrollEnabled = YES;
    [self setStartPositionForAnimation];
    [self startBounceInAnimation];
    
}

- (void)setStartPositionForAnimation
{
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    frame.origin.x = frame.size.width;
    frame.origin.y = frame.size.height;
    self.view.frame = frame;
}

- (void)startBounceInAnimation
{
    NSString *keyPath = @"position.y";
    CGRect frame = [[UIScreen mainScreen] bounds];
    frame.origin.x = frame.size.width;
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
    
    [_rootScrollView setBackgroundColor:[UIColor clearColor]];
    _rootScrollView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    _rootScrollView.clipsToBounds = NO;
    _rootScrollView.scrollEnabled = YES;
    _rootScrollView.pagingEnabled = NO;
    
}

- (void)addCategoryButtons
{
    UIButton *topStories = [UIButton buttonWithType:UIButtonTypeCustom];
    topStories.frame = CGRectMake(BUTTON_X, BUTTON_Y, BUTTON_WIDTH, BUTTON_HEIGHT);
    [topStories addTarget:self action:@selector(showFrontPage) forControlEvents:UIControlEventTouchUpInside];
    [topStories setBackgroundColor:[Colors green]];
    [topStories setTitle:CATEGORY_TOP_STORIES forState:UIControlStateNormal];
    [topStories setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [topStories setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [topStories.titleLabel setFont:[UIFont fontWithName:BUTTON_FONT_TYPE size:BUTTON_FONT_SIZE]];
    
    UIButton *technology = [UIButton buttonWithType:UIButtonTypeCustom];
    technology.frame = CGRectMake(BUTTON_X, topStories.frame.origin.y + BUTTON_HEIGHT + BUTTON_VERTICAL_SPACING, BUTTON_WIDTH, BUTTON_HEIGHT);
    [technology addTarget:self action:@selector(showNewsArticles:) forControlEvents:UIControlEventTouchUpInside];
    [technology setBackgroundColor:[Colors lightBlue]];
    [technology setTitle:CATEGORY_TECHNOLOGY forState:UIControlStateNormal];
    [technology setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [technology setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [technology setTag:CATEGORY_TAG_TECHNOLOGY];
    [technology.titleLabel setFont:[UIFont fontWithName:BUTTON_FONT_TYPE size:BUTTON_FONT_SIZE]];
    
    UIButton *science = [UIButton buttonWithType:UIButtonTypeCustom];
    science.frame = CGRectMake(BUTTON_X, technology.frame.origin.y + BUTTON_HEIGHT + BUTTON_VERTICAL_SPACING, BUTTON_WIDTH, BUTTON_HEIGHT);
    [science addTarget:self action:@selector(showNewsArticles:) forControlEvents:UIControlEventTouchUpInside];
    [science setBackgroundColor:[Colors lightBlue]];
    [science setTitle:CATEGORY_SCIENCE forState:UIControlStateNormal];
    [science setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [science setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [science setTag:CATEGORY_TAG_SCIENCE];
    [science.titleLabel setFont:[UIFont fontWithName:BUTTON_FONT_TYPE size:BUTTON_FONT_SIZE]];
    
    UIButton *sport = [UIButton buttonWithType:UIButtonTypeCustom];
    sport.frame = CGRectMake(BUTTON_X, science.frame.origin.y + BUTTON_HEIGHT + BUTTON_VERTICAL_SPACING, BUTTON_WIDTH, BUTTON_HEIGHT);
    [sport addTarget:self action:@selector(showNewsArticles:) forControlEvents:UIControlEventTouchUpInside];
    [sport setBackgroundColor:[Colors lightBlue]];
    [sport setTitle:CATEGORY_SPORT forState:UIControlStateNormal];
    [sport setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sport setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [sport setTag:CATEGORY_TAG_SPORT];
    [sport.titleLabel setFont:[UIFont fontWithName:BUTTON_FONT_TYPE size:BUTTON_FONT_SIZE]];
    
    UIButton *economy = [UIButton buttonWithType:UIButtonTypeCustom];
    economy.frame = CGRectMake(BUTTON_X, sport.frame.origin.y + BUTTON_HEIGHT + BUTTON_VERTICAL_SPACING, BUTTON_WIDTH, BUTTON_HEIGHT);
    [economy addTarget:self action:@selector(showNewsArticles:) forControlEvents:UIControlEventTouchUpInside];
    [economy setBackgroundColor:[Colors lightBlue]];
    [economy setTitle:CATEGORY_ECONOMY forState:UIControlStateNormal];
    [economy setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [economy setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [economy setTag:CATEGORY_TAG_ECONOMY];
    [economy.titleLabel setFont:[UIFont fontWithName:BUTTON_FONT_TYPE size:BUTTON_FONT_SIZE]];
    
    UIButton *entertainment = [UIButton buttonWithType:UIButtonTypeCustom];
    entertainment.frame = CGRectMake(BUTTON_X, economy.frame.origin.y + BUTTON_HEIGHT + BUTTON_VERTICAL_SPACING, BUTTON_WIDTH, BUTTON_HEIGHT);
    [entertainment addTarget:self action:@selector(showNewsArticles:) forControlEvents:UIControlEventTouchUpInside];
    [entertainment setBackgroundColor:[Colors lightBlue]];
    [entertainment setTitle:CATEGORY_ENTERTAINMENT forState:UIControlStateNormal];
    [entertainment setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [entertainment setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [entertainment setTag:CATEGORY_TAG_ENTERTAINMENT];
    [entertainment.titleLabel setFont:[UIFont fontWithName:BUTTON_FONT_TYPE size:BUTTON_FONT_SIZE]];
    
    UIButton *engine = [UIButton buttonWithType:UIButtonTypeCustom];
    engine.frame = CGRectMake(BUTTON_X, entertainment.frame.origin.y + BUTTON_HEIGHT + BUTTON_VERTICAL_SPACING, BUTTON_WIDTH, BUTTON_HEIGHT);
    [engine addTarget:self action:@selector(showNewsArticles:) forControlEvents:UIControlEventTouchUpInside];
    [engine setBackgroundColor:[Colors lightBlue]];
    [engine setTitle:CATEGORY_ENGINE forState:UIControlStateNormal];
    [engine setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [engine setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [engine setTag:CATEGORY_TAG_ENGINE];
    [engine.titleLabel setFont:[UIFont fontWithName:BUTTON_FONT_TYPE size:BUTTON_FONT_SIZE]];
    
    UIButton *favorites = [UIButton buttonWithType:UIButtonTypeCustom];
    favorites.frame = CGRectMake(BUTTON_X, engine.frame.origin.y + BUTTON_HEIGHT + BUTTON_VERTICAL_SPACING, BUTTON_WIDTH, BUTTON_HEIGHT);
    [favorites addTarget:self action:@selector(showNewsArticles:) forControlEvents:UIControlEventTouchUpInside];
    [favorites setBackgroundColor:[Colors orange]];
    [favorites setTitle:CATEGORY_FAVORITES forState:UIControlStateNormal];
    [favorites setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [favorites setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [favorites setTag:CATEGORY_TAG_FAVORITES];
    [favorites.titleLabel setFont:[UIFont fontWithName:BUTTON_FONT_TYPE size:BUTTON_FONT_SIZE]];
    
    [_rootScrollView addSubview:topStories];
    [_rootScrollView addSubview:technology];
    [_rootScrollView addSubview:science];
    [_rootScrollView addSubview:sport];
    [_rootScrollView addSubview:economy];
    [_rootScrollView addSubview:entertainment];
    [_rootScrollView addSubview:engine];
    [_rootScrollView addSubview:favorites];
    
    [_rootScrollView setContentSize:CGSizeMake(self.view.frame.size.width, favorites.frame.origin.y + BUTTON_HEIGHT + BUTTON_VERTICAL_SPACING)];
    
}

- (void)showFrontPage
{
//    _parentScrollView.scrollEnabled = NO;
//    CGRect rect = CGRectMake(self.view.frame.origin.x, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
//    [UIView animateWithDuration:0.3f animations:^{
//        self.view.frame = rect;
//    } completion:^(BOOL finished) {
//        TopStoriesViewController *topStoriesViewController = [[TopStoriesViewController alloc] initWithNibName:@"TopStoriesViewController" bundle:nil];
//        [self presentViewController:topStoriesViewController animated:NO completion:nil];
//    }];
    [_parentScrollView setContentOffset:CGPointZero animated:YES];
}

- (void)showNewsArticles:(UIButton *)sender
{
    NSString *status = [HelpMethods randomLoadText];
    [SVProgressHUD showWithStatus:status maskType:SVProgressHUDMaskTypeBlack];
    _parentScrollView.scrollEnabled = NO;
    CGRect rect = CGRectMake(self.view.frame.origin.x, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    [UIView animateWithDuration:0.3f animations:^{
        self.view.frame = rect;
    } completion:^(BOOL finished) {
        TopStoriesViewController *topStoriesViewController = [[TopStoriesViewController alloc] initWithNibName:@"TopStoriesViewController" bundle:nil];
        [topStoriesViewController setCategoryTag:sender.tag];
        [self presentViewController:topStoriesViewController animated:NO completion:nil];
    }];
}

- (void)showFavorites
{
    _parentScrollView.scrollEnabled = NO;
    CGRect rect = CGRectMake(self.view.frame.origin.x, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    [UIView animateWithDuration:0.3f animations:^{
        self.view.frame = rect;
    } completion:^(BOOL finished) {
        TopStoriesViewController *topStoriesViewController = [[TopStoriesViewController alloc] initWithNibName:@"TopStoriesViewController" bundle:nil];
        [topStoriesViewController setCategoryTag:CATEGORY_TAG_FAVORITES];
        [self presentViewController:topStoriesViewController animated:NO completion:nil];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
