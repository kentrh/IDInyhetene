//
//  NewsParser.h
//  KongroNews
//
//  Created by Kent Robin Haugen on 19.02.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface NewsParser : NSObject

//Array with similar News to articleId
+ (NSArray *)similarNewsWithUserId:(NSString *)userId articleId:(int)articleId location:(CLLocationCoordinate2D)location;

//Array with relevant News
+ (NSArray *)relevantNewsWithUserId:(NSString *)userId location:(CLLocationCoordinate2D)location shouldUpdate:(BOOL)shouldUpdate;

//Array with relevant News by search query
+ (NSArray *)relevantNewsWithUserId:(NSString *)userId location:(CLLocationCoordinate2D)location query:(NSString *)query;

//Array with relevant News by category
+ (NSArray *)relevantNewsWithUserId:(NSString *)userId location:(CLLocationCoordinate2D)location category:(NSString *)category shouldUpdate:(BOOL)shouldUpdate;

+ (int)numberOfArticlesForCategory:(NSString *)category;

+ (int)numberOfUnseenArticlesByCategory:(NSString *)newsCategory;

//Array with available categories
+ (NSArray *)availableCategories;

+ (int)lastViewedArticleByCategory:(NSString *)category;

+ (void)setLastViewedArticleByCategory:(NSString *)category lastViewedArticleId:(int)lastArticleId;

@end
