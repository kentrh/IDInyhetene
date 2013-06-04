//
//  SettingsViewController.m
//  KongroNews
//
//  Created by Kent Robin Haugen on 04.03.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import "SettingsViewController.h"
#import "Colors.h"
#import "SKBounceAnimation.h"
#import "Constants.h"
#import "FrontPageViewController.h"
#import "HelpMethods.h"
#import "RootViewController.h"
#import "Annotation.h"
#import "CategoriesViewController.h"
#import "UserProfile.h"


#define JSON_BASE_URL_GET_USER_PROFILE @"http://vm-6120.idi.ntnu.no/news-rec-service/getUserProfile?userId=%@"
#define JSON_BASE_URL_POST_USER_PROFILE @"http://vm-6120.idi.ntnu.no/news-rec-service/postUserProfile"

@interface SettingsViewController (){
    BOOL modalIsShowing;
    CLLocationCoordinate2D *storedLocation;
    UserProfile *_userProfile;
    NSString *inProgressWord;
    NSString *doneProgressWord;
}

@end

@implementation SettingsViewController

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
    [self performSelectorInBackground:@selector(loadProfile) withObject:nil];
    [self setStartPositionForAnimation];
    [self addGestureRecognizer];
    [self setUpUI];
    [self setUpMapView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    if (!modalIsShowing)
    {
        [self setStartPositionForAnimation];
        [self startBounceInAnimation];
    }
}

- (void)setUpUI
{
    _resetProfileButton.backgroundColor = [Colors lightBlue];
    _loadProfileButton.backgroundColor = [Colors lightBlue];
    _saveProfileButton.backgroundColor = [Colors lightBlue];
    
    _mapOverlayView.backgroundColor = [UIColor colorWithWhite:0.7f alpha:0.5];
}

- (void)setUpMapView
{
    _mapView.delegate = self;
    
    //Add long gesture recognizer to _mapView to be able to drop a pin on a desired location.
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressOnMapTriggered:)];
    [longPress setNumberOfTapsRequired:0];
    [longPress setNumberOfTouchesRequired:1];
    [longPress setMinimumPressDuration:0.5f];
    [_mapView addGestureRecognizer:longPress];
    
    CLLocationCoordinate2D location = [RootViewController lastUpdatedLocation].coordinate;
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(location.latitude, location.longitude);
    MKCoordinateSpan span = MKCoordinateSpanMake((CLLocationDegrees)1.0f, (CLLocationDegrees)1.0f);
    MKCoordinateRegion region = MKCoordinateRegionMake(coord, span);
    [_mapView setRegion:[_mapView regionThatFits:region] animated:YES];
    
    [self setLocationNameInMapFromCoordinate:location];
    Annotation *mapPin = [[Annotation alloc] init];
    [mapPin setCoordinate:location];
    [_mapView addAnnotation:mapPin];

}

- (IBAction)longPressOnMapTriggered:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        [self addAnnotationPinToMap:[sender locationInView:_mapView]];
    }
}

- (void)addAnnotationPinToMap:(CGPoint)locationInView
{
    [_mapView removeAnnotations:[_mapView annotations]];
    CLLocationCoordinate2D location = [_mapView convertPoint:locationInView toCoordinateFromView:_mapView];
    Annotation *mapPin = [[Annotation alloc] init];
    [mapPin setCoordinate:location];
    [_mapView addAnnotation:mapPin];
    [self setLocationNameInMapFromCoordinate:location];
    CLLocation *rootViewLocation = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];
    [RootViewController setLastLocation:rootViewLocation];
    
}

- (void)addGestureRecognizer
{
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDownTriggered:)];
    swipe.direction = UISwipeGestureRecognizerDirectionDown;
    swipe.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:swipe];
}

- (IBAction)swipeDownTriggered:(id)sender
{
    [self closeSettingsView];
}

