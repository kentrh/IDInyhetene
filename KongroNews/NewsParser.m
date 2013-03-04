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
#import <Parse/Parse.h>
#import "NewsCategory.h"

@implementation NewsParser

static NSArray *newsList;
static NSString *currentQuery;
static NSArray *categoryList;

+ (NSArray *) newsList:(NSString *)queryString shouldUpdate:(BOOL)shouldUpdate
{
    if (!newsList || newsList.count == 0 || ![queryString isEqualToString:currentQuery] || shouldUpdate)
    {
        newsList = nil;
        NSURL *url = [NSURL URLWithString:queryString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSURLResponse *response;
        NSError *error;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (data == nil || (error != nil && [error code] != noErr)) {
            // If there was a no data received, or an error...
            NSLog(@"Error fetching json");
            NSLog(@"URL: %@", queryString);
            //            dispatch_async(dispatch_get_main_queue(), ^{
            //
            //            });
        } else {
            // Handle the data
            NSError *error;
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            NSDictionary *queryResponse = [jsonData objectForKey:@"value"];
            NSMutableArray *unsortedArray = [[NSMutableArray alloc] init];
            
            for (NSDictionary *singleNews in [queryResponse objectForKey:@"items"]) {
                NSString *title = [singleNews objectForKey:@"title"];
                NSString *leadText = [singleNews objectForKey:@"description"];
                NSString *tempLink = [singleNews objectForKey:@"link"];
                NSString *date = [singleNews objectForKey:@"pubDate"];
                NSString *publisher = [singleNews objectForKey:@"author"];
                if (!title || !leadText || !link || !date || !publisher)
                {
                    continue;
                    
                }
                
                if ([title isEqual:[NSNull null]] || [leadText isEqual:[NSNull null]] || [date isEqual:[NSNull null]] || [tempLink isEqual:[NSNull null]] || [publisher isEqual:[NSNull null]]) {
                    continue;
                }
                NSURL *link = [NSURL URLWithString:tempLink];
                title = [title stringByConvertingHTMLToPlainText];
                leadText = [leadText stringByConvertingHTMLToPlainText];
                
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                if (date.length == 31){
                    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"]];
                    [formatter setDateFormat:@"EEE, d MMM y HH:mm:ss Z"];
                }
                else if (date.length == 22){
                    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"]];
                    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mmZZZZ"];
                }
                else if (date.length == 25){
                    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"]];
                    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
//                    date = [date stringByReplacingOccurrencesOfString:@"+02:00" withString:@"+01:00"];
                }
                else if (date.length == 16){
                    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"]];
                    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
                }
                else if (date.length == 29){
                    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"]];
                    [formatter setDateFormat:@"EEE, d MMM y HH:mm:ss Z"];
                }
                else if (date.length == 19){
                    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"]];
                    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                }
                else if (date.length == 21){
                    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"]];
                    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.S"];
                }
                else if (date.length == 30){
                    //Sun, 3 Mar 2013 16:35:45 +0100
                    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"]];
                    [formatter setDateFormat:@"EEE, d MMM y HH:mm:ss Z"];
                }
                else {
                    NSLog(@"%@",title);
                }
                NSDate *pubDate = [formatter dateFromString:date];
//                [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
//                NSString *tempDate = [formatter stringFromDate:pubDate];
//                pubDate = [formatter dateFromString:tempDate];
                
                NSDictionary *enclosure = [singleNews objectForKey:@"enclosure"];
                NSString *imageType = [enclosure objectForKey:@"type"];
                NSString *tempUrl = [enclosure objectForKey:@"url"];
                NSURL *imageUrl = [[NSURL alloc] init];
                if (![tempUrl isEqual:[NSNull null]] && tempUrl) {
                    imageUrl = [NSURL URLWithString:tempUrl];
                }
                
                News *news = [[News alloc] initWithTitle:title leadText:leadText link:link pubDate:pubDate imageType:imageType imageUrl:imageUrl publisher:publisher];
                
                [unsortedArray addObject:news];
            }
            newsList = [unsortedArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return [[(News *)obj2 pubDate] compare:[(News *)obj1 pubDate]];
            }];
        }
    }
    currentQuery = queryString;
    return newsList;
}

+ (NSArray *) categories
{
    if (!categoryList) {
        PFQuery *query = [PFQuery queryWithClassName:@"Categories"];
        NSError *error;
        NSArray *categories = [query findObjects:(&error)];
        if(!error)
        {
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:[categories count]];
            for (PFObject *category in categories) {
                
                NewsCategory *newsCategory = [[NewsCategory alloc] initWithName:[category objectForKey:@"name"] displayName:[category objectForKey:@"displayName"] tag:[[category objectForKey:@"tag"] intValue] url:[category objectForKey:@"url"]];
                [tempArray addObject:newsCategory];
            }
            categoryList = [tempArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                NSNumber *one = [[NSNumber alloc] initWithInt:[(NewsCategory *)obj1 tag]];
                NSNumber *two = [[NSNumber alloc] initWithInt:[(NewsCategory *)obj2 tag]];
                return [one compare:two];
            }];
        }
    }
    return categoryList;
}

@end
