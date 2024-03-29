//
//  SingleArticleViewController.h
//  KongroNews
//
//  Created by Kent Robin Haugen on 27.03.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "News.h"
#import "CMPopTipView.h"

@interface SingleArticleViewController : UIViewController <UIGestureRecognizerDelegate, CMPopTipViewDelegate>

@property (strong, nonatomic) News *newsArticle;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UITextView *leadTextLabel;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UITextView *bodyTextView;
@property (strong, nonatomic) IBOutlet UILabel *timeSinceLabel;
@property (strong, nonatomic) IBOutlet UILabel *publisherLabel;
@property (strong, nonatomic) IBOutlet UILabel *categoryLabel;
@property (strong, nonatomic) IBOutlet UIButton *mapButton;
- (IBAction)mapButtonAction:(UIButton *)sender;

@end