- (void)closeSettingsView
{
    [self storeLocationInUserDefaults];
    
    CGRect rect = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    [UIView animateWithDuration:0.3f animations:^{
        self.view.frame = rect;
    } completion:^(BOOL finished) {
        for (UIViewController *vc in self.parentViewController.childViewControllers) {
            if ([vc isKindOfClass:[FrontPageViewController class]]) {
                [(FrontPageViewController *)vc setSettingsIsShowing:NO];
                [(FrontPageViewController *)vc updateFrontPageNews];
                [vc viewDidAppear:YES];
            }
        }
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}

- (void)storeLocationInUserDefaults
{
    NSData *locationData = [NSKeyedArchiver archivedDataWithRootObject:[RootViewController lastUpdatedLocation]];
    [[NSUserDefaults standardUserDefaults] setObject:locationData forKey:USER_DEFAULTS_PREVIOUS_LOCATION];
}

- (void)setStartPositionForAnimation
{
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    frame.origin.y = frame.size.height;
    self.view.frame = frame;
}

- (void)startBounceInAnimation
{
    NSString *keyPath = @"position.y";
    CGRect frame = [[UIScreen mainScreen] bounds];
    CGPoint center = CGPointMake(frame.size.width/2, frame.size.height/2);
    id finalValue = [NSNumber numberWithFloat:center.y];
    
    SKBounceAnimation *bounceAnimation = [SKBounceAnimation animationWithKeyPath:keyPath];
    bounceAnimation.fromValue = [NSNumber numberWithFloat:self.view.center.y];
    bounceAnimation.toValue = finalValue;
    bounceAnimation.duration = ANIMATION_DURATION;
    bounceAnimation.numberOfBounces = ANIMATION_NUMBER_OF_BOUNCES;
    bounceAnimation.shouldOvershoot = ANIMATION_SHOULD_OVERSHOOT;
    
    [self.view.layer addAnimation:bounceAnimation forKey:@"someKey"];
    [self.view.layer setValue:finalValue forKeyPath:keyPath];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (IBAction)resetProfileButtonAction:(UIButton *)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Er du sikker?" message:@"Er du helt sikker på at du vil nullstille data? All profilinformasjon blir slettet og brukerprofilen må bygges opp fra bunnen av igjen." delegate:self cancelButtonTitle:@"Avbryt" otherButtonTitles:@"Helt Sikker", nil];
    [alertView show];
}

- (IBAction)loadProfileButtonAction:(UIButton *)sender {
    [self performSelectorInBackground:@selector(loadProfile) withObject:nil];
}

- (IBAction)saveProfileButtonAction:(UIButton *)sender {
    [self performSelectorInBackground:@selector(saveProfile) withObject:nil];
}

- (IBAction)locateMeButtonAction:(UIButton *)sender {
    [self locateMe];
}

- (void)setLocationNameInMapFromCoordinate:(CLLocationCoordinate2D)coord
{
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error) {
            NSString *locationHeader;
            NSString *locationSubtitle;
            for (CLPlacemark *placemark in placemarks) {
                locationHeader = [placemark locality];
                locationSubtitle = [placemark name];
            }
            _positionLabel.text = locationHeader;
        }
        else {
            NSLog(@"There was a reverse geocoding error\n%@", [error localizedDescription]);
            _positionLabel.text = @"Ukjent";
        }
        
    }];
}


- (void)loadProfile
{
    inProgressWord = @"Laster profil";
    doneProgressWord = @"Profil lastet";
    [SVProgressHUD showWithStatus:inProgressWord maskType:SVProgressHUDMaskTypeBlack];
    NSString *urlString = [NSString stringWithFormat:JSON_BASE_URL_GET_USER_PROFILE, [[UIDevice currentDevice] uniqueDeviceIdentifier]];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if ([data length] > 0 && error == nil) {
            NSError *JSONError;
            NSLog(@"JSON summary: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            NSDictionary *userProfile = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&JSONError];
            NSString *userId = [userProfile objectForKey:JSON_USER_PROFILE_USER_ID];
            NSDictionary *categoryInterests = [userProfile objectForKey:JSON_USER_PROFILE_CATEGORY_INTERESTS];
            NSDictionary *contentInterests = [userProfile objectForKey:JSON_USER_PROFILE_CONTENT_INTERESTS];
            float categoryWeight = [[userProfile objectForKey:JSON_USER_PROFILE_CATEGORY_INTEREST_WEIGHT] floatValue];
            float contentWeight = [[userProfile objectForKey:JSON_USER_PROFILE_CONTENT_INTEREST_WEIGHT] floatValue];
            float freshnessWeight = [[userProfile objectForKey:JSON_USER_PROFILE_FRESHNESS_WEIGHT] floatValue];
            float geoDistanceWeight = [[userProfile objectForKey:JSON_USER_PROFILE_GEO_DISTANCE_WEIGHT] floatValue];
            
            _userProfile = [[UserProfile alloc] initWithUserId:userId contentInterests:contentInterests categoryInterests:categoryInterests categoryWeight:categoryWeight contentWeight:contentWeight freshnessWeight:freshnessWeight geoDistanceWeight:geoDistanceWeight];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateProfileUI];
                [SVProgressHUD dismiss];
            });
        }
        else if ([data length] == 0 && error == nil) {
            [SVProgressHUD showErrorWithStatus:@"Kunne ikke hente data"];
            }
        else if (error != nil && error.code == NSURLErrorTimedOut) {
            [SVProgressHUD showErrorWithStatus:@"Kunne ikke hente data"];
        }
        else if (error != nil) {
            [SVProgressHUD showErrorWithStatus:@"Kunne ikke hente data"];
        }
    }];
}

