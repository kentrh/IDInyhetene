//
//  GeoLocation.h
//  KongroNews
//
//  Created by Kent Robin Haugen on 28.03.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GeoLocation : NSObject

@property (assign, nonatomic) float latitude;
@property (assign, nonatomic) float longitude;
@property (strong, nonatomic) NSString *name;

- (id)initWithLatitude:(float)latitude longitude:(float)longitude nameOfLocation:(NSString *)name;
- (id)initWithLatitude:(float)latitude longitude:(float)longitude;


@end
