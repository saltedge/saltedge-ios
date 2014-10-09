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

static NSString* const kRequestMethodPOST   = @"POST";
static NSString* const kRequestMethodGET    = @"GET";
static NSString* const kRequestMethodDELETE = @"DELETE";

typedef NS_ENUM(NSInteger, SERequestMethod) {
    SERequestMethodPOST,
    SERequestMethodGET,
    SERequestMethodDELETE
};

@interface SERequestHandler (/* Private */) <NSURLConnectionDelegate>

@property (nonatomic) NSMutableData* responseData;
@property (nonatomic, copy) SERequestHandlerSuccessBlock successBlock;
@property (nonatomic, copy) SERequestHandlerFailureBlock failureBlock;

@end

@implementation SERequestHandler

#pragma mark -
#pragma mark - Public API

+ (void)sendPostRequestWithURL:(NSString*)url
                    parameters:(NSDictionary*)parameters
                       headers:(NSDictionary*)headers
                       success:(SERequestHandlerSuccessBlock)success
                       failure:(SERequestHandlerFailureBlock)failure
{
    [[self handler] sendRequest:SERequestMethodPOST withURL:url parameters:parameters headers:headers success:success failure:success];
}

+ (void)sendGetRequestWithURL:(NSString*)url
                   parameters:(NSDictionary*)parameters
                      headers:(NSDictionary*)headers
                      success:(SERequestHandlerSuccessBlock)success
                      failure:(SERequestHandlerFailureBlock)failure
{
    [[self handler] sendRequest:SERequestMethodGET withURL:url parameters:parameters headers:headers success:success failure:success];
}

+ (void)sendDeleteRequestWithURL:(NSString*)url
                      parameters:(NSDictionary*)parameters
                         headers:(NSDictionary*)headers
                         success:(SERequestHandlerSuccessBlock)success
                         failure:(SERequestHandlerFailureBlock)failure
{
    [[self handler] sendRequest:SERequestMethodDELETE withURL:url parameters:parameters headers:headers success:success failure:success];
}

#pragma mark -
#pragma mark - Private API

+ (SERequestHandler*)handler
{
    return [[SERequestHandler alloc] init];
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
            failure([self errorDictionaryWithError:@"EmptyURL" message:@"URL is empty"]);
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
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-value"
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
#pragma clang diagnostic pop
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

- (NSDictionary*)errorDictionaryWithError:(NSString*)error
                                  message:(NSString*)message
{
    return @{ @"error_class" : error,
              @"message" : message,
              @"request" : @{} };
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
                self.failureBlock([self errorDictionaryWithError:error.description message:error.userInfo[NSLocalizedDescriptionKey]]);
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

#pragma mark - NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response
{
    self.responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    if (self.successBlock) {
        NSError* error;
        NSDictionary* data = [NSJSONSerialization JSONObjectWithData:self.responseData options:0 error:&error];
        if (error) {
            self.failureBlock([self errorDictionaryWithError:error.description message:error.userInfo[NSLocalizedDescriptionKey]]);
        } else {
            self.successBlock(data);
        }
    }
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    if (self.failureBlock) {
        self.failureBlock([self errorDictionaryWithError:error.description message:error.userInfo[NSLocalizedDescriptionKey]]);
    }
}

@end
