//
//  ArticlesViewController.h
//  KongroNews
//
//  Created by Kent Robin Haugen on 27.03.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "News.h"
#import <MessageUI/MessageUI.h>
#import "NewsPageViewController.h"

@interface ArticlesViewController : UIViewController <UIAlertViewDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (assign, nonatomic) BOOL shouldAnimateFromMainView;
@property (assign, nonatomic) BOOL shouldAnimateFromWebView;
@property (strong, nonatomic) News *newsArticle;

//pageviewcontroller stuff
@property (strong, nonatomic) NewsPageViewController *pageViewController;
@property (assign, nonatomic) int pageIndex;

@end
