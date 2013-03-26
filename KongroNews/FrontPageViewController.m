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
#import "SVPullToRefresh.h"
#import "RootViewController.h"

@interface FrontPageViewController (){
    News *frontPageNewsArticle;
    NewsCategory *topStoriesCategory;
    BOOL fromSettingsView;
    int counter;
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
    [self addObserversToHandleApplicationResigning];
    if ([RootViewController isFirstRun]) {
        [self setUpPopUp];
    }
}

- (void)setUpPopUp
{
    CMPopTipView *popTip;
    popTip = [[CMPopTipView alloc] initWithMessage:@"Klikk overskriften for å lese siste sak. (Klikk utenfor denne boksen for å se neste melding.)"];
    [popTip setTextColor:[UIColor whiteColor]];
    [popTip setTextFont:[UIFont fontWithName:BUTTON_FONT_TYPE size:BUTTON_FONT_SIZE]];
    [popTip setBackgroundColor:[Colors help]];
    [popTip setDismissTapAnywhere:YES];
    [popTip setDelegate:self];
    [popTip presentPointingAtView:_headlineButton inView:self.view animated:YES];
    counter = 0;
}

- (void)addObserversToHandleApplicationResigning
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDelegateWillTerminate:) name:@"applicationWillTerminate" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDelegateDidBecomeActive:) name:@"applicationDidBecomeActive" object:nil];
}

- (void)appDelegateWillTerminate:(NSNotification *)notification
{
    NSLog(@"application will terminate");
    if ([self.parentViewController.presentedViewController isKindOfClass:[TopStoriesViewController class]])
    {
        
        TopStoriesViewController *tsvc = (TopStoriesViewController *)self.parentViewController.presentedViewController;
        for (UIViewController *vc in tsvc.childViewControllers) {
            [vc dismissViewControllerAnimated:NO completion:nil];
            [vc removeFromParentViewController];
        }
        [tsvc dismissViewControllerAnimated:NO completion:nil];
        [tsvc removeFromParentViewController];
    }
}

- (void)appDelegateDidBecomeActive:(NSNotification *)notification
{
    [_activityIndicator startAnimating];
    NSLog(@"application did become active");
    [self performSelectorInBackground:@selector(updateFrontPageNews) withObject:nil];
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
    if (!_settingsIsShowing) {
        _parentScrollView.scrollEnabled = YES;
        [self setStartPositionForAnimation];
        [self startBounceInAnimation];
    }
    
    if (!frontPageNewsArticle) {
        [self triggerNoNetworkMode];
    }
    [_activityIndicator startAnimating];
    [self performSelectorInBackground:@selector(checkIfFrontpageNewsHasUpdated) withObject:nil];
    [_timeSinceLabel setText:[frontPageNewsArticle.pubDate timeSinceFromDate]];
    [_numberOfNewsLabel setText:[NSString stringWithFormat:@"%d", [NewsParser numberOfNewsFromTag:topStoriesCategory.tag]]];
}

- (void)checkIfFrontpageNewsHasUpdated
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *topStories = [NewsParser newsListFromCategoryTag:topStoriesCategory.tag shouldUpdate:NO];
        News *tempNews = [topStories objectAtIndex:0];
        if (![frontPageNewsArticle.link.absoluteString isEqualToString:tempNews.link.absoluteString]){
            frontPageNewsArticle = tempNews;
            [_headlineButton setTitle:tempNews.title forState:UIControlStateNormal];
            [_timeSinceLabel setText:[tempNews.pubDate timeSinceFromDate]];
        }
        [_activityIndicator stopAnimating];
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

- (void)updateFrontPageNews
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *topStories = [NewsParser newsListFromCategoryTag:topStoriesCategory.tag shouldUpdate:YES];
        News *tempNews = [topStories objectAtIndex:0];
        if (![frontPageNewsArticle.link.absoluteString isEqualToString:tempNews.link.absoluteString]){
            frontPageNewsArticle = tempNews;
            [_headlineButton setTitle:tempNews.title forState:UIControlStateNormal];
        }
        [_parentScrollView.pullToRefreshView stopAnimating];
        [_timeSinceLabel setText:[tempNews.pubDate timeSinceFromDate]];
        [_activityIndicator stopAnimating];
        [_numberOfNewsLabel setText:[NSString stringWithFormat:@"%d", [NewsParser numberOfNewsFromTag:topStoriesCategory.tag]]];
    });
    
}

