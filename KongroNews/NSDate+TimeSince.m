//
//  NSDate+TimeSince.m
//  KongroNews
//
//  Created by Kent Robin Haugen on 03.03.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import "NSDate+TimeSince.h"

@implementation NSDate (TimeSince)

- (NSString *)timeSinceFromDate
{
    NSTimeInterval timeDiff = [[NSDate date] timeIntervalSinceDate:self];
    int time = (int) timeDiff;
    int minutes = ((time / 60) % 60);
    int hours = (time / 3600);
    
    NSString *entallFlertallMinutter = minutes == 1 ? @"minutt" : @"minutter";
    NSString *entallFlertallTimer = hours == 1 ? @"time" : @"timer";
    
    NSString *timeSinceText;
    if (hours == 0) {
        timeSinceText = [NSString stringWithFormat:@"%d %@ siden", minutes, entallFlertallMinutter];
    }
    else if (hours == 1 || hours == 2) {
        timeSinceText = [NSString stringWithFormat:@"%d %@ og %d %@ siden", hours, entallFlertallTimer, minutes, entallFlertallMinutter];
    }
    else if (hours <= 23) {
        timeSinceText = [NSString stringWithFormat:@"%d %@ siden", hours, entallFlertallTimer];
    }
    else if (hours <= 48) {
        timeSinceText = [NSString stringWithFormat:@"1 dag siden"];
    }
    else if (hours <= 72) {
        timeSinceText = @"2 dager siden";
    }
    else if (hours <= 96) {
        timeSinceText = @"3 dager siden";
    }
    else if (hours <= 120) {
        timeSinceText = @"4 dager siden";
    }
    else if (hours <= 144) {
        timeSinceText = @"5 dager siden";
    }
    else if (hours <= 168) {
        timeSinceText = @"6 dager siden";
    }
    else if (hours <= 192) {
        timeSinceText = @"7 dager siden";
    }
    else {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"EEE d MMM y"];
        
        timeSinceText = [formatter stringFromDate:self];
    }
    
    return timeSinceText;
}

@end
