//
//  TutorialViewController.h
//  KongroNews
//
//  Created by Kent Robin Haugen on 22.03.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TutorialViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIButton *closeButton;
@property (strong, nonatomic) IBOutlet UIButton *nextButton;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;

- (IBAction)closeAction:(id)sender;
- (IBAction)nextAction:(id)sender;

@end
