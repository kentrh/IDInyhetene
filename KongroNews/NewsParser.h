//
//  NewsParser.h
//  KongroNews
//
//  Created by Kent Robin Haugen on 19.02.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsParser : NSObject

+ (NSArray *) newsList:(NSString *)queryString;

@end
