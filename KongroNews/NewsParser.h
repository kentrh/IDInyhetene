//
//  NewsParser.h
//  KongroNews
//
//  Created by Kent Robin Haugen on 19.02.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NewsCategory.h"

@interface NewsParser : NSObject

+ (NSArray *)newsListFromCategoryTag:(int)categoryTag shouldUpdate:(BOOL)shouldUpdate;

+ (NSArray *)categories;

+ (int)numberOfNewsFromTag:(int)tag;

+ (NSString *)lastViewedArticleByCategoryTag:(int)tag;
+ (void)setLastViewedArticleByCategoryTag:(int)tag lastViewedArticleUrlString:(NSString *)lastArticleUrlString;

+ (NewsCategory *)newsCategoryFromTag:(int)tag;

+ (NSArray *)queryResult:(NSString *)queryUrl;

@end
