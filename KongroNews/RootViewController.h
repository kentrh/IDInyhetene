//
//  RootViewController.h
//  KongroNews
//
//  Created by Kent Robin Haugen on 24.02.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface RootViewController : UIViewController <UIScrollViewDelegate, CLLocationManagerDelegate>{
    CLLocationManager *locationManager;
}

@property (strong, nonatomic) IBOutlet UIScrollView *rootScrollView;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;

+ (BOOL)isFirstRun;
+ (void)setIsFirstRun:(BOOL)firstRun;

+ (CLLocation *)lastUpdatedLocation;
@end
