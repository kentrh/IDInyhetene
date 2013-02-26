//
//  FrontPageViewController.h
//  KongroNews
//
//  Created by Kent Robin Haugen on 21.02.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FrontPageViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *headlineButton;
@property (strong, nonatomic) IBOutlet UILabel *numberOfNewsLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeSinceLabel;
@property (strong, nonatomic) UIScrollView *parentScrollView;

- (IBAction)headlineButtonPushed:(UIButton *)sender;
@end
