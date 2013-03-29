//
//  MapViewController.h
//  KongroNews
//
//  Created by Kent Robin Haugen on 29.03.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "News.h"

@interface MapViewController : UIViewController <MKMapViewDelegate, UIGestureRecognizerDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) News *newsArticle;
@end
