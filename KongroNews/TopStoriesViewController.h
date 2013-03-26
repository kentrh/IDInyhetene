//
//  TopStoriesViewController.h
//  KongroNews
//
//  Created by Kent Robin Haugen on 18.02.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "News.h"
#import <MessageUI/MessageUI.h>
#import "NewsPageViewController.h"

@interface TopStoriesViewController : UIViewController <UIAlertViewDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (assign, nonatomic) int categoryTag;
@property (strong, nonatomic) NSString *queryUrl;
@property (assign, nonatomic) BOOL shouldAnimateFromMainView;
@property (assign, nonatomic) BOOL shouldAnimateFromWebView;

//pageviewcontroller stuff
@property (strong, nonatomic) NewsPageViewController *pageViewController;
@property (assign, nonatomic) int pageIndex;

@end
