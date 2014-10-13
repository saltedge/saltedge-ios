//
//  SERequestHandler.m
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

#import "SERequestHandler.h"
#import "SEError.h"

static NSString* const kRequestMethodPOST   = @"POST";
static NSString* const kRequestMethodGET    = @"GET";
static NSString* const kRequestMethodDELETE = @"DELETE";

typedef NS_ENUM(NSInteger, SERequestMethod) {
    SERequestMethodPOST,
    SERequestMethodGET,
    SERequestMethodDELETE
};

@interface SERequestHandler (/* Private */)

@property (nonatomic, copy) SERequestHandlerFailureBlock successBlock;
@property (nonatomic, copy) SERequestHandlerFailureBlock failureBlock;

@end

@implementation SERequestHandler

#pragma mark -
#pragma mark - Public API

+ (void)sendPOSTRequestWithURL:(NSString*)url
                    parameters:(NSDictionary*)parameters
                       headers:(NSDictionary*)headers
                       success:(SERequestHandlerSuccessBlock)success
                       failure:(SERequestHandlerFailureBlock)failure
{
    [[self handler] sendRequest:SERequestMethodPOST withURL:url parameters:parameters headers:headers success:success failure:failure];
}

+ (void)sendGETRequestWithURL:(NSString*)url
                   parameters:(NSDictionary*)parameters
                      headers:(NSDictionary*)headers
                      success:(SERequestHandlerSuccessBlock)success
                      failure:(SERequestHandlerFailureBlock)failure
{
    [[self handler] sendRequest:SERequestMethodGET withURL:url parameters:parameters headers:headers success:success failure:failure];
}

+ (void)sendDELETERequestWithURL:(NSString*)url
                      parameters:(NSDictionary*)parameters
                         headers:(NSDictionary*)headers
                         success:(SERequestHandlerSuccessBlock)success
                         failure:(SERequestHandlerFailureBlock)failure
{
    [[self handler] sendRequest:SERequestMethodDELETE withURL:url parameters:parameters headers:headers success:success failure:failure];
}

#pragma mark -
#pragma mark - Private API

+ (SERequestHandler*)handler
{
    return [[SERequestHandler alloc] init];
}

+ (NSOperationQueue*)requestOperationQueue
{
    static NSOperationQueue* operationQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        operationQueue = [[NSOperationQueue alloc] init];
    });
    return operationQueue;
}

- (void)sendRequest:(SERequestMethod)method
            withURL:(NSString*)url
         parameters:(NSDictionary*)parameters
            headers:(NSDictionary*)headers
            success:(SERequestHandlerSuccessBlock)success
            failure:(SERequestHandlerFailureBlock)failure
{
    if (url.length == 0) {
        if (failure) {
            failure(@{ @"error_class": @"EmptyURLError",
                       @"message": @"Cannot send a request to empty URL.",
                       @"request": @{ @"parameters" : parameters ? parameters : [NSNull null] }
                       });
        }
        return;
    }

    self.successBlock = success;
    self.failureBlock = failure;

    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = [self stringForMethod:method];

    for (NSString* header in headers) {
        [request setValue:headers[header] forHTTPHeaderField:header];
    }

    if (parameters) {
        if (![self handleParameters:parameters assignmentInRequest:request]) {
            return;
        }
    }

    [NSURLConnection sendAsynchronousRequest:request queue:[[self class] requestOperationQueue] completionHandler:^(NSURLResponse* response, NSData* data, NSError* connectionError) {
        NSInteger statusCode = [(NSHTTPURLResponse*)response statusCode];
        if (connectionError || !(statusCode >= 200 && statusCode < 300)) {
            if (failure) {
                self.failureBlock(@{ @"error_class": connectionError.domain,
                                     @"message": connectionError.localizedDescription,
                                     @"request": request
                                     });
            }
        } else {
            if (success) {
                NSError* error;
                NSDictionary* responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                if (error) {
                    if (failure) {
                        failure(@{ @"error_class": @"NSJSONSerializationError",
                                   @"message": @"Could not serialize request parameters",
                                   @"request": request
                                   });
                    }
                } else {
                    success(responseObject);
                }
            }
        }
    }];
}

- (NSString*)stringForMethod:(SERequestMethod)method
{
    switch (method) {
        case SERequestMethodPOST: {
            return kRequestMethodPOST;
        }
        case SERequestMethodGET: {
            return kRequestMethodGET;
        }
        case SERequestMethodDELETE: {
            return kRequestMethodDELETE;
        }
    }
}

- (BOOL)handleParameters:(NSDictionary*)parameters
     assignmentInRequest:(NSMutableURLRequest*)request
{
    if ([[self HTTPMethodsWithoutBody] containsObject:[request.HTTPMethod uppercaseString]]) {
        NSString* query = [self urlQueryFormatForParameters:parameters];
        request.URL = [NSURL URLWithString:[request.URL.absoluteString stringByAppendingFormat:request.URL.query ? @"&%@" : @"?%@", query]];
    } else {
        NSError* error;
        NSData* data = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error];
        if (error) {
            if (self.failureBlock) {
                self.failureBlock(@{ @"error_class": @"NSJSONSerializationError",
                                     @"message": @"Could not serialize request parameters",
                                     @"request": parameters
                                     });
            }
            return NO;
        }
        request.HTTPBody = data;
    }
    return YES;
}

- (NSString*)urlQueryFormatForParameters:(NSDictionary*)parameters
{
    NSMutableArray* parameterStrings = [NSMutableArray array];
    for (NSString* parameterKey in parameters) {
        [parameterStrings addObject:[NSString stringWithFormat:@"%@=%@", parameterKey, parameters[parameterKey]]];
    }
    return [parameterStrings componentsJoinedByString:@"&"];
}

- (NSArray*)HTTPMethodsWithoutBody
{
    return @[kRequestMethodGET, kRequestMethodDELETE];
}

@end
