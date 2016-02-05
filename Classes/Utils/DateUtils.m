//
//  DateUtils.m
//
//  Copyright (c) 2016 Salt Edge. https://saltedge.com
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "DateUtils.h"

static NSDateFormatter* iso8601DateFormatter, *ymdDateFormatter;

@implementation DateUtils

#pragma mark - Public API

+ (NSDate*)dateFromISO8601String:(NSString *)dateString
{
    return [[self iso8601DateFormatter] dateFromString:dateString];
}

+ (NSDate*)dateFromYMDString:(NSString *)dateString
{
    return [[self ymdDateFormatter] dateFromString:dateString];
}

+ (NSString*)YMDStringFromDate:(NSDate *)date
{
    return [[self ymdDateFormatter] stringFromDate:date];
}

#pragma mark - Private API, Singletons

+ (NSDateFormatter*)iso8601DateFormatter
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        iso8601DateFormatter = [[NSDateFormatter alloc] init];
        [iso8601DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
        NSTimeZone* tz = [NSTimeZone timeZoneWithName:@"UTC"];
        [iso8601DateFormatter setTimeZone:tz];
        [iso8601DateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
    });
    return iso8601DateFormatter;
}

+ (NSDateFormatter*)ymdDateFormatter
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ymdDateFormatter = [[NSDateFormatter alloc] init];
        [ymdDateFormatter setDateFormat:@"yyyy'-'MM'-'dd"];
        NSTimeZone* tz = [NSTimeZone timeZoneWithName:@"UTC"];
        [ymdDateFormatter setTimeZone:tz];
        [ymdDateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
    });
    return ymdDateFormatter;
}

@end
