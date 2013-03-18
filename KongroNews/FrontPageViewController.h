//
//  FrontPageViewController.h
//  KongroNews
//
//  Created by Kent Robin Haugen on 21.02.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FrontPageViewController : UIViewController <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UIButton *headlineButton;
@property (strong, nonatomic) IBOutlet UILabel *numberOfNewsLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeSinceLabel;
@property (strong, nonatomic) UIScrollView *parentScrollView;
@property (strong, nonatomic) IBOutlet UITextField *searchField;
@property (assign, nonatomic) BOOL settingsIsShowing;

- (IBAction)headlineButtonPushed:(UIButton *)sender;
- (IBAction)searchAction:(UITextField *)sender;
- (void)updateFrontPageNews;
@end
