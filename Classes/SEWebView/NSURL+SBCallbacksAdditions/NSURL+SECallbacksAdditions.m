//
//  NSURL+SECallbacksAdditions.m
//
//  Copyright (c) 2014 Salt Edge. https://saltedge.com
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

#import "NSURL+SECallbacksAdditions.h"

@implementation NSURL (SECallbacksAdditions)

- (BOOL)se_isCallbackURL
{
    return [self.scheme isEqualToString:SECallbackScheme] && [self.host isEqualToString:SECallbackHost];
}

- (NSDictionary*)se_callbackParametersWithError:(NSError**)error
{
    if (!self.se_isCallbackURL) { return nil; }
    NSString* jsonString = [self.path substringFromIndex:1];
    if (!jsonString.length) { return nil; }
    NSData* jsonStringData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:jsonStringData options:0 error:error];
}

@end
