//
//  DateUtils.h
//
//  Copyright (c) 2015 Salt Edge. https://saltedge.com
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

#import <Foundation/Foundation.h>

/**
 DateUtils is a class containing utility methods for serializing dates strings from Salt Edge entities returned from API calls.
 */
@interface DateUtils : NSObject

/**
 Converts a ISO 8601 date string into an NSDate object.
 
 @param dateString The ISO 8601 formatted date string.
 @return The NSDate equivalent of the date string parameter.
 @see http://en.wikipedia.org/wiki/ISO_8601
 */
+ (NSDate*)dateFromISO8601String:(NSString*)dateString;

/**
 Converts a Year-Month-Day date string into an NSDate object.

 @param dateString The YYYY-MM-DD formatted date string.
 @return The NSDate equivalent of the date string parameter.
 */
+ (NSDate*)dateFromYMDString:(NSString*)dateString;

/**
 Converts a NSDate object into a YYYY-MM-DD formatted date string.

 @param date The date object which will be converted into a string.
 @return The YYYY-MM-DD string equivalent of the date object parameter.
 */
+ (NSString*)YMDStringFromDate:(NSDate*)date;

@end
