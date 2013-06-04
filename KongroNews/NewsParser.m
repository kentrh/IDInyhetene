//
//  NewsParser.m
//  KongroNews
//
//  Created by Kent Robin Haugen on 19.02.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import "NewsParser.h"
#import "News.h"
#import "NSString+HTML.h"
#import "GeoLocation.h"
#import "Constants.h"
#import "NewsReadingEvent.h"

//(NSString *)userId (float)latitude (float)longitude
#define JSON_BASE_URL_RELEVANT_NEWS @"http://vm-6120.idi.ntnu.no/news-rec-service/getRelevantNews?userId=%@&geoLocation=%f,%f"
//(NSString *)userId (int)articleId (float)latitude (float)longitude
#define JSON_BASE_URL_SIMILAR_NEWS @"http://vm-6120.idi.ntnu.no/news-rec-service/getMoreLikeThis?userId=%@&articleId=%d&geoLocation=%f,%f"
//(NSString *)userId (float)latitude (float)longitude (NSString *)category
#define JSON_BASE_URL_CATEGORY_NEWS @"http://vm-6120.idi.ntnu.no/news-rec-service/getRelevantNews?userId=%@&geoLocation=%f,%f&categoryQuery=[\"%@\"]"
//(NSString *)userId (float)latitude (float)longitude (NSString *)query
#define JSON_BASE_URL_QUERY_NEWS @"http://vm-6120.idi.ntnu.no/news-rec-service/getRelevantNews?userId=%@&geoLocation=%f,%f&contentQuery=[\"%@\"]"

@implementation NewsParser

static NSMutableArray *categories;
static NSMutableDictionary *numberOfNews;

+ (NSArray *)relevantNewsWithUserId:(NSString *)userId location:(CLLocationCoordinate2D)location shouldUpdate:(BOOL)shouldUpdate
{
    NSArray *newsList;
    if (!shouldUpdate) {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:CATEGORY_RELEVANT_NEWS];
        if (data) {
            newsList = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
    }
    
    if (!newsList || newsList.count == 0 || shouldUpdate)
    {
        NSLog(@"lat: %f, long: %f", location.latitude, location.longitude);
        NSString *urlString = [NSString stringWithFormat:JSON_BASE_URL_RELEVANT_NEWS, userId, location.latitude, location.longitude];
        urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *queryUrl = [NSURL URLWithString:urlString];
        
        NSData *newsData = [NewsParser executeQueryWithUrl:queryUrl];
        if (!newsData) return nil;
        
        newsList = [NewsParser newsArrayWithData:newsData];
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:newsList];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:CATEGORY_RELEVANT_NEWS];
        
        //Flush NewsReadingEvents
        [NewsReadingEvent postEventQueue];
    }
    
    if (!numberOfNews) numberOfNews = [[NSMutableDictionary alloc] initWithCapacity:categories.count];
    NSNumber *newsCount = [NSNumber numberWithInt:newsList.count];
    [numberOfNews setObject:newsCount forKey:CATEGORY_RELEVANT_NEWS];
    
    return newsList;
}

+ (NSArray *)relevantNewsWithUserId:(NSString *)userId location:(CLLocationCoordinate2D)location query:(NSString *)query
{
    NSString *urlString = [NSString stringWithFormat:JSON_BASE_URL_QUERY_NEWS, userId, location.latitude, location.longitude, query];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *queryUrl = [NSURL URLWithString:urlString];
    
    NSData *newsData = [NewsParser executeQueryWithUrl:queryUrl];
    if (!newsData) return nil;
    
    NSArray *queryArray = [NewsParser newsArrayWithData:newsData];
    return queryArray;
}

+ (NSArray *)relevantNewsWithUserId:(NSString *)userId location:(CLLocationCoordinate2D)location category:(NSString *)category shouldUpdate:(BOOL)shouldUpdate
{
    NSArray *newsList;
    if (!shouldUpdate) {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:category];
        if (data) {
            newsList = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
    }
    
    if (!newsList || newsList.count == 0 || shouldUpdate)
    {
        NSString *urlString = [NSString stringWithFormat:JSON_BASE_URL_CATEGORY_NEWS, userId, location.latitude, location.longitude, category];
        urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *queryUrl = [NSURL URLWithString:urlString];
        
        NSData *newsData = [NewsParser executeQueryWithUrl:queryUrl];
        if (!newsData) return nil;
        
        newsList = [NewsParser newsArrayWithData:newsData];
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:newsList];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:category];
    }
    
    if (!numberOfNews) numberOfNews = [[NSMutableDictionary alloc] initWithCapacity:categories.count];
    NSNumber *newsCount = [NSNumber numberWithInt:newsList.count];
    [numberOfNews setObject:newsCount forKey:category];
    
    return newsList;
}

