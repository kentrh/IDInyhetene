//
//  News.h
//  KongroNews
//
//  Created by Kent Robin Haugen on 19.02.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface News : NSObject

@property (assign, nonatomic) int articleId;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *leadText;
@property (strong, nonatomic) NSString *bodyText;
@property (strong, nonatomic) NSString *publisher;
@property (strong, nonatomic) NSString *author;
@property (strong, nonatomic) NSDate *published;
@property (strong, nonatomic) NSArray *tags; //Array with NSString
@property (strong, nonatomic) NSArray *categories; //Array with NSString
@property (strong, nonatomic) NSArray *images; //Array with NSURL
@property (strong, nonatomic) NSURL *sourceUrl;
@property (strong, nonatomic) NSArray *locations;   //Array with GeoLocation where name = nil
@property (strong, nonatomic) NSArray *geoLocations; //Array with GeoLocation
@property (assign, nonatomic) float sentimentValue;

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
          sentimentValue:(float)sentimentValue;
@end
