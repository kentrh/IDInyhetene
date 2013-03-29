//
//  FrontPageViewController.h
//  KongroNews
//
//  Created by Kent Robin Haugen on 21.02.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMPopTipView.h"

@interface FrontPageViewController : UIViewController <UITextFieldDelegate, CMPopTipViewDelegate>

@property (strong, nonatomic) IBOutlet UIButton *headlineButton;
@property (strong, nonatomic) IBOutlet UILabel *numberOfNewsLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeSinceLabel;
@property (strong, nonatomic) UIScrollView *parentScrollView;
@property (strong, nonatomic) IBOutlet UITextField *searchField;
@property (assign, nonatomic) BOOL settingsIsShowing;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UILabel *frontPageArticlesLabel;

- (IBAction)headlineButtonPushed:(UIButton *)sender;
- (IBAction)searchAction:(UITextField *)sender;
- (IBAction)usernameDoneTyping:(UITextField *)sender;
- (IBAction)passwordDoneTyping:(UITextField *)sender;
- (void)updateFrontPageNews;
- (void)setUpPopUp;
@end
