//
//  SettingsViewController.m
//  KongroNews
//
//  Created by Kent Robin Haugen on 04.03.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import "SettingsViewController.h"
#import "Colors.h"
#import "SKBounceAnimation.h"
#import "Constants.h"
#import "FrontPageViewController.h"

#define BUTTON_WIDTH 280.0f
#define BUTTON_HEIGHT 50.0f
#define BUTTON_Y 20.0f
#define BUTTON_X 20.0f
#define BUTTON_VERTICAL_SPACING 20.0f
#define BUTTON_FONT_TYPE @"AmericanTypewriter"
#define BUTTON_FONT_SIZE 18.0f

@interface SettingsViewController (){
    BOOL modalIsShowing;
}

@end

@implementation SettingsViewController

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
//    [self addBackgroundImage];
    [self setStartPositionForAnimation];
    [self addButtons];
    [self addGestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    if (!modalIsShowing)
    {
        [self setStartPositionForAnimation];
        [self startBounceInAnimation];
    }
}

- (void)addBackgroundImage
{
    UIImage *backgroundImage = [UIImage imageNamed:@"settings.jpg"];
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
    backgroundView.frame = [[UIScreen mainScreen] bounds];
    backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    UIImage *filterImage;
    if (IS_IPHONE_5) filterImage = [UIImage imageNamed:@"blackFilter5"];
    else filterImage = [UIImage imageNamed:@"blackFilter"];
    UIImageView *filterView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [filterView setImage:filterImage];
    [backgroundView addSubview:filterView];
    [self.view addSubview:backgroundView];
}

- (void)addGestureRecognizer
{
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDownTriggered:)];
    swipe.direction = UISwipeGestureRecognizerDirectionDown;
    swipe.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:swipe];
}

