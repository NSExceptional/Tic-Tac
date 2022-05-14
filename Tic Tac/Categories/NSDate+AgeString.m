//
//  NSDate+AgeString.m
//  Tic Tac
//
//  Created by Tanner on 5/1/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "NSDate+AgeString.h"
#import "NSDate-Utilities.h"


static NSDateFormatter *formatter;
static NSString * const kTwoWeeksOrMoreFormat = @"MMM d, yyyy, h:m a";
static NSString * const kOneDayOrMoreFormat = @"d 'days', H 'hours ago'";
static NSString * const kOneDayOrLessFormat = @"H \'hours,\' m \'min ago\'";
static NSString * const kHourOrLessFormat = @"m 'minutes ago'";

@implementation NSDate (AgeString)

- (NSString *)relativeTimeString {
    if (!formatter) {
        formatter = [NSDateFormatter new];
        formatter.dateFormat = kHourOrLessFormat;
    }
    
    NSInteger hours = [self hoursBeforeDate:NSDate.date];
    if (hours >= 337) {
        formatter.dateFormat = kTwoWeeksOrMoreFormat;
        return [formatter stringFromDate:self];
    } else if (hours >= 24) {
        return [self daysAgo];
    } else if (hours == 0) {
        return [self minutesAgo];
    } else {
        return [self hoursAgo];
    }
}

- (NSString *)minutesAgo {
    NSInteger minutes = [self minutesBeforeDate:NSDate.date];
    if (minutes == 1) {
        return @"1m";
    }
    
    return [@(minutes).stringValue stringByAppendingString:@"m"];
}

- (NSString *)hoursAgo {
    NSDate *now = [NSDate date];
    NSInteger hours   = [self hoursBeforeDate:now];
    NSInteger minutes = [self minutesBeforeDate:now] - 60*hours;
    
    NSString *ret;
    
    if (hours == 1) {
        ret = @"1h";
    } else {
        ret = [@(hours).stringValue stringByAppendingString:@"h"];
    }
    
    if (minutes == 1) {
        return [ret stringByAppendingString:@", 1m"];
    } else if (minutes > 1) {
        return [NSString stringWithFormat:@"%@, %@m", ret, @(minutes).stringValue];
    } else {
        return ret;
    }
}

- (NSString *)daysAgo {
    NSDate *now     = [NSDate date];
    NSInteger days  = [self daysBeforeDate:now];
    NSInteger hours = [self hoursBeforeDate:now] - days*24;
    // Round up an hour
    hours += ([self minutesBeforeDate:now] - hours*60) >= 30 ? 1 : 0;
    
    NSString *ret;
    
    if (days == 1) {
        ret = @"1d";
    } else {
        ret = [@(days).stringValue stringByAppendingString:@"d"];
    }
    
    if (hours == 1) {
        return [ret stringByAppendingString:@", 1h"];
    } else if (hours > 1) {
        return [NSString stringWithFormat:@"%@, %@h", ret, @(hours).stringValue];
    } else {
        return ret;
    }
}

@end
