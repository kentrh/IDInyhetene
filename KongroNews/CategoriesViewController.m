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
#import "NewsParser.h"
#import "CMPopTipView.h"
#import "RootViewController.h"
#import "NewsReadingEvent.h"

@interface CategoriesViewController (){
    NSArray *newsCategories;
    NSMutableDictionary *buttons;
//    int numberOfLoadedCategories;
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
//    if ([RootViewController isFirstRun]) {
//        [self setUpPopUp];
//    }
}

- (void)viewDidAppear:(BOOL)animated
{
    _parentScrollView.scrollEnabled = YES;
    [self setStartPositionForAnimation];
    [self startBounceInAnimation];
//    if (numberOfLoadedCategories == newsCategories.count-1) {
//        [self updateNumberOfNewsCountOnButtons];
//    }
    
}

//- (void)setUpPopUp
//{
//    CMPopTipView *popTip;
//    popTip = [[CMPopTipView alloc] initWithMessage:@"Hold nede kategoriknappen i ett sekund for å oppdatere nyhetene i denne kategorien. Gjelder ikke favoritter."];
//    [popTip setTextColor:[UIColor whiteColor]];
//    [popTip setTextFont:[UIFont fontWithName:BUTTON_FONT_TYPE size:BUTTON_FONT_SIZE]];
//    [popTip setBackgroundColor:[Colors help]];
//    [popTip setDismissTapAnywhere:YES];
//    [popTip presentPointingAtView:[buttons objectForKey:[newsCategories objectAtIndex:1]] inView:self.view animated:YES];
//}

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

//- (void)updateNumberOfNewsCountOnButtons
//{
//    for (NSString *cat in newsCategories) {
//        UIView *view = (UIView *)[buttons objectForKey:cat];
//        UILabel *countLabel;
//        for (UIView *subView in view.subviews) {
//            if (subView.tag == 2 && [subView isKindOfClass:[UILabel class]]) {
//                countLabel = (UILabel *)subView;
//            }
//        }
//        int numberOfNew = [NewsParser numberOfUnseenArticlesByCategory:cat];
//        countLabel.text = [NSString stringWithFormat:@"%d", numberOfNew];
//        countLabel.hidden = numberOfNew == 0 ? YES : NO;
//    }
//}

- (void)addCategoryButtons{
    newsCategories = [NewsParser availableCategories];
//    numberOfLoadedCategories = 0;
    buttons = [[NSMutableDictionary alloc] initWithCapacity:newsCategories.count];
    
    float buttonWidth = [[UIScreen mainScreen] bounds].size.width - 40.0f;
    
    int counter = 0;
    for (NSString *newsCategory in newsCategories) {
        int buttonY = counter == 0 ? BUTTON_VERTICAL_SPACING : ((BUTTON_VERTICAL_SPACING + BUTTON_HEIGHT)*counter)+BUTTON_VERTICAL_SPACING;
        UIColor *buttonColor;
        if ([newsCategory isEqualToString:CATEGORY_FAVORITE_NEWS]) {
            buttonColor = [Colors orange];
        }
        else if ([newsCategory isEqualToString:CATEGORY_RELEVANT_NEWS]) {
            buttonColor = [Colors green];
        }
        else buttonColor = [Colors lightBlue];
        
        UIView *button = [[UIView alloc] initWithFrame:CGRectMake(BUTTON_X, buttonY, buttonWidth, BUTTON_HEIGHT)];
        [button setBackgroundColor:buttonColor];
        
        UITapGestureRecognizer *buttonTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showNewsArticles:)];
        [buttonTap setNumberOfTapsRequired:1];
        [buttonTap setNumberOfTouchesRequired:1];
        [button addGestureRecognizer:buttonTap];
        
//        if (![newsCategory isEqualToString: CATEGORY_FAVORITE_NEWS]) {
//            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(updateCategory:)];
//            longPress.numberOfTapsRequired = 0;
//            longPress.numberOfTouchesRequired = 1;
//            longPress.minimumPressDuration = 1;
//            [button addGestureRecognizer:longPress];
//        }
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 24, buttonWidth - 80, 21)];
        titleLabel.text = newsCategory;
        titleLabel.font = [UIFont fontWithName:BUTTON_FONT_TYPE size:BUTTON_FONT_SIZE];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.tag = 1;
        
        UILabel *newsCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(buttonWidth-50, 24, 30, 21)];
        newsCountLabel.text = @"";
        newsCountLabel.font = [UIFont fontWithName:BUTTON_FONT_TYPE size:BUTTON_FONT_COUNT_SIZE];
        newsCountLabel.textColor = [UIColor whiteColor];
        newsCountLabel.backgroundColor = [UIColor clearColor];
        newsCountLabel.tag = 2;
        [newsCountLabel setTextAlignment:NSTextAlignmentRight];
        [newsCountLabel setHidden:YES];
        
//        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
//        [activityView setCenter:newsCountLabel.center];
//        [activityView startAnimating];
        
        [button addSubview:titleLabel];
        [button addSubview:newsCountLabel];
//        [button addSubview:activityView];
        
        [_rootScrollView addSubview:button];
        [buttons setObject:button forKey:newsCategory];
        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            //Doesn't have to update because top stories was updated when initializing the main view.