-(void)updateProfileUI
{
    _freshnessTicker.value = _userProfile.freshnessWeight;
    _geoDistanceTicker.value = _userProfile.geoDistanceWeight;
    _contentTicker.value = _userProfile.contentWeight;
    _categoryTicker.value = _userProfile.categoryWeight;
}

-(void)saveProfile
{
    inProgressWord = @"Lagrer profil";
    doneProgressWord = @"Profil lagret";
    [SVProgressHUD showProgress:0.0f status:inProgressWord maskType:SVProgressHUDMaskTypeBlack];
    dispatch_async(dispatch_get_main_queue(), ^{
        _userProfile.freshnessWeight = _freshnessTicker.value;
        _userProfile.geoDistanceWeight = _geoDistanceTicker.value;
        _userProfile.contentWeight = _contentTicker.value;
        _userProfile.categoryWeight = _categoryTicker.value;
        
        NSData *postData = [_userProfile parseUserProfileToJSONObject];
        
        NSLog(@"JSON summary: %@", [[NSString alloc] initWithData:postData
                                                         encoding:NSUTF8StringEncoding]);
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:JSON_BASE_URL_POST_USER_PROFILE]];
        [request setHTTPMethod:@"POST"];
        
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
        [request setHTTPBody:postData];
        
        [NSURLConnection connectionWithRequest:request delegate:self];
    });
}

-(void)resetProfile
{
    inProgressWord = @"Nullstiller profil";
    doneProgressWord = @"Profil nullstilt";
    NSString *userId = _userProfile.userId;
    [SVProgressHUD showProgress:0.0f status:inProgressWord maskType:SVProgressHUDMaskTypeBlack];
    _userProfile = [[UserProfile alloc] initWithUserId:userId contentInterests:[[NSDictionary alloc] init] categoryInterests:[[NSDictionary alloc] init] categoryWeight:50.0f contentWeight:50.0f freshnessWeight:50.0f geoDistanceWeight:50.0f];
    [self updateProfileUI];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSData *postData = [_userProfile parseUserProfileToJSONObject];
        
        NSLog(@"JSON summary: %@", [[NSString alloc] initWithData:postData
                                                         encoding:NSUTF8StringEncoding]);
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:JSON_BASE_URL_POST_USER_PROFILE]];
        [request setHTTPMethod:@"POST"];
        
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
        [request setHTTPBody:postData];
        
        [NSURLConnection connectionWithRequest:request delegate:self];
    });
}

-(void)locateMe
{
    [SVProgressHUD showWithStatus:@"Lokaliserer.." maskType:SVProgressHUDMaskTypeBlack];
    [_mapView setShowsUserLocation:YES];
}

-(void)setUserLocationOnMapWithLocation:(CLLocationCoordinate2D)location
{
    [_mapView removeAnnotations:[_mapView annotations]];
    [_mapView setCenterCoordinate:location animated:YES];
    Annotation *mapPin = [[Annotation alloc] init];
    [mapPin setCoordinate:location];
    [_mapView addAnnotation:mapPin];
    [self setLocationNameInMapFromCoordinate:location];
    CLLocation *rootViewLocation = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];
    [RootViewController setLastLocation:rootViewLocation];
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(Annotation *) annotation
{
    MKPinAnnotationView *newAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"annotation1"];
    newAnnotation.pinColor = MKPinAnnotationColorGreen;
    newAnnotation.animatesDrop = YES;
    newAnnotation.canShowCallout = NO;
    [newAnnotation setSelected:YES animated:YES];
    return newAnnotation;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    [self setUserLocationOnMapWithLocation:userLocation.location.coordinate];
    [_mapView setShowsUserLocation:NO];
    [SVProgressHUD showSuccessWithStatus:@"Lokalisert"];
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    if (totalBytesWritten == totalBytesExpectedToWrite) {
        [SVProgressHUD showSuccessWithStatus:doneProgressWord];
    }
    else {
        float percent = (float) totalBytesWritten/totalBytesExpectedToWrite;
        [SVProgressHUD showProgress:percent status:inProgressWord maskType:SVProgressHUDMaskTypeBlack];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"faaailed");
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [SVProgressHUD showErrorWithStatus:@"Nullstill profil avbrutt"];
    }
    else {
        [self performSelectorInBackground:@selector(resetProfile) withObject:nil];
    }
}
@end
