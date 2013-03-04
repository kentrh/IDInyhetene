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
#import <Parse/Parse.h>
#import "NewsCategory.h"
#import "NewsParser.h"

#define BUTTON_WIDTH 280.0f
#define BUTTON_HEIGHT 50.0f
#define BUTTON_Y 20.0f
#define BUTTON_X 20.0f
#define BUTTON_VERTICAL_SPACING 20.0f
#define BUTTON_FONT_TYPE @"AmericanTypewriter"
#define BUTTON_FONT_SIZE 18.0f

@interface CategoriesViewController (){
    NSArray *newsCategories;
}

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

- (void)addCategoryButtons{
    newsCategories = [NewsParser categories];
    
    int counter = 0;
    for (NewsCategory *newsCategory in newsCategories) {
        int buttonY = counter == 0 ? BUTTON_VERTICAL_SPACING : ((BUTTON_VERTICAL_SPACING + BUTTON_HEIGHT)*counter)+BUTTON_VERTICAL_SPACING;
        UIColor *buttonColor;
        if (newsCategory.tag == -1) {
            buttonColor = [Colors orange];
        }
        else if (newsCategory.tag == 1) {
            buttonColor = [Colors green];
        }
        else buttonColor = [Colors lightBlue];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(BUTTON_X, buttonY, BUTTON_WIDTH, BUTTON_HEIGHT);
        [button addTarget:self action:@selector(showNewsArticles:) forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundColor:buttonColor];
        [button setTitle:newsCategory.displayName forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [button.titleLabel setFont:[UIFont fontWithName:BUTTON_FONT_TYPE size:BUTTON_FONT_SIZE]];
        [button setTag:newsCategory.tag];
        [_rootScrollView addSubview:button];
        counter++;
    }
        [_rootScrollView setContentSize:CGSizeMake(self.view.frame.size.width, (newsCategories.count*(BUTTON_HEIGHT + BUTTON_VERTICAL_SPACING))+BUTTON_VERTICAL_SPACING)];  
}

- (void)showNewsArticles:(UIButton *)sender
{
    if (sender.tag == 1) {
        [_parentScrollView setContentOffset:CGPointZero animated:YES];
        return;
    }
    NSString *url;
    for (NewsCategory *cat in newsCategories) {
        if (cat.tag == sender.tag){
            url = cat.url;
            break;
        }
    }
    NSString *status = [HelpMethods randomLoadText];
    [SVProgressHUD showWithStatus:status maskType:SVProgressHUDMaskTypeBlack];
    _parentScrollView.scrollEnabled = NO;
    CGRect rect = CGRectMake(self.view.frame.origin.x, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    [UIView animateWithDuration:0.3f animations:^{
        self.view.frame = rect;
    } completion:^(BOOL finished) {
        TopStoriesViewController *topStoriesViewController = [[TopStoriesViewController alloc] initWithNibName:@"TopStoriesViewController" bundle:nil];
        [topStoriesViewController setCategoryTag:sender.tag];
        [topStoriesViewController setQueryUrl:url];
        [self presentViewController:topStoriesViewController animated:NO completion:nil];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
