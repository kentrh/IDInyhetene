//
//  UserProfile.h
//  KongroNews
//
//  Created by Kent Robin Haugen on 03.06.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserProfile : NSObject

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSDictionary *contentInterests;
@property (nonatomic, strong) NSDictionary *categoryInterests;
@property (nonatomic, assign) float categoryWeight;
@property (nonatomic, assign) float contentWeight;
@property (nonatomic, assign) float freshnessWeight;
@property (nonatomic, assign) float geoDistanceWeight;

-(id)initWithUserId:(NSString *)userId
   contentInterests:(NSDictionary *)contentInterests
  categoryInterests:(NSDictionary *)categoryInterests
     categoryWeight:(float)categoryWeight
      contentWeight:(float)contentWeight
    freshnessWeight:(float)freshnessWeight
  geoDistanceWeight:(float)geoDistanceWeight;

-(NSData *)parseUserProfileToJSONObject;

@end
