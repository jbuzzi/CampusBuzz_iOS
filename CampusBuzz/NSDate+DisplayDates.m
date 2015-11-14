//
//  NSDate+DisplayDates.m
//
//  Created by Jorge Buzzi on 12/10/14.
//  Copyright (c) 2014 Jorge Buzzi. All rights reserved.
//

#import "NSDate+DisplayDates.h"

@implementation NSDate (DisplayDates)

- (NSString *)timeAgo {
    double deltaSeconds = fabs([self timeIntervalSinceNow]);
    double deltaMinutes = deltaSeconds / 60.0f;
    if (deltaMinutes <= 2) {
        if ((int)deltaSeconds == 0) {
            return @"Now";
        } else {
            return [NSString stringWithFormat:@"%ds", (int)deltaSeconds];
        }
    }
    else if  ((deltaMinutes > 2) && (deltaMinutes < 60)) {
        return [NSString stringWithFormat:@"%dm", (int)deltaMinutes];
    }
    else if (deltaMinutes < 120) {
        return @"1h";
    }
    else if (deltaMinutes < (24 * 60)) {
        return [NSString stringWithFormat:@"%dh", (int)floor(deltaMinutes/60)];
    }
    else if (deltaMinutes > (24 * 60)) {
        if ((int)floor(deltaMinutes/(24*60) >= 365)) {
            return [NSString stringWithFormat:@"%dy", (int)floor(deltaMinutes/(24*60)/365)];
        } else {
            return [NSString stringWithFormat:@"%dd", (int)floor(deltaMinutes/(24*60))];
        }
    }
    NSDateFormatter *displayFormatter = [[NSDateFormatter alloc] init];
    [displayFormatter setDateStyle:NSDateFormatterShortStyle];
    [displayFormatter setTimeStyle:NSDateFormatterShortStyle];
    return [displayFormatter stringFromDate:self];
}


@end
