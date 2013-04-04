//
//  NewsReadingEvent.h
//  KongroNews
//
//  Created by Kent Robin Haugen on 02.04.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GeoLocation.h"

#define NewsReadingEventOpenedArticleView @"OPENED_ARTICLE_VIEW"
#define NewsReadingEventTimeSpentPreview @"TIME_SPENT_PREVIEW"
#define NewsReadingEventTimeSpentArticleView @"TIME_SPENT_ARTICLE_VIEW"
#define NewsReadingEventClickedCategory @"CLICKED_CATEGORY"
#define NewsReadingEventSharedTwitter @"SHARED_TWITTER"
#define NewsReadingEventSharedFacebook @"SHARED_FACEBOOK"
#define NewsReadingEventSharedMail @"SHARED_MAIL"
#define NewsReadingEventStarredArticle @"STARRED_ARTICLE"
#define NewsReadingEventViewedMap @"VIEWED_MAP"
#define NewsReadingEventViewedEntityView @"VIEWED_ENTITY_VIEW"
#define NewsReadingEventClickedEntity @"CLICKED_ENTITY"
#define NewsReadingEventViewedSimilarArticle @"VIEWED_SIMILAR_ARTICLE"

@interface NewsReadingEvent : NSObject

@property (strong, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSString *articleId;
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *eventType;
@property (strong, nonatomic) NSDate *timeStamp;
@property (strong, nonatomic) GeoLocation *geoLocation;
@property (strong, nonatomic) NSDictionary *properties;

- (id)initWithGlobalIdentifier:(NSString *)identifier articleId:(NSString *)articleId userId:(NSString *)userId eventType:(NSString *)eventType timeStamp:(NSDate *)timeStamp geoLocation:(GeoLocation *)geoLocation properties:(NSDictionary *)properties;

+ (void)addEventToQueue:(NewsReadingEvent *)event;

+ (BOOL)postEventQueue;

@end
