//
//  HelpMethods.m
//  KongroNews
//
//  Created by Kent Robin Haugen on 27.02.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import "HelpMethods.h"
#import "Constants.h"

@implementation HelpMethods

+ (NSString *)randomLoadText
{
    NSArray *randomTexts = [NSArray arrayWithObjects:
                            @"To sek bare",
                            @"Snart der..",
                            @"Sjill to, k?",
                            @"I'm loading",
                            @"Please hold",
                            @"Laddar",
                            @"Hold an",
                            @"Very soon",
                            @"Incoming data",
                            @"Shh, hør..",
                            @"Venta lite",
                            @"Incoming",
                            @"Chewing bytes",
                            @"Bitrain",
                            @"Et lite blikk",
                            nil];
    
    int index = arc4random() % [randomTexts count];
    return [randomTexts objectAtIndex:index];
}
@end
