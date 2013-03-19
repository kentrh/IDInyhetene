//
//  TopStoriesViewController.h
//  KongroNews
//
//  Created by Kent Robin Haugen on 18.02.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADBannerView.h"
#import "GADInterstitial.h"
#import "News.h"
#import <MessageUI/MessageUI.h>

@interface TopStoriesViewController : UIViewController <GADBannerViewDelegate, UIAlertViewDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) GADBannerView *adBannerView;
@property (assign, nonatomic) int categoryTag;
@property (strong, nonatomic) NSString *queryUrl;
@property (assign, nonatomic) BOOL shouldAnimateFromMainView;
@property (assign, nonatomic) BOOL shouldAnimateFromWebView;

//pageviewcontroller stuff
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (assign, nonatomic) int pageIndex;

@end
