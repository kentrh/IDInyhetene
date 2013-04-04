//
//  NewsReadingEvent.m
//  KongroNews
//
//  Created by Kent Robin Haugen on 02.04.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import "NewsReadingEvent.h"
#import "Constants.h"

#define JSON_BASE_URL_POST_EVENTS @"http://vm-6120.idi.ntnu.no:8080/news-rec-service/postLog"

@implementation NewsReadingEvent

- (id)initWithGlobalIdentifier:(NSString *)identifier articleId:(NSString *)articleId userId:(NSString *)userId eventType:(NSString *)eventType timeStamp:(NSDate *)timeStamp geoLocation:(GeoLocation *)geoLocation properties:(NSDictionary *)properties
{
    self = [super init];
    if (self) {
        _identifier = identifier;
        _articleId = articleId;
        _userId = userId;
        _eventType = eventType;
        _timeStamp = timeStamp;
        _geoLocation = geoLocation;
        _properties = properties;
    }
    return self;
}

+ (void)addEventToQueue:(NewsReadingEvent *)event
{
    NSMutableArray *eventQueue;
    NSData *eventQueueData = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_NEWS_READING_EVENT_QUEUE];
    if (eventQueueData) {
        eventQueue = [NSKeyedUnarchiver unarchiveObjectWithData:eventQueueData];
    }
    else {
        eventQueue = [[NSMutableArray alloc] init];
    }
    NSDictionary *eventDictionary = [NewsReadingEvent parseEventToDictionary:event];
    [eventQueue addObject:eventDictionary];
    
    eventQueueData = [NSKeyedArchiver archivedDataWithRootObject:eventQueue];
    [[NSUserDefaults standardUserDefaults] setObject:eventQueueData forKey:USER_DEFAULTS_NEWS_READING_EVENT_QUEUE];
                      
}

+ (NSDictionary *)parseEventToDictionary:(NewsReadingEvent *)event
{
    NSString *geoName = event.geoLocation.name == nil ? @"" : event.geoLocation.name;
    NSString *geoType = event.geoLocation.type == nil ? @"" : event.geoLocation.type;
    NSString *geoLong = [NSString stringWithFormat:@"%f", event.geoLocation.longitude];
    NSString *geoLat = [NSString stringWithFormat:@"%f", event.geoLocation.latitude];
    
    
    NSDictionary *geoLocation = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 geoName, @"name",
                                 geoType, @"type",
                                 geoLong, @"longitude",
                                 geoLat, @"latitude", nil];
    
    NSString *identifier = event.identifier == nil ? @"" : event.identifier;
    NSString *articleId = event.articleId == nil ? @"" : event.articleId;
    NSString *userId = event.userId == nil ? @"" : event.userId;
    NSString *eventType = event.eventType == nil ? @"" : event.eventType;
    double milsecs = [event.timeStamp timeIntervalSince1970];
    milsecs = milsecs * 1000.0f;
    long long milsec = milsecs;
    NSString *timestamp = [NSString stringWithFormat:@"%lld", milsec];
    NSDictionary *properties = event.properties;
    
    NSDictionary *eventDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     identifier, @"id",
                                     articleId, @"articleId",
                                     userId, @"userId",
                                     eventType, @"eventType",
                                     timestamp, @"timestamp",
                                     geoLocation, @"geoLocation",
                                     properties, @"properties", nil];
    return eventDictionary;
}

+ (BOOL)postEventQueue
{
    NSMutableArray *eventQueue;
    NSData *eventQueueData = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_NEWS_READING_EVENT_QUEUE];
    if (eventQueueData) {
        eventQueue = [NSKeyedUnarchiver unarchiveObjectWithData:eventQueueData];
    }
    if (!eventQueue || eventQueue.count == 0) {
        return YES;
    }
    
    NSError *error;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:eventQueue options:0 error:&error];
    
    NSLog(@"JSON summary: %@", [[NSString alloc] initWithData:postData
                                                     encoding:NSUTF8StringEncoding]);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:JSON_BASE_URL_POST_EVENTS]];
    [request setHTTPMethod:@"POST"];

    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:postData];
    
    [NSURLConnection connectionWithRequest:request delegate:self];
    if (error) {
        return NO;
    }
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULTS_NEWS_READING_EVENT_QUEUE];
    
    return YES;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if(self = [super init])
    {
        _identifier = [decoder decodeObjectForKey:@"identifier"];
        _articleId = [decoder decodeObjectForKey:@"articleId"];
        _userId = [decoder decodeObjectForKey:@"userId"];
        _eventType = [decoder decodeObjectForKey:@"eventType"];
        _timeStamp = [decoder decodeObjectForKey:@"timeStamp"];
        _geoLocation = [decoder decodeObjectForKey:@"geoLocation"];
        _properties = [decoder decodeObjectForKey:@"properties"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_identifier forKey:@"identifier"];
    [encoder encodeObject:_articleId forKey:@"articleId"];
    [encoder encodeObject:_userId forKey:@"userId"];
    [encoder encodeObject:_eventType forKey:@"eventType"];
    [encoder encodeObject:_timeStamp forKey:@"timeStamp"];
    [encoder encodeObject:_geoLocation forKey:@"geoLocation"];
    [encoder encodeObject:_properties forKey:@"properties"];
}

@end
