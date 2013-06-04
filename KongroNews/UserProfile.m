//
//  UserProfile.m
//  KongroNews
//
//  Created by Kent Robin Haugen on 03.06.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import "UserProfile.h"
#import "Constants.h"

@implementation UserProfile

-(id)initWithUserId:(NSString *)userId
   contentInterests:(NSDictionary *)contentInterests
  categoryInterests:(NSDictionary *)categoryInterests
     categoryWeight:(float)categoryWeight
      contentWeight:(float)contentWeight
    freshnessWeight:(float)freshnessWeight
  geoDistanceWeight:(float)geoDistanceWeight
{
    self = [super init];
    if (self) {
        _userId = userId;
        _contentInterests = contentInterests;
        _categoryInterests = categoryInterests;
        _categoryWeight = categoryWeight;
        _contentWeight = contentWeight;
        _freshnessWeight = freshnessWeight;
        _geoDistanceWeight = geoDistanceWeight;
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)decoder
{
    if(self = [super init])
    {
        _userId = [decoder decodeObjectForKey:@"userId"];
        _contentInterests = [decoder decodeObjectForKey:@"contentInterests"];
        _categoryInterests = [decoder decodeObjectForKey:@"categoryInterests"];
        _categoryWeight = [decoder decodeFloatForKey:@"categoryWeight"];
        _contentWeight = [decoder decodeFloatForKey:@"contentWeight"];
        _freshnessWeight = [decoder decodeFloatForKey:@"freshnessWeight"];
        _geoDistanceWeight = [decoder decodeFloatForKey:@"geoDistanceWeight"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_userId forKey:@"userId"];
    [encoder encodeObject:_contentInterests forKey:@"contentInterests"];
    [encoder encodeObject:_categoryInterests forKey:@"categoryInterests"];
    [encoder encodeFloat:_categoryWeight forKey:@"categoryWeight"];
    [encoder encodeFloat:_contentWeight forKey:@"contentWeight"];
    [encoder encodeFloat:_freshnessWeight forKey:@"freshnessWeight"];
    [encoder encodeFloat:_geoDistanceWeight forKey:@"geoDistanceWeight"];
    
}

-(NSData *)parseUserProfileToJSONObject
{
    
    NSDictionary *userProfile = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 _userId, JSON_USER_PROFILE_USER_ID,
                                 _contentInterests, JSON_USER_PROFILE_CONTENT_INTERESTS,
                                 _categoryInterests, JSON_USER_PROFILE_CATEGORY_INTERESTS,
                                 [NSString stringWithFormat:@"%f", _categoryWeight], JSON_USER_PROFILE_CATEGORY_INTEREST_WEIGHT,
                                 [NSString stringWithFormat:@"%f", _contentWeight], JSON_USER_PROFILE_CONTENT_INTEREST_WEIGHT,
                                 [NSString stringWithFormat:@"%f", _freshnessWeight], JSON_USER_PROFILE_FRESHNESS_WEIGHT,
                                 [NSString stringWithFormat:@"%f", _geoDistanceWeight], JSON_USER_PROFILE_GEO_DISTANCE_WEIGHT, nil];
    
    
    NSError *error;
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:userProfile options:0 error:&error];
    
    
    return JSONData;
}

@end
