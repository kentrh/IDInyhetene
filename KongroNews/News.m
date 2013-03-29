//
//  News.m
//  KongroNews
//
//  Created by Kent Robin Haugen on 19.02.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import "News.h"

@implementation News


- (id) initWithArticleId:(int)articleId
                   title:(NSString *)title
                leadText:(NSString *)leadText
                bodyText:(NSString *)bodyText
               publisher:(NSString *)publisher
                  author:(NSString *)author
               published:(NSDate *)published
                    tags:(NSArray *)tags
              categories:(NSArray *)categories
                  images:(NSArray *)images
               sourceUrl:(NSURL *)sourceUrl
               locations:(NSArray *)locations
            geoLocations:(NSArray *)geoLocations
          sentimentValue:(float)sentimentValue
{
    self = [super init];
    if (self)
    {
        _articleId = articleId;
        _title = title;
        _leadText = leadText;
        _bodyText = bodyText;
        _publisher = publisher;
        _author = author;
        _published = published;
        _tags = tags;
        _categories = categories;
        _images = images;
        _sourceUrl = sourceUrl;
        _locations = locations;
        _geoLocations = geoLocations;
        _sentimentValue = sentimentValue;
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if(self = [super init])
    {
        _articleId = [decoder decodeIntForKey:@"articleId"];
        _title = [decoder decodeObjectForKey:@"title"];
        _leadText = [decoder decodeObjectForKey:@"leadText"];
        _bodyText = [decoder decodeObjectForKey:@"bodyText"];
        _publisher = [decoder decodeObjectForKey:@"publisher"];
        _author = [decoder decodeObjectForKey:@"author"];
        _published = [decoder decodeObjectForKey:@"published"];
        _tags = [decoder decodeObjectForKey:@"tags"];
        _categories = [decoder decodeObjectForKey:@"categories"];
        _images = [decoder decodeObjectForKey:@"images"];
        _sourceUrl = [decoder decodeObjectForKey:@"sourceUrl"];
        _locations = [decoder decodeObjectForKey:@"locations"];
        _geoLocations = [decoder decodeObjectForKey:@"geoLocations"];
        _sentimentValue = [decoder decodeFloatForKey:@"sentimentValue"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeInt:_articleId forKey:@"articleId"];
    [encoder encodeObject:_title forKey:@"title"];
    [encoder encodeObject:_leadText forKey:@"leadText"];
    [encoder encodeObject:_bodyText forKey:@"bodyText"];
    [encoder encodeObject:_publisher forKey:@"publisher"];
    [encoder encodeObject:_author forKey:@"author"];
    [encoder encodeObject:_published forKey:@"published"];
    [encoder encodeObject:_tags forKey:@"tags"];
    [encoder encodeObject:_categories forKey:@"categories"];
    [encoder encodeObject:_images forKey:@"images"];
    [encoder encodeObject:_sourceUrl forKey:@"sourceUrl"];
    [encoder encodeObject:_locations forKey:@"locations"];
    [encoder encodeObject:_geoLocations forKey:@"geoLocations"];
    [encoder encodeFloat:_sentimentValue forKey:@"sentimentValue"];
}

@end