+ (int)numberOfArticlesForCategory:(NSString *)category
{
    if ([category isEqualToString:CATEGORY_FAVORITE_NEWS]) {
        NSArray *newsArray;
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_STARRED_ARTICLES];
        if (data) {
            newsArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
        return newsArray.count;
    }
    NSNumber *number = (NSNumber *)[numberOfNews objectForKey:category];
    int num = number.intValue;
    return num;
}

+ (int)numberOfUnseenArticlesByCategory:(NSString *)newsCategory
{
    NSArray *newsList;
    if ([newsCategory isEqualToString:CATEGORY_FAVORITE_NEWS]) {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_STARRED_ARTICLES];
        if (data) {
            newsList = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
        return newsList.count;
    }
    
    int articleIdOfLastViewedArticle = [NewsParser lastViewedArticleByCategory:newsCategory];
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:newsCategory];
    if (data) {
        newsList = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    int numberOfUnseenNews = newsList.count;
    for (int i=0; i<newsList.count; i++) {
        News *newsArticle = [newsList objectAtIndex:i];
        if (newsArticle.articleId == articleIdOfLastViewedArticle) {
            numberOfUnseenNews = i;
            break;
        }
    }
    return numberOfUnseenNews;
}

+ (NSArray *)similarNewsWithUserId:(NSString *)userId articleId:(int)articleId location:(CLLocationCoordinate2D)location
{
    NSString *urlString = [NSString stringWithFormat:JSON_BASE_URL_SIMILAR_NEWS, userId, articleId, location.latitude, location.longitude];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *queryUrl = [NSURL URLWithString:urlString];
    
    NSData *newsData = [NewsParser executeQueryWithUrl:queryUrl];
    if (!newsData) return nil;
    
    NSArray *newsArray = [NewsParser newsArrayWithData:newsData];
    
    return newsArray;
}

+ (int)lastViewedArticleByCategory:(NSString *)category
{
    NSMutableDictionary *previousArticles;
    NSData *previousArticlesData = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_PREVIOUS_ARTICLE];
    if (previousArticlesData) {
        previousArticles = [NSKeyedUnarchiver unarchiveObjectWithData:previousArticlesData];
    }
    NSNumber *articleIdNumber = [previousArticles objectForKey:category];
    int articleId = [articleIdNumber integerValue];
    return articleId;
}

+ (void)setLastViewedArticleByCategory:(NSString *)category lastViewedArticleId:(int)lastArticleId
{
    NSMutableDictionary *previousArticles;
    NSData *previousArticlesData = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_PREVIOUS_ARTICLE];
    if (previousArticlesData) {
        previousArticles = [NSKeyedUnarchiver unarchiveObjectWithData:previousArticlesData];
    }
    else previousArticles = [[NSMutableDictionary alloc] initWithCapacity:categories.count];
    NSNumber *articleId = [NSNumber numberWithInt:lastArticleId];
    [previousArticles setObject:articleId forKey:category];
    
    previousArticlesData = [NSKeyedArchiver archivedDataWithRootObject:previousArticles];
    [[NSUserDefaults standardUserDefaults] setObject:previousArticlesData forKey:USER_DEFAULTS_PREVIOUS_ARTICLE];
}


+ (NSArray *)availableCategories
{
    return categories;
}

+ (NSData *)executeQueryWithUrl:(NSURL *)queryUrl
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:queryUrl];
    NSURLResponse *response;
    NSError *error;
    NSData *newsData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (newsData == nil || (error != nil && [error code] != noErr)) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Nyhetsdata kunne ikke hentes" delegate:nil cancelButtonTitle:@"Lukk" otherButtonTitles: nil];
        [alertView show];
        return nil;
    }
    return newsData;
}

+ (NSArray *)newsArrayWithData:(NSData *)newsData
{
    NSError *error;
    NSArray *jsonData = [NSJSONSerialization JSONObjectWithData:newsData options:kNilOptions error:&error];
    
    NSMutableArray *newsArray = [[NSMutableArray alloc] init];
    for (NSDictionary *newsArticle in jsonData) {
        News *news = [NewsParser newsArticleFromDictionary:newsArticle];
        if (news.title.length == 0 || news.leadText.length == 0 || news.bodyText.length == 0) {
            continue;
        }
        [newsArray addObject:news];
    }
    return [NSArray arrayWithArray:newsArray];
}

