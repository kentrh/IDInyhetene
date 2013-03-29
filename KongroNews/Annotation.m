//
//  Annotation.m
//  KongroNews
//
//  Created by Kent Robin Haugen on 29.03.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import "Annotation.h"

@implementation Annotation

-(id)initWithCoordinate:(CLLocationCoordinate2D)coord title:(NSString *)tit subtitle:(NSString *)subtit{
    
    self = [super init];
    if (self){
        _coordinate = coord;
        _title = tit;
        _subtitle = subtit;
    }
    return self;
}

-(id)initWithCoordinate:(CLLocationCoordinate2D)coord title:(NSString *)tit{
    
    self = [super init];
    if (self){
        _coordinate = coord;
        _title = tit;
    }
    return self;
}

-(id)initWithCoordinate:(CLLocationCoordinate2D)coord{
    
    self = [super init];
    if (self){
        _coordinate = coord;
    }
    return self;
}

@end
