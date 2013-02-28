//
//  News.h
//  KongroNews
//
//  Created by Kent Robin Haugen on 19.02.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface News : NSObject <NSCoding>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *leadText;
@property (nonatomic, strong) NSURL *link;
@property (nonatomic, strong) NSDate *pubDate;
@property (nonatomic, strong) NSString *imageType;
@property (nonatomic, strong) NSURL *imageUrl;

- (id)initWithTitle:(NSString *)title leadText:(NSString *)leadText link:(NSURL *)link pubDate:(NSDate *)pubDate imageType:(NSString *)imageType imageUrl:(NSURL *)imageUrl;

@end
