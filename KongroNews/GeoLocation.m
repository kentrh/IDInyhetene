//
//  GeoLocation.m
//  KongroNews
//
//  Created by Kent Robin Haugen on 28.03.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import "GeoLocation.h"

@implementation GeoLocation

- (id)initWithLatitude:(float)latitude longitude:(float)longitude nameOfLocation:(NSString *)name
{
    self = [super init];
    if (self)
    {
        _latitude = latitude;
        _longitude = longitude;
        _name = name;
    }
    return self;
}

- (id)initWithLatitude:(float)latitude longitude:(float)longitude
{
    self = [super init];
    if (self) {
        _latitude = latitude;
        _longitude = longitude;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if(self = [super init])
    {
        _name = [decoder decodeObjectForKey:@"name"];
        _latitude = [decoder decodeFloatForKey:@"latitude"];
        _longitude = [decoder decodeFloatForKey:@"longitude"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_name forKey:@"name"];
    [encoder encodeFloat:_latitude forKey:@"latitude"];
    [encoder encodeFloat:_longitude forKey:@"longitude"];
    
}

@end
