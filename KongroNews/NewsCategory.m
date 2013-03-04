//
//  NewsCategory.m
//  KongroNews
//
//  Created by Kent Robin Haugen on 02.03.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import "NewsCategory.h"

@implementation NewsCategory

- (id)initWithName:(NSString *)name displayName:(NSString *)displayName tag:(int)tag url:(NSString *)url
{
    self = [super init];
    if (self)
    {
        _displayName = displayName;
        _name = name;
        _tag = tag;
        _url = url;
    }
    return self;
}

@end
