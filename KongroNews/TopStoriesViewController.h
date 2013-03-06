//
//  TopStoriesViewController.h
//  KongroNews
//
//  Created by Kent Robin Haugen on 18.02.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADBannerView.h"
#import "News.h"
#import <MessageUI/MessageUI.h>

@interface TopStoriesViewController : UIViewController <UIScrollViewDelegate, GADBannerViewDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *rootScrollView;
@property (strong, nonatomic) NSMutableArray *singleNewsVCs;
@property (strong, nonatomic) GADBannerView *adBannerView;
@property (assign, nonatomic) int categoryTag;
@property (strong, nonatomic) NSString *queryUrl;
@property (assign, nonatomic) BOOL shouldAnimate;

- (void)presentMailComposerWithNews:(News *)newsArticle;

@end
