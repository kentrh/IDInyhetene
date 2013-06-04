//
//  SettingsViewController.h
//  KongroNews
//
//  Created by Kent Robin Haugen on 04.03.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MapKit/MapKit.h>

@interface SettingsViewController : UIViewController <MKMapViewDelegate, NSURLConnectionDataDelegate, UIAlertViewDelegate>
- (IBAction)resetProfileButtonAction:(UIButton *)sender;
- (IBAction)loadProfileButtonAction:(UIButton *)sender;
- (IBAction)saveProfileButtonAction:(UIButton *)sender;
- (IBAction)locateMeButtonAction:(UIButton *)sender;

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UILabel *positionLabel;

@property (strong, nonatomic) IBOutlet UIButton *resetProfileButton;
@property (strong, nonatomic) IBOutlet UIButton *loadProfileButton;
@property (strong, nonatomic) IBOutlet UIButton *saveProfileButton;

@property (strong, nonatomic) IBOutlet UIView *mapOverlayView;

@property (strong, nonatomic) IBOutlet UISlider *freshnessTicker;
@property (strong, nonatomic) IBOutlet UISlider *geoDistanceTicker;
@property (strong, nonatomic) IBOutlet UISlider *categoryTicker;
@property (strong, nonatomic) IBOutlet UISlider *contentTicker;



@end
