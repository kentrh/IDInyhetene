//
//  WebViewController.h
//  KongroNews
//
//  Created by Kent Robin Haugen on 24.02.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "News.h"
#import "GADBannerView.h"

@interface WebViewController : UIViewController <UIWebViewDelegate, UIGestureRecognizerDelegate, GADBannerViewDelegate>
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) News *news;
@property (strong, nonatomic) IBOutlet UIToolbar *navToolbar;
@property (strong, nonatomic) GADBannerView *adBannerView;

@end
