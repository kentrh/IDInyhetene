//
//  Annotation.h
//  KongroNews
//
//  Created by Kent Robin Haugen on 29.03.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Annotation : NSObject <MKAnnotation>

@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *subtitle;
@property (assign, nonatomic) int tag;

@end
