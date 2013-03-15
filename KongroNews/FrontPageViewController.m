//
//  FrontPageViewController.m
//  KongroNews
//
//  Created by Kent Robin Haugen on 21.02.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import "FrontPageViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Colors.h"
#import "News.h"
#import "NewsParser.h"
#import "Constants.h"
#import "TopStoriesViewController.h"
#import "SKBounceAnimation.h"
#import "HelpMethods.h"
#import "NewsCategory.h"
#import "NSDate+TimeSince.h"
#import "SettingsViewController.h"

@interface FrontPageViewController (){
    News *frontPageNewsArticle;
    NewsCategory *topStoriesCategory;
    BOOL fromSettingsView;
}

@end

@implementation FrontPageViewController

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
    [self setUpUi];
    [self setStartPositionForAnimation];
    [self addGestureRecognizer];
    [self addTapGestureRecognizer];
}

- (void)setStartPositionForAnimation
{
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    if (fromSettingsView)
    {
        frame.origin.y = -frame.size.height;
        fromSettingsView = NO;
    }
    else {
        frame.origin.y = frame.size.height;
    }
    self.view.frame = frame;
}

- (void)viewDidAppear:(BOOL)animated
{
    _parentScrollView.scrollEnabled = YES;
    [self setStartPositionForAnimation];
    [self startBounceInAnimation];
    
    if (!frontPageNewsArticle) {
        [self triggerNoNetworkMode];
    }
    [self performSelectorInBackground:@selector(checkIfFrontpageNewsHasUpdated) withObject:nil];
    [_timeSinceLabel setText:[frontPageNewsArticle.pubDate timeSinceFromDate]];
}

- (void)checkIfFrontpageNewsHasUpdated
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *topStories = [NewsParser newsList:topStoriesCategory.url shouldUpdate:NO];
        News *tempNews = [topStories objectAtIndex:0];
        if (![frontPageNewsArticle.link.absoluteString isEqualToString:tempNews.link.absoluteString]){
            frontPageNewsArticle = tempNews;
            [_headlineButton setTitle:tempNews.title forState:UIControlStateNormal];
            [_timeSinceLabel setText:[tempNews.pubDate timeSinceFromDate]];
        }
    });
}

- (void)addTapGestureRecognizer
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeTextFieldKeyboard)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:tap];
}

- (void)triggerNoNetworkMode
{
    _headlineButton.enabled = NO;
    for (UIGestureRecognizer *gr in self.view.gestureRecognizers) {
        [self.view removeGestureRecognizer:gr];
    }
    [_parentScrollView setScrollEnabled:NO];
    [_parentScrollView setPagingEnabled:NO];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ingen nyheter" message:@"Ingen nyheter kunne bli hentet, mest sannsynlig på grunn av en nettverksfeil. Sjekk at nettverk er tilgjengelig og start applikasjonen på nytt, eller hold 3 fingre nede på startskjermen for å laste inn på nytt!" delegate:self cancelButtonTitle:@"Lukk" otherButtonTitles: nil];
    [alertView show];
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

- (void)addGradientToBackground
{
    [self.view.layer insertSublayer:[Colors blueGradientWithFrame:self.view.frame] atIndex:0];
}



- (void)setUpUi
{
    NSArray *categories = [NewsParser categories];
    for (NewsCategory *cat in categories) {
        if (cat.tag == CATEGORY_TAG_TOP_STORIES) {
            topStoriesCategory = cat;
        }
    }
    NSArray *newsArray = [NewsParser newsList:topStoriesCategory.url shouldUpdate:NO];
    frontPageNewsArticle = [newsArray objectAtIndex:0];
    
    [_headlineButton setTitle:frontPageNewsArticle.title forState:UIControlStateNormal];
    [_headlineButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_headlineButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [_headlineButton.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [_headlineButton.titleLabel setNumberOfLines:4];
    [_headlineButton.titleLabel setFont:[UIFont fontWithName:@"AmericanTypewriter" size:22.0f]];
    
    [_numberOfNewsLabel setText:[NSString stringWithFormat:@"%d",newsArray.count]];
    [_numberOfNewsLabel sizeToFit];
    
    
    [_timeSinceLabel setText:[frontPageNewsArticle.pubDate timeSinceFromDate]];
    [_timeSinceLabel setFont:[UIFont fontWithName:@"AmericanTypewriter" size:14.0f]];
    [_timeSinceLabel sizeToFit];
    
    [_searchField setDelegate:self];
}

- (void)addGestureRecognizer
{
    UISwipeGestureRecognizer *downSwiper = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDownTriggered:)];
    [downSwiper setDirection:UISwipeGestureRecognizerDirectionDown];
    [downSwiper setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:downSwiper];
    
    UISwipeGestureRecognizer *upSwiper = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUpTriggered:)];
    [upSwiper setDirection:UISwipeGestureRecognizerDirectionUp];
    [upSwiper setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:upSwiper];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)headlineButtonPushed:(UIButton *)sender {
    [TestFlight passCheckpoint:@"Frontpage show top stories swipe"];
    [self showTopStories];
}

