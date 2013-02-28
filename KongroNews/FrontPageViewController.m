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

@interface FrontPageViewController ()

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
}

- (void)setStartPositionForAnimation
{
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    frame.origin.y = frame.size.height;
    self.view.frame = frame;
}

- (void)viewDidAppear:(BOOL)animated
{
    _parentScrollView.scrollEnabled = YES;
    [self setStartPositionForAnimation];
    [self startBounceInAnimation];
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
    
    NSArray *newsArray = [NewsParser newsList:URL_TOP_STORIES];
    News *news = [newsArray objectAtIndex:0];
    
    [_headlineButton setTitle:news.title forState:UIControlStateNormal];
    [_headlineButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_headlineButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [_headlineButton.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [_headlineButton.titleLabel setNumberOfLines:4];
    [_headlineButton.titleLabel setFont:[UIFont fontWithName:@"AmericanTypewriter" size:22.0f]];
    
    [_numberOfNewsLabel setText:[NSString stringWithFormat:@"%d",newsArray.count]];
    [_numberOfNewsLabel sizeToFit];
    
    NSTimeInterval timeDiff = [[NSDate date] timeIntervalSinceDate:news.pubDate];
    int time = (int) timeDiff;
    int minutes = ((time / 60) % 60);
    int hours = (time / 3600);
    
    NSString *entallFlertallMinutter = minutes == 1 ? @"minutt" : @"minutter";
    NSString *entallFlertallTimer = hours == 1 ? @"time" : @"timer";
    
    NSString *timeSinceText;
    if (hours == 0) {
        timeSinceText = [NSString stringWithFormat:@"%d %@ siden", minutes, entallFlertallMinutter];
    }
    else if (hours == 1 || hours == 2) {
        timeSinceText = [NSString stringWithFormat:@"%d %@ og %d %@ siden", hours, entallFlertallTimer, minutes, entallFlertallMinutter];
    }
    else if (hours > 2) {
        timeSinceText = [NSString stringWithFormat:@"%d %@ siden", hours, entallFlertallTimer];
    }
    else if (hours > 23) {
        timeSinceText = [NSString stringWithFormat:@"Mer enn én dag siden"];
    }
    
    [_timeSinceLabel setText:timeSinceText];
    [_timeSinceLabel setFont:[UIFont fontWithName:@"AmericanTypewriter" size:14.0f]];
    [_timeSinceLabel sizeToFit];
}

- (void)addGestureRecognizer
{
    UISwipeGestureRecognizer *swiper = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showTopStories)];
    [swiper setDirection:UISwipeGestureRecognizerDirectionDown];
    [swiper setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:swiper];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)headlineButtonPushed:(UIButton *)sender {
    [self showTopStories];
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
        [self presentViewController:topStoriesViewController animated:NO completion:nil];
    }];
}
@end
