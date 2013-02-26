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


#define TEST_STRING @"Dette er en teststring for å sjekke hvor langt opp og ned titlelabelen går. Og den må faktisk kanskje bli ennå litt lengre. Kanskje til og med ennå lengre."

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
}

- (void)viewDidAppear:(BOOL)animated
{
    _parentScrollView.scrollEnabled = YES;
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.view.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    [UIView animateWithDuration:0.3f animations:^{
        self.view.frame = rect;
    }];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)headlineButtonPushed:(UIButton *)sender {
    NSLog(@"Headline was clicked");
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
