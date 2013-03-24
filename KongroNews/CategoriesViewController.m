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
#import "CMPopTipView.h"
#import "RootViewController.h"

@interface CategoriesViewController (){
    NSArray *newsCategories;
    NSMutableDictionary *buttons;
    BOOL hasDoneFirstLoad;
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
    if ([RootViewController isFirstRun]) {
        [self setUpPopUp];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    _parentScrollView.scrollEnabled = YES;
    [self setStartPositionForAnimation];
    [self startBounceInAnimation];
    if (hasDoneFirstLoad) {
        [self updateNumberOfNewsCountOnButtons];
    }
    
}

- (void)setUpPopUp
{
    CMPopTipView *popTip;
    popTip = [[CMPopTipView alloc] initWithMessage:@"Hold nede kategoriknappen i ett sekund for å oppdatere nyhetene i denne kategorien. Gjelder ikke favoritter."];
    [popTip setTextColor:[UIColor whiteColor]];
    [popTip setTextFont:[UIFont fontWithName:BUTTON_FONT_TYPE size:BUTTON_FONT_SIZE]];
    [popTip setBackgroundColor:[Colors help]];
    [popTip setDismissTapAnywhere:YES];
    [popTip presentPointingAtView:[buttons objectForKey:(NewsCategory *)[[newsCategories objectAtIndex:1] name]] inView:self.view animated:YES];
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

- (void)updateNumberOfNewsCountOnButtons
{
    for (NewsCategory *cat in newsCategories) {
        UIView *view = (UIView *)[buttons objectForKey:cat.name];
        UILabel *countLabel;
        for (UIView *subView in view.subviews) {
            if (subView.tag == 1 && [subView isKindOfClass:[UILabel class]]) {
                countLabel = (UILabel *)subView;
            }
        }
        countLabel.text = [NSString stringWithFormat:@"%d", [NewsParser numberOfNewsFromTag:cat.tag]];
    }
}

- (void)addCategoryButtons{
    newsCategories = [NewsParser categories];
    
    buttons = [[NSMutableDictionary alloc] initWithCapacity:newsCategories.count];
    
    float buttonWidth = [[UIScreen mainScreen] bounds].size.width - 40.0f;
    
    int counter = 0;
    for (NewsCategory *newsCategory in newsCategories) {
        int buttonY = counter == 0 ? BUTTON_VERTICAL_SPACING : ((BUTTON_VERTICAL_SPACING + BUTTON_HEIGHT)*counter)+BUTTON_VERTICAL_SPACING;
        UIColor *buttonColor;
        if (newsCategory.tag == CATEGORY_TAG_FAVORITES) {
            buttonColor = [Colors orange];
        }
        else if (newsCategory.tag == CATEGORY_TAG_TOP_STORIES) {
            buttonColor = [Colors green];
        }
        else buttonColor = [Colors lightBlue];
        
        UIView *button = [[UIView alloc] initWithFrame:CGRectMake(BUTTON_X, buttonY, buttonWidth, BUTTON_HEIGHT)];
        [button setBackgroundColor:buttonColor];
        
        UITapGestureRecognizer *buttonTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showNewsArticles:)];
        [buttonTap setNumberOfTapsRequired:1];
        [buttonTap setNumberOfTouchesRequired:1];
        [button addGestureRecognizer:buttonTap];
        
        if (newsCategory.tag != CATEGORY_TAG_FAVORITES) {
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(updateCategory:)];
            longPress.numberOfTapsRequired = 0;
            longPress.numberOfTouchesRequired = 1;
            longPress.minimumPressDuration = 1;
            [button addGestureRecognizer:longPress];
        }
        
