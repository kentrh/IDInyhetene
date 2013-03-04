//
//  NewsCategory.h
//  KongroNews
//
//  Created by Kent Robin Haugen on 02.03.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsCategory : NSObject

@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) int tag;

- (id)initWithName:(NSString *)name displayName:(NSString *)displayName tag:(int)tag url:(NSString *)url;

@end