- (IBAction)swipeDownTriggered:(id)sender
{
    CGRect rect = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    [UIView animateWithDuration:0.3f animations:^{
        self.view.frame = rect;
    } completion:^(BOOL finished) {
        for (UIViewController *vc in self.parentViewController.childViewControllers) {
            if ([vc isKindOfClass:[FrontPageViewController class]]) {
                [(FrontPageViewController *)vc setSettingsIsShowing:NO];
                [vc viewDidAppear:YES];
            }
        }
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}

- (void)setStartPositionForAnimation
{
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    frame.origin.y = frame.size.height;
    self.view.frame = frame;
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

- (void)addButtons
{
    int counter = 0;

    UIButton *feedback = [UIButton buttonWithType:UIButtonTypeCustom];
    feedback.frame = CGRectMake(BUTTON_X, counter == 0 ? BUTTON_VERTICAL_SPACING : ((BUTTON_VERTICAL_SPACING + BUTTON_HEIGHT)*counter)+BUTTON_VERTICAL_SPACING, BUTTON_WIDTH, BUTTON_HEIGHT);
    [feedback addTarget:self action:@selector(sendFeedback) forControlEvents:UIControlEventTouchUpInside];
    [feedback setBackgroundColor:[Colors rate]];
    [feedback setTitle:@"Send tilbakemelding" forState:UIControlStateNormal];
    [feedback setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [feedback setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [feedback.titleLabel setFont:[UIFont fontWithName:BUTTON_FONT_TYPE size:BUTTON_FONT_SIZE]];
    
    counter++;
    
    UIButton *rate = [UIButton buttonWithType:UIButtonTypeCustom];
    rate.frame = CGRectMake(BUTTON_X, counter == 0 ? BUTTON_VERTICAL_SPACING : ((BUTTON_VERTICAL_SPACING + BUTTON_HEIGHT)*counter)+BUTTON_VERTICAL_SPACING, BUTTON_WIDTH, BUTTON_HEIGHT);
    [rate addTarget:self action:@selector(rateApp) forControlEvents:UIControlEventTouchUpInside];
    [rate setBackgroundColor:[Colors rate]];
    [rate setTitle:@"Vurder på App Store" forState:UIControlStateNormal];
    [rate setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rate setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [rate.titleLabel setFont:[UIFont fontWithName:BUTTON_FONT_TYPE size:BUTTON_FONT_SIZE]];
    
    counter++;
    
    UIButton *facebook = [UIButton buttonWithType:UIButtonTypeCustom];
    facebook.frame = CGRectMake(BUTTON_X, counter == 0 ? BUTTON_VERTICAL_SPACING : ((BUTTON_VERTICAL_SPACING + BUTTON_HEIGHT)*counter)+BUTTON_VERTICAL_SPACING, BUTTON_WIDTH, BUTTON_HEIGHT);
    [facebook addTarget:self action:@selector(likeOnFacebook) forControlEvents:UIControlEventTouchUpInside];
    [facebook setBackgroundColor:[Colors facebook]];
    [facebook setTitle:@"Lik på Facebook" forState:UIControlStateNormal];
    [facebook setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [facebook setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [facebook.titleLabel setFont:[UIFont fontWithName:BUTTON_FONT_TYPE size:BUTTON_FONT_SIZE]];
    
    counter++;
    
    UIButton *twitter = [UIButton buttonWithType:UIButtonTypeCustom];
    twitter.frame = CGRectMake(BUTTON_X, counter == 0 ? BUTTON_VERTICAL_SPACING : ((BUTTON_VERTICAL_SPACING + BUTTON_HEIGHT)*counter)+BUTTON_VERTICAL_SPACING, BUTTON_WIDTH, BUTTON_HEIGHT);
    [twitter addTarget:self action:@selector(followOnTwitter) forControlEvents:UIControlEventTouchUpInside];
    [twitter setBackgroundColor:[Colors twitter]];
    [twitter setTitle:@"Følg på Twitter" forState:UIControlStateNormal];
    [twitter setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [twitter setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [twitter.titleLabel setFont:[UIFont fontWithName:BUTTON_FONT_TYPE size:BUTTON_FONT_SIZE]];

    
    [self.view addSubview:feedback];
    [self.view addSubview:rate];
    [self.view addSubview:twitter];
    [self.view addSubview:facebook];
}

- (void)sendFeedback
{
    [TestFlight passCheckpoint:@"Send Feedback clicked"];
    if ([MFMailComposeViewController canSendMail])
    {
        modalIsShowing = YES;
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        NSString *versionNumber =  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        [mailViewController setSubject:[NSString stringWithFormat:@"Tilbakemelding på nyhetene %@",  versionNumber]];
        NSArray *recipients = [[NSArray alloc] initWithObjects:@"nyheteneapp@gmail.com", nil];
        [mailViewController setToRecipients:recipients];
        [self presentViewController:mailViewController animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Send tilbakemelding" message:@"Ingen mailkonto er lagt inn på enheten. Registrer en mailkonto og prøv igjen." delegate:self cancelButtonTitle:@"Lukk" otherButtonTitles: nil];
        [alertView show];
    }
}

- (void)rateApp
{
    [TestFlight passCheckpoint:@"Rate app clicked"];
    NSString* url = [NSString stringWithFormat: @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", @"608290153"];
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
}

- (void)followOnTwitter
{
    [TestFlight passCheckpoint:@"Follow on Twitter clicked"];
    BOOL canOpenUrl = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://user?screen_name=nyheteneapp"]];
    if (canOpenUrl)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=nyheteneapp"]];
    }
    else
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/nyheteneapp"]];
    }
}

- (void)likeOnFacebook
{
    [TestFlight passCheckpoint:@"Like on Facebook clicked"];
    BOOL canOpenUrl = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://profile/358349337615099"]];
    if (canOpenUrl)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"fb://profile/358349337615099"]];
    }
    else
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.facebook.com/pages/Nyhetene/358349337615099"]];
    }
}

- (BOOL)shouldAutorotate
{
    return NO;
}

#pragma mark Mail delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    // Remove the mail view
    [self dismissViewControllerAnimated:YES completion:^{
        modalIsShowing = NO;
    }];
}

@end
