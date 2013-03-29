//
//  MapViewController.m
//  KongroNews
//
//  Created by Kent Robin Haugen on 29.03.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import "MapViewController.h"
#import "GeoLocation.h"
#import "Annotation.h"

@interface MapViewController ()

@end

@implementation MapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self addAnnotations];
    [self setContentRegionForMap];
    [self addDoubleTapGestureRecognizer];
}

- (void)setUpMapView
{
    _mapView.delegate = self;
    [_mapView setShowsUserLocation:YES];
}

- (void)addAnnotations
{
    
    for (int i=0; i<[_newsArticle.locations count]; i++)
    {
//        CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
        
        GeoLocation *geoLocation = [_newsArticle.locations objectAtIndex:i];
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(geoLocation.latitude, geoLocation.longitude);
        Annotation *annotation = [[Annotation alloc] init];
        [annotation setCoordinate:coord];
        [_mapView addAnnotation:annotation];
//        CLLocation *location = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
//        [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
//            if (!error) {
//                NSString *locationHeader;
//                NSString *locationSubtitle;
//                for (CLPlacemark *placemark in placemarks) {
//                    locationHeader = [placemark locality];
//                    locationSubtitle = [placemark name];
//                }
//                if (locationHeader.length > 0) [annotation setTitle:locationHeader];
//                if (locationSubtitle.length > 0) [annotation setSubtitle:locationSubtitle];
//                [_mapView addAnnotation:annotation];
//                
//            }
//            else {
//                NSLog(@"There was a reverse geocoding error\n%@", [error localizedDescription]);
//            }
//            
//        }];
        
    }
}

- (void)addDoubleTapGestureRecognizer
{
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    doubleTap.delegate = self;
    [self.view addGestureRecognizer:doubleTap];
}

- (IBAction)doubleTapAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)setContentRegionForMap
{
    
    if (_newsArticle.locations.count == 1) {
        GeoLocation *location = [_newsArticle.locations objectAtIndex:0];
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(location.latitude, location.longitude);
        MKCoordinateSpan span = MKCoordinateSpanMake((CLLocationDegrees)4.0f, (CLLocationDegrees)4.0f);
        MKCoordinateRegion region = MKCoordinateRegionMake(coord, span);
        [_mapView setRegion:[_mapView regionThatFits:region] animated:YES];
    }
    else{
        double maxLong = DBL_MIN;
        double minLong = DBL_MAX;
        double maxLat = DBL_MIN;
        double minLat = DBL_MAX;
        
        for (GeoLocation *coords in _newsArticle.locations) {
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(coords.latitude, coords.longitude);
            maxLong = MAX(maxLong, coord.longitude);
            minLong = MIN(minLong, coord.longitude);
            maxLat = MAX(maxLat, coord.latitude);
            minLat = MIN(minLat, coord.latitude);
        }
        CLLocationCoordinate2D center = CLLocationCoordinate2DMake((maxLat+minLat)/2.0, (maxLong+minLong)/2.0);
        MKCoordinateSpan span = MKCoordinateSpanMake((maxLat-minLat)*1.25, (maxLong-minLong)*1.1);
        MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
        [_mapView setRegion:[_mapView regionThatFits:region] animated:YES];
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
