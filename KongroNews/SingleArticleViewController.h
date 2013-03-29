//
//  SingleArticleViewController.h
//  KongroNews
//
//  Created by Kent Robin Haugen on 27.03.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "News.h"

@interface SingleArticleViewController : UIViewController <UIGestureRecognizerDelegate>

@property (strong, nonatomic) News *newsArticle;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UITextView *leadTextLabel;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UITextView *bodyTextView;
@property (strong, nonatomic) IBOutlet UIScrollView *rootScrollView;
@property (strong, nonatomic) IBOutlet UILabel *timeSinceLabel;
@property (strong, nonatomic) IBOutlet UILabel *publisherLabel;
@property (strong, nonatomic) IBOutlet UILabel *categoryLabel;

@end
