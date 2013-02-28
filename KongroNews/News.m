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

- (id)initWithCoder:(NSCoder *)decoder
{
    if(self = [super init])
    {
        _title = [decoder decodeObjectForKey:@"title"];
        _leadText = [decoder decodeObjectForKey:@"leadText"];
        _link = [decoder decodeObjectForKey:@"link"];
        _pubDate = [decoder decodeObjectForKey:@"pubDate"];
        _imageType = [decoder decodeObjectForKey:@"imageType"];
        _imageUrl = [decoder decodeObjectForKey:@"imageUrl"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_title forKey:@"title"];
    [encoder encodeObject:_leadText forKey:@"leadText"];
    [encoder encodeObject:_link forKey:@"link"];
    [encoder encodeObject:_pubDate forKey:@"pubDate"];
    [encoder encodeObject:_imageType forKey:@"imageType"];
    [encoder encodeObject:_imageUrl forKey:@"imageUrl"];
}

@end
