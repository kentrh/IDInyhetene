//
//  SingleNewsViewController.h
//  KongroNews
//
//  Created by Kent Robin Haugen on 23.02.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "News.h"
#import "KLExpandingSelect.h"
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>
#import "TopStoriesViewController.h"


@interface SingleNewsViewController : UIViewController <KLExpandingSelectDataSource, KLExpandingSelectDelegate, UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) News *newsArticle;
@property (strong, nonatomic) IBOutlet UILabel *timeSinceLabel;
@property (strong, nonatomic) IBOutlet UILabel *providerLabel;
@property (strong, nonatomic) IBOutlet UILabel *pageNumber;
@property (assign, nonatomic) int pageIndex;
@end