//            if (![newsCategory isEqualToString:CATEGORY_RELEVANT_NEWS]) {
//                [NewsParser relevantNewsWithUserId:[[UIDevice currentDevice] uniqueDeviceIdentifier] location:[[RootViewController lastUpdatedLocation] coordinate] category:newsCategory shouldUpdate:YES];
//            }
//            int numberOfNew = [NewsParser numberOfUnseenArticlesByCategory:newsCategory];
//            newsCountLabel.text = [NSString stringWithFormat:@"%d", numberOfNew];
//            [newsCountLabel setHidden:numberOfNew == 0 ? YES : NO];
//            [activityView stopAnimating];
//            numberOfLoadedCategories++;
//        });
        
        counter++;
    }
    [_rootScrollView setContentSize:CGSizeMake(self.view.frame.size.width, (newsCategories.count*(BUTTON_HEIGHT + BUTTON_VERTICAL_SPACING))+BUTTON_VERTICAL_SPACING)];
}

//- (IBAction)updateCategory:(UIGestureRecognizer *)sender
//{
//    if (sender.state == UIGestureRecognizerStateBegan) {
//        UIActivityIndicatorView *activityIndicator;
//        UILabel *counter;
//        NSString *cat;
//        for (UIView *view in sender.view.subviews) {
//            if ([view isKindOfClass:[UIActivityIndicatorView class]]) {
//                activityIndicator = (UIActivityIndicatorView *)view;
//            }
//            else if ([view isKindOfClass:[UILabel class]] && view.tag == 1) {
//                UILabel *title = (UILabel *)view;
//                cat = title.text;
//            }
//            else if ([view isKindOfClass:[UILabel class]] && view.tag == 2) {
//                counter = (UILabel *)view;
//            }
//        }
//
//        [TestFlight passCheckpoint:[NSString stringWithFormat:@"CategoriesView: Update category: %@", cat]];
//        
//        [counter setHidden:YES];
//        [activityIndicator startAnimating];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSArray *newsArray;
//            if ([cat  isEqualToString:CATEGORY_RELEVANT_NEWS]) {
//                newsArray = [NewsParser relevantNewsWithUserId:[[UIDevice currentDevice] uniqueDeviceIdentifier] location:[[RootViewController lastUpdatedLocation] coordinate] shouldUpdate:YES];
//            }
//            else {
//                newsArray = [NewsParser relevantNewsWithUserId:[[UIDevice currentDevice] uniqueDeviceIdentifier] location:[[RootViewController lastUpdatedLocation] coordinate] category:cat shouldUpdate:YES];
//            }
//            int numberOfNew = [NewsParser numberOfUnseenArticlesByCategory:cat];
//            counter.text = [NSString stringWithFormat:@"%d", numberOfNew];
//            [activityIndicator stopAnimating];
//            [counter setHidden:numberOfNew == 0 ? YES : NO];
//            [sender setEnabled:YES];
//        });
//    }
//}

- (void)showNewsArticles:(UIGestureRecognizer *)sender
{
    NSString *cat;
    for (UIView *view in sender.view.subviews) {
        if ([view isKindOfClass:[UILabel class]] && view.tag == 1) {
            UILabel *title = (UILabel *)view;
            cat = title.text;
        }
    }
    [TestFlight passCheckpoint:[NSString stringWithFormat:@"CategoriesView: Show news articles clicked: %@", cat]];
    [self performSelectorInBackground:@selector(addClickedCategoryToEventQueue:) withObject:cat];
    if ([cat isEqualToString:CATEGORY_RELEVANT_NEWS]) {
        [_parentScrollView setContentOffset:CGPointZero animated:YES];
        return;
    }
    NSString *status = [HelpMethods randomLoadText];
    [SVProgressHUD showWithStatus:status maskType:SVProgressHUDMaskTypeBlack];
    _parentScrollView.scrollEnabled = NO;
    CGRect rect = CGRectMake(self.view.frame.origin.x, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    [UIView animateWithDuration:0.3f animations:^{
        self.view.frame = rect;
    } completion:^(BOOL finished) {
        TopStoriesViewController *topStoriesViewController = [[TopStoriesViewController alloc] initWithNibName:@"TopStoriesViewController" bundle:nil];
        [topStoriesViewController setCategory:cat];
        [topStoriesViewController setShouldAnimateFromMainView:YES];
        [self.parentViewController presentViewController:topStoriesViewController animated:NO completion:nil];
    }];
}

- (void)addClickedCategoryToEventQueue:(id)obj
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *category = (NSString *)obj;
        NSString *GUID = [[NSUUID UUID] UUIDString];
        CLLocation *location = [RootViewController lastUpdatedLocation];
        GeoLocation *geoLocation = [[GeoLocation alloc] initWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
        NewsReadingEvent *event = [[NewsReadingEvent alloc] initWithGlobalIdentifier:GUID articleId:nil userId:[[UIDevice currentDevice] uniqueDeviceIdentifier] eventType:NewsReadingEventClickedCategory timeStamp:[NSDate date] geoLocation:geoLocation properties:[NSDictionary dictionaryWithObjectsAndKeys:category, @"category", nil]];
        [NewsReadingEvent addEventToQueue:event];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
