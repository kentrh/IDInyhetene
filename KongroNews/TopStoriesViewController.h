//
//  TopStoriesViewController.h
//  KongroNews
//
//  Created by Kent Robin Haugen on 18.02.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADBannerView.h"

@interface TopStoriesViewController : UIViewController <UIScrollViewDelegate, GADBannerViewDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *rootScrollView;
@property (strong, nonatomic) NSMutableArray *singleNewsVCs;
@property (strong, nonatomic) GADBannerView *adBannerView;
@property (assign, nonatomic) int categoryTag;
@property (strong, nonatomic) NSString *queryUrl;


@end