- (IBAction)searchAction:(UITextField *)sender {
    if (sender.text.length > 0 || ![sender.text isEqualToString:@""]){
        NSString *query = sender.text;
        NSString *baseUrl = @"http://pipes.yahoo.com/kongronews/allnews?_render=json&query=";
        NSString *queryString = [NSString stringWithFormat:@"%@%@", baseUrl, query];
        queryString = [queryString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        sender.text = @"";
        
        NSString *status = [HelpMethods randomLoadText];
        [SVProgressHUD showWithStatus:status maskType:SVProgressHUDMaskTypeBlack];
        _parentScrollView.scrollEnabled = NO;
        CGRect rect = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
        [UIView animateWithDuration:0.3f animations:^{
            self.view.frame = rect;
        } completion:^(BOOL finished) {
            TopStoriesViewController *topStoriesViewController = [[TopStoriesViewController alloc] initWithNibName:@"TopStoriesViewController" bundle:nil];
            [topStoriesViewController setQueryUrl:queryString];
            [topStoriesViewController setShouldAnimateFromMainView:YES];
            [self presentViewController:topStoriesViewController animated:NO completion:nil];
        }];
    }
    
}

- (IBAction)swipeDownTriggered:(UISwipeGestureRecognizer *)swipe
{
    [TestFlight passCheckpoint:@"Frontpage show top stories swipe"];
    [self showTopStories];
}

- (IBAction)swipeUpTriggered:(UISwipeGestureRecognizer *)swipe
{
    [TestFlight passCheckpoint:@"Frontpage show settings"];
    [self showSettings];
}

- (void)showTopStories
{
    NSString *status = [HelpMethods randomLoadText];
    [SVProgressHUD showWithStatus:status maskType:SVProgressHUDMaskTypeBlack];
    _parentScrollView.scrollEnabled = NO;
    CGRect rect = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    [UIView animateWithDuration:0.3f animations:^{
        self.view.frame = rect;
    } completion:^(BOOL finished) {
        TopStoriesViewController *topStoriesViewController = [[TopStoriesViewController alloc] initWithNibName:@"TopStoriesViewController" bundle:nil];
        [topStoriesViewController setQueryUrl:topStoriesCategory.url];
        [topStoriesViewController setShouldAnimateFromMainView:YES];
        [self.parentViewController presentViewController:topStoriesViewController animated:NO completion:nil];
    }];
}

- (void)showSettings
{
    _parentScrollView.scrollEnabled = NO;
    fromSettingsView = YES;
    CGRect rect = CGRectMake(0, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    [UIView animateWithDuration:0.3f animations:^{
        self.view.frame = rect;
    } completion:^(BOOL finished) {
        SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
        [self.parentViewController presentViewController:settingsViewController animated:NO completion:nil];
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)removeTextFieldKeyboard
{
    [_searchField resignFirstResponder];
}
@end
