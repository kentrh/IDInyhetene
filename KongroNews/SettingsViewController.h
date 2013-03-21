//
//  SettingsViewController.h
//  KongroNews
//
//  Created by Kent Robin Haugen on 04.03.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface SettingsViewController : UIViewController <MFMailComposeViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UIView *feedbackView;
@property (strong, nonatomic) IBOutlet UIView *rateView;
@property (strong, nonatomic) IBOutlet UIView *facebookView;
@property (strong, nonatomic) IBOutlet UIView *twitterView;

@end