        button.tag = newsCategory.tag;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 24, buttonWidth - 80, 21)];
        titleLabel.text = newsCategory.displayName;
        titleLabel.font = [UIFont fontWithName:BUTTON_FONT_TYPE size:BUTTON_FONT_SIZE];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        
        UILabel *newsCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(buttonWidth-50, 24, 30, 21)];
        newsCountLabel.text = @"";
        newsCountLabel.font = [UIFont fontWithName:BUTTON_FONT_TYPE size:BUTTON_FONT_COUNT_SIZE];
        newsCountLabel.textColor = [UIColor whiteColor];
        newsCountLabel.backgroundColor = [UIColor clearColor];
        newsCountLabel.tag = 1;
        [newsCountLabel setTextAlignment:NSTextAlignmentRight];
        [newsCountLabel setHidden:YES];
        
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [activityView setCenter:newsCountLabel.center];
        [activityView startAnimating];
        
        [button addSubview:titleLabel];
        [button addSubview:newsCountLabel];
        [button addSubview:activityView];
        
        [_rootScrollView addSubview:button];
        [buttons setObject:button forKey:newsCategory.name];
        
        dispatch_queue_t queue = dispatch_queue_create("com.kentrobin.nyhetene", NULL);
        dispatch_async(queue, ^{
            NSArray *newsArray;
            if (newsCategory.tag == CATEGORY_TAG_FAVORITES) {
                NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"starredArticles"];
                if (data) {
                    newsArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                    
                }
            }
            //Doesn't have to update because top stories was updated when initializing the main view.
            else if (newsCategory.tag == CATEGORY_TAG_TOP_STORIES) {
                newsArray = [NewsParser newsListFromCategoryTag:newsCategory.tag shouldUpdate:NO];
            }
            //Update all the other categories
            else {
                newsArray = [NewsParser newsListFromCategoryTag:newsCategory.tag shouldUpdate:YES];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                newsCountLabel.text = [NSString stringWithFormat:@"%d", newsArray.count];
                [newsCountLabel setHidden:NO];
                [activityView stopAnimating];
                if (counter == newsCategories.count - 1) {
                    hasDoneFirstLoad = YES;
                }
            });
        });
        
        counter++;
    }
        [_rootScrollView setContentSize:CGSizeMake(self.view.frame.size.width, (newsCategories.count*(BUTTON_HEIGHT + BUTTON_VERTICAL_SPACING))+BUTTON_VERTICAL_SPACING)];  
}

- (IBAction)updateCategory:(UIGestureRecognizer *)sender
{
    [sender setEnabled:NO];
    int tag = sender.view.tag;
    [TestFlight passCheckpoint:[NSString stringWithFormat:@"CategoriesView: Update category, tag: %d", tag]];
    UIActivityIndicatorView *activityIndicator;
    UILabel *counter;
    for (UIView *view in sender.view.subviews) {
        if ([view isKindOfClass:[UIActivityIndicatorView class]]) {
            activityIndicator = (UIActivityIndicatorView *)view;
        }
        else if ([view isKindOfClass:[UILabel class]] && view.tag == 1) {
            counter = (UILabel *)view;
        }
    }
    [counter setHidden:YES];
    [activityIndicator startAnimating];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *newsArray = [NewsParser newsListFromCategoryTag:tag shouldUpdate:YES];
        counter.text = [NSString stringWithFormat:@"%d", newsArray.count];
        [activityIndicator stopAnimating];
        [counter setHidden:NO];
        [sender setEnabled:YES];
    });
}

- (void)showNewsArticles:(UIGestureRecognizer *)sender
{
    int tag = sender.view.tag;
    [TestFlight passCheckpoint:[NSString stringWithFormat:@"CategoriesView: Show news articles clicked, tag: %d", tag]];
    if (tag == 1) {
        [_parentScrollView setContentOffset:CGPointZero animated:YES];
        return;
    }
    NSString *url;
    for (NewsCategory *cat in newsCategories) {
        if (cat.tag == tag){
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
        [topStoriesViewController setCategoryTag:tag];
        [topStoriesViewController setShouldAnimateFromMainView:YES];
        [self.parentViewController presentViewController:topStoriesViewController animated:NO completion:nil];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
