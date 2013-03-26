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
#import "HelpMethods.h"
#import "RootViewController.h"
#import "CategoriesViewController.h"

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
    [self setStartPositionForAnimation];
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

- (void)addGestureRecognizer
{
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDownTriggered:)];
    swipe.direction = UISwipeGestureRecognizerDirectionDown;
    swipe.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:swipe];
}

- (IBAction)swipeDownTriggered:(id)sender
{
    [self closeSettingsView];
}

- (void)closeSettingsView
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

- (void)startHelpSession
{
    [TestFlight passCheckpoint:@"SettingsView: Start help session clicked."];
    FrontPageViewController *fpvc;
    CategoriesViewController *cvc;
    for (UIViewController *vc in self.parentViewController.childViewControllers) {
        if ([vc isKindOfClass:[FrontPageViewController class]]) {
            fpvc = (FrontPageViewController *)vc;
        }
        if ([vc isKindOfClass:[CategoriesViewController class]]) {
            cvc = (CategoriesViewController *)vc;
        }
        
    }
    [RootViewController setIsFirstRun:YES];
    [fpvc setUpPopUp];
    [cvc setUpPopUp];
    [self closeSettingsView];
}

- (void)sendFeedback
{
    [TestFlight passCheckpoint:@"SettingsView: Send Feedback clicked."];
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
