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

@interface SERequestHandler ()

typedef NS_ENUM(NSInteger, RequestMethod) {
    RequestMethodPost,
    RequestMethodGet,
    RequestMethodDelete
};

@property (nonatomic) NSMutableData *responseData;
@property (nonatomic, copy) SuccessBlock successBlock;
@property (nonatomic, copy) FailureBlock failureBlock;

@end

@implementation SERequestHandler

#pragma mark -
#pragma mark - Public API

+ (void)sendPostRequestWithURL:(NSString*)urlPath parameters:(NSDictionary*)parameters
                       headers:(NSDictionary*)headers success:(SuccessBlock)success failure:(FailureBlock)failure {
    [[self handler] sendRequest:RequestMethodPost withURL:urlPath parameters:parameters headers:headers success:success failure:success];
}

+ (void)sendGetRequestWithURL:(NSString*)urlPath parameters:(NSDictionary*)parameters
                      headers:(NSDictionary*)headers success:(SuccessBlock)success failure:(FailureBlock)failure {
    [[self handler] sendRequest:RequestMethodGet withURL:urlPath parameters:parameters headers:headers success:success failure:success];
}

+ (void)sendDeleteRequestWithURL:(NSString*)urlPath parameters:(NSDictionary*)parameters
                         headers:(NSDictionary*)headers success:(SuccessBlock)success failure:(FailureBlock)failure {
    [[self handler] sendRequest:RequestMethodDelete withURL:urlPath parameters:parameters headers:headers success:success failure:success];
}

#pragma mark -
#pragma mark - Private API

+ (SERequestHandler*)handler {
    return [[SERequestHandler alloc] init];
}

- (void)sendRequest:(RequestMethod)method withURL:(NSString*)urlPath parameters:(NSDictionary*)parameters
            headers:(NSDictionary*)headers success:(SuccessBlock)success failure:(FailureBlock)failure {
    if ((!urlPath || (urlPath && urlPath.length == 0)) && failure) {
        failure([self errorDictionaryWithError:@"EmptyURLParh" message:@"URL path is empty"]);
        return;
    }

    self.successBlock = success;
    self.failureBlock = failure;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlPath]];
    request.HTTPMethod = [self stringForMethod:method];

    if (headers) {
        for (NSString *header in headers) {
            [request setValue:headers[header] forHTTPHeaderField:header];
        }
    }

    if (parameters) {
        NSError *error;
        request.HTTPBody = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error];
        if (error && failure) {
            failure([self errorDictionaryWithError:error.description message:error.userInfo[NSLocalizedDescriptionKey]]);
            return;
        }
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-value"
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
#pragma clang diagnostic pop
}

- (NSString*)stringForMethod:(RequestMethod)method {
    switch (method) {
        case RequestMethodPost: {
            return @"POST";
        }
        case RequestMethodGet: {
            return @"GET";
        }
        case RequestMethodDelete: {
            return @"DELETE";
        }
    }
}

- (NSDictionary*)errorDictionaryWithError:(NSString*)error message:(NSString*)message {
    return @{ @"error_class" : error,
              @"message" : message,
              @"request" : @{} };
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (self.successBlock) {
        self.successBlock([NSJSONSerialization JSONObjectWithData:self.responseData options:0 error:nil]);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (self.failureBlock) {
        self.failureBlock([self errorDictionaryWithError:error.description message:error.userInfo[NSLocalizedDescriptionKey]]);
    }
}

@end
