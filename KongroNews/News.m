//
//  News.m
//  KongroNews
//
//  Created by Kent Robin Haugen on 19.02.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import "News.h"

@implementation News

- (id)initWithTitle:(NSString *)title leadText:(NSString *)leadText link:(NSURL *)link pubDate:(NSDate *)pubDate imageType:(NSString *)imageType imageUrl:(NSURL *)imageUrl
{
    self = [super init];
    if (self)
    {
        _title = title;
        _leadText = leadText;
        _link = link;
        _pubDate = pubDate;
        _imageType = imageType;
        _imageUrl = imageUrl;
    }
    return self;
}



@end