+ (News *)newsArticleFromDictionary:(NSDictionary *)newsArticle
{
    int articleId = [[newsArticle objectForKey:@"articleId"] integerValue];
    
    NSString *title = [newsArticle objectForKey:@"title"];
    title = [title stringByConvertingHTMLToPlainText];
    title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *leadText = [newsArticle objectForKey:@"leadText"];
    leadText = [leadText stringByConvertingHTMLToPlainText];
    leadText = [leadText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *bodyText = [newsArticle objectForKey:@"bodyText"];
    bodyText = [bodyText stringByConvertingHTMLToPlainText];
//    bodyText = [bodyText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *publisher = [newsArticle objectForKey:@"publisher"];
    
    NSString *author = [newsArticle objectForKey:@"author"];
    double time = [[newsArticle objectForKey:@"published"] doubleValue];
    NSDate *published = [NSDate dateWithTimeIntervalSince1970:time/1000.0f];
    
    NSArray *tags = [newsArticle objectForKey:@"tags"];
    
    NSArray *categoryStrings = [newsArticle objectForKey:@"categories"];
    [NewsParser addCategoryToCategories:categoryStrings];
    
    
    NSArray *images = [newsArticle objectForKey:@"images"];
    NSMutableArray *imageUrls = [[NSMutableArray alloc] init];
    if (images && ![images isEqual:[NSNull null]]) {
        for (NSString *urlString in images) {
            NSURL *url = [NSURL URLWithString:urlString];
            [imageUrls addObject:url];
        }
    }
    
    NSString *sourceUrlString = [[newsArticle objectForKey:@"sourceUrl"] objectAtIndex:0];
    NSURL *sourceUrl = [NSURL URLWithString:sourceUrlString];
    
    NSArray *locations = [newsArticle objectForKey:@"locations"];
    NSMutableArray *tempLocations = [[NSMutableArray alloc] init];
    if (locations && ![locations isEqual:[NSNull null]]) {
        for (NSString *location in locations) {
            float latitude = [[[location componentsSeparatedByString:@","] objectAtIndex:0] floatValue];
            float longitude = [[[location componentsSeparatedByString:@","] lastObject] floatValue];
            GeoLocation *loc = [[GeoLocation alloc] initWithLatitude:latitude longitude:longitude];
            [tempLocations addObject:loc];
        }
    }
    
    NSArray *geoLocations = [newsArticle objectForKey:@"geoLocations"];
    NSMutableArray *tempGeoLocations = [[NSMutableArray alloc] init];
    if (geoLocations && ![geoLocations isEqual:[NSNull null]])
    {
        for (NSDictionary *geoLocation in geoLocations) {
            GeoLocation *location = [[GeoLocation alloc] initWithLatitude:[[geoLocation objectForKey:@"latitude"] floatValue] longitude:[[geoLocation objectForKey:@"longitude"] floatValue] nameOfLocation:[geoLocation objectForKey:@"name"]];
            [tempGeoLocations addObject:location];
        }
    }
    
    float sentimentValue = [[newsArticle objectForKey:@"sentimentValue"] floatValue];
    
    News *news = [[News alloc]
                  initWithArticleId:articleId
                  title:title
                  leadText:leadText
                  bodyText:bodyText
                  publisher:publisher
                  author:author
                  published:published
                  tags:tags
                  categories:categoryStrings
                  images:[NSArray arrayWithArray:imageUrls]
                  sourceUrl:sourceUrl
                  locations:[NSArray arrayWithArray:tempLocations]
                  geoLocations:[NSArray arrayWithArray:tempGeoLocations]
                  sentimentValue:sentimentValue];
    
    return news;
}

+ (void)makeCategoriesUnique
{
    NSArray *a = [NSArray arrayWithArray:categories];
    NSMutableArray *unique = [NSMutableArray array];
    NSMutableSet *processed = [NSMutableSet set];
    for (NSString *string in a) {
        if ([processed containsObject:string] == NO) {
            [unique addObject:string];
            [processed addObject:string];
        }
    }
    categories = unique;
}

+ (void)addCategoryToCategories:(NSArray *)categoryStrings
{
    if (!categories) {
        categories = [[NSMutableArray alloc] initWithObjects:CATEGORY_FAVORITE_NEWS, CATEGORY_RELEVANT_NEWS, nil];
    }
    for (NSString *cat in categoryStrings) {
        [categories addObject:cat];
    }
    [NewsParser makeCategoriesUnique];
}
@end
