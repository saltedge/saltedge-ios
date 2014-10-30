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
static NSString* const kRequestMethodPUT    = @"PUT";

static NSString* const kErrorClassKey = @"error_class";
static NSString* const kMessageKey    = @"message";
static NSString* const kRequestKey    = @"request";
static NSString* const kParametersKey = @"parameters";

static NSString* const kEmptyURLErrorClass   = @"SEEmptyURLError";
static NSString* const kEmptyURLErrorMessage = @"Cannot send a request to an empty URL.";

static NSString* const kBadRequestParametersErrorClass   = @"SEBadRequestParametersError";
static NSString* const kBadRequestParametersErrorMessage = @"Could not handle parameters assignment in request.";

typedef NS_ENUM(NSInteger, SERequestMethod) {
    SERequestMethodDELETE,
    SERequestMethodGET,
    SERequestMethodPOST,
    SERequestMethodPUT
};

@interface SERequestHandler (/* Private */) <NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSMutableData* responseData;
@property (nonatomic, copy)   SERequestHandlerFailureBlock successBlock;
@property (nonatomic, copy)   SERequestHandlerFailureBlock failureBlock;
@property (nonatomic)         NSInteger responseStatusCode;

@end

@implementation SERequestHandler

#pragma mark -
#pragma mark - Public API

+ (void)sendDELETERequestWithURL:(NSString*)url
                      parameters:(NSDictionary*)parameters
                         headers:(NSDictionary*)headers
                         success:(SERequestHandlerSuccessBlock)success
                         failure:(SERequestHandlerFailureBlock)failure
{
    [[self handler] sendRequest:SERequestMethodDELETE withURL:url parameters:parameters headers:headers success:success failure:failure];
}

+ (void)sendGETRequestWithURL:(NSString*)url
                   parameters:(NSDictionary*)parameters
                      headers:(NSDictionary*)headers
                      success:(SERequestHandlerSuccessBlock)success
                      failure:(SERequestHandlerFailureBlock)failure
{
    [[self handler] sendRequest:SERequestMethodGET withURL:url parameters:parameters headers:headers success:success failure:failure];
}

+ (void)sendPOSTRequestWithURL:(NSString*)url
                    parameters:(NSDictionary*)parameters
                       headers:(NSDictionary*)headers
                       success:(SERequestHandlerSuccessBlock)success
                       failure:(SERequestHandlerFailureBlock)failure
{
    [[self handler] sendRequest:SERequestMethodPOST withURL:url parameters:parameters headers:headers success:success failure:failure];
}

+ (void)sendPUTRequestWithURL:(NSString *)url
                   parameters:(NSDictionary *)parameters
                      headers:(NSDictionary *)headers
                      success:(SERequestHandlerSuccessBlock)success
                      failure:(SERequestHandlerFailureBlock)failure
{
    [[self handler] sendRequest:SERequestMethodPUT withURL:url parameters:parameters headers:headers success:success failure:failure];
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
            failure(@{ kErrorClassKey : kEmptyURLErrorClass,
                       kMessageKey : kEmptyURLErrorMessage,
                       kRequestKey : @{
                               kParametersKey : parameters ? parameters : [NSNull null]
                               }
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
            if (failure) {
                failure(@{ kErrorClassKey : kBadRequestParametersErrorClass,
                           kMessageKey : kBadRequestParametersErrorMessage,
                           kRequestKey : @{
                                   kParametersKey : parameters
                                   }
                           });
            }
            return;
        }
    }

    [NSURLConnection connectionWithRequest:request delegate:self];
}

- (NSString*)stringForMethod:(SERequestMethod)method
{
    switch (method) {
        case SERequestMethodDELETE: {
            return kRequestMethodDELETE;
        }
        case SERequestMethodGET: {
            return kRequestMethodGET;
        }
        case SERequestMethodPOST: {
            return kRequestMethodPOST;
        }
        case SERequestMethodPUT: {
            return kRequestMethodPUT;
        }
    }
}

- (BOOL)handleParameters:(NSDictionary*)parameters assignmentInRequest:(NSMutableURLRequest*)request
{
    if ([[self HTTPMethodsWithoutBody] containsObject:[request.HTTPMethod uppercaseString]]) {
        NSString* query = [self urlQueryFormatForParameters:parameters];
        request.URL = [NSURL URLWithString:[request.URL.absoluteString stringByAppendingFormat:request.URL.query ? @"&%@" : @"?%@", query]];
    } else {
        NSError* error;
        NSData* data = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error];
        if (error) {
            if (self.failureBlock) {
                self.failureBlock(@{ kErrorClassKey : error.domain,
                                     kMessageKey : error.localizedDescription,
                                     kRequestKey : parameters });
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

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response
{
    self.responseData = [[NSMutableData alloc] init];
    self.responseStatusCode = [(NSHTTPURLResponse*)response statusCode];
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    NSError* error;
    NSDictionary* data = [NSJSONSerialization JSONObjectWithData:self.responseData options:0 error:&error];
    if (error) {
        self.failureBlock(@{ kErrorClassKey : error.domain,
                             kMessageKey : error.localizedDescription,
                             kRequestKey : connection.currentRequest });
    } else {
        if ((self.responseStatusCode >= 200 && self.responseStatusCode < 300)) {
            self.successBlock(data);
        } else {
            self.failureBlock(data);
        }
    }
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    if (self.failureBlock) {
        self.failureBlock(@{ kErrorClassKey : error.domain,
                             kMessageKey : error.localizedDescription,
                             kRequestKey : connection.currentRequest
                             });
    }
}

- (NSCachedURLResponse*)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return nil;
}

@end