- (void)setUpUi
{
    NSArray *categories = [NewsParser categories];
    for (NewsCategory *cat in categories) {
        if (cat.tag == CATEGORY_TAG_TOP_STORIES) {
            topStoriesCategory = cat;
        }
    }
    NSArray *newsArray = [NewsParser newsListFromCategoryTag:topStoriesCategory.tag shouldUpdate:YES];
    frontPageNewsArticle = [newsArray objectAtIndex:0];
    
    [_headlineButton setTitle:frontPageNewsArticle.title forState:UIControlStateNormal];
    [_headlineButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_headlineButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [_headlineButton.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [_headlineButton.titleLabel setNumberOfLines:4];
    [_headlineButton.titleLabel setFont:[UIFont fontWithName:@"AmericanTypewriter" size:22.0f]];
    
    [_numberOfNewsLabel setText:[NSString stringWithFormat:@"%d",[NewsParser numberOfNewsFromTag:topStoriesCategory.tag]]];
    [_numberOfNewsLabel sizeToFit];
    
    
    [_timeSinceLabel setText:[frontPageNewsArticle.pubDate timeSinceFromDate]];
    [_timeSinceLabel setFont:[UIFont fontWithName:@"AmericanTypewriter" size:14.0f]];
    [_timeSinceLabel sizeToFit];
    
    [_searchField setDelegate:self];
    [_usernameField setDelegate:self];
    [_passwordField setDelegate:self];
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
    [TestFlight passCheckpoint:@"FrontpageView: Headline clicked."];
    [NewsParser setLastViewedArticleByCategoryTag:CATEGORY_TAG_TOP_STORIES lastViewedArticleUrlString:@""];
    [self showTopStories];
}

- (IBAction)searchAction:(UITextField *)sender {
    if (_searchField.text.length > 0){
        NSString *query = sender.text;
        NSString *baseUrl = @"http://pipes.yahoo.com/kongronews/allnews?_render=json&query=";
        NSString *queryString = [NSString stringWithFormat:@"%@%@", baseUrl, query];
        queryString = [queryString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        _searchField.text = @"";
        
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

- (IBAction)usernameDoneTyping:(UITextField *)sender {
    if (_usernameField.text.length > 0) {
    }
}

- (IBAction)passwordDoneTyping:(UITextField *)sender {
    if (_usernameField.text.length > 0 && _passwordField.text.length > 0) {
        [self login];
    }
}

- (void)login
{
    _usernameField.text = @"";
    [_usernameField setHidden:YES];
    _passwordField.text = @"";
    [_passwordField setHidden:YES];
    
    NSLog(@"Login called");
}

- (IBAction)swipeDownTriggered:(UISwipeGestureRecognizer *)swipe
{
    [TestFlight passCheckpoint:@"FrontpageView: Show top stories swipe."];
    [self showTopStories];
}

- (IBAction)swipeUpTriggered:(UISwipeGestureRecognizer *)swipe
{
    [TestFlight passCheckpoint:@"FrontpageView: Show settings."];
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
        [topStoriesViewController setCategoryTag:topStoriesCategory.tag];
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
        [self.parentViewController addChildViewController:settingsViewController];
        [self setSettingsIsShowing:YES];
        [self.parentViewController.view addSubview:settingsViewController.view];
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];
    if (textField == _usernameField && _usernameField.text.length > 0) {
        [_passwordField becomeFirstResponder];
    }
    return YES;
}

- (void)removeTextFieldKeyboard
{
    [_searchField endEditing:YES];
    [_usernameField endEditing:YES];
    [_passwordField endEditing:YES];
}

#pragma mark - CMPopTipViewDelegate Methods
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    CMPopTipView *popTip = [[CMPopTipView alloc] init];
    [popTip setTextColor:[UIColor whiteColor]];
    [popTip setTextFont:[UIFont fontWithName:BUTTON_FONT_TYPE size:BUTTON_FONT_SIZE]];
    [popTip setBackgroundColor:[Colors help]];
    [popTip setDismissTapAnywhere:YES];
    [popTip setDelegate:self];
    
    if (counter == 0) {
        
        [popTip setMessage:@"Dra ned for å vise den forrige viste nyheten."];
        [popTip presentPointingAtView:_headlineButton inView:self.view animated:YES];
        counter++;
    }
    else if (counter == 1) {
        [popTip setMessage:@"Klikk her for å søke blant de siste nyhetene i alle kategorier."];
        [popTip presentPointingAtView:_searchField inView:self.view animated:YES];
        counter++;
    }
    else if (counter == 2) {
        [popTip setMessage:@"Dra opp for å gå til innstillinger."];
        [popTip presentPointingAtView:_headlineButton inView:self.view animated:YES];
        counter++;
    }
    else if (counter == 3) {
        [popTip setMessage:@"Dra til høyre og slipp for å oppdatere hovedsakene."];
        [popTip presentPointingAtView:_headlineButton inView:self.view animated:YES];
        counter++;
    }
    else if (counter == 4) {
        [popTip setMessage:@"Dra til venstre for å vise kategoriene."];
        [popTip presentPointingAtView:_headlineButton inView:self.view animated:YES];
        counter++;
    }
}
@end
