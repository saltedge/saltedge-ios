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

@property (nonatomic) NSURLConnection *connection;
@property (nonatomic) NSMutableData *responseData;
@property (nonatomic, copy) SuccessBlock successBlock;
@property (nonatomic, copy) FailureBlock failureBlock;

@end

@implementation SERequestHandler

#pragma mark -
#pragma mark - Public API

+ (SERequestHandler*)createRequest {
    return [[SERequestHandler alloc] init];
}

- (void)sendPostRequestSuccess:(SuccessBlock)success failure:(FailureBlock)failure {
    [self sendRequest:RequestMethodPost success:success failure:failure];
}

- (void)sendGetRequestSuccess:(SuccessBlock)success failure:(FailureBlock)failure {
    [self sendRequest:RequestMethodGet success:success failure:failure];
}

- (void)sendDeleteRequestSuccess:(SuccessBlock)success failure:(FailureBlock)failure {
    [self sendRequest:RequestMethodDelete success:success failure:failure];
}

#pragma mark -
#pragma mark - Private API

- (void)sendRequest:(RequestMethod)method success:(SuccessBlock)success failure:(FailureBlock)failure {
    if ((!self.urlPath || (self.urlPath && self.urlPath.length == 0)) && failure) {
        failure([self errorDictionaryWithError:@"EmptyURLParh" message:@"URL path is empty"]);
        return;
    }

    self.successBlock = success;
    self.failureBlock = failure;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.urlPath]];
    request.HTTPMethod = [self stringForMethod:method];

    if (self.headers) {
        for (NSString *header in self.headers) {
            [request setValue:self.headers[header] forHTTPHeaderField:header];
        }
    }

    if (self.parameters) {
        NSError *error;
        request.HTTPBody = [NSJSONSerialization dataWithJSONObject:self.parameters options:0 error:&error];
        if (error && failure) {
            failure([self errorDictionaryWithError:error.description message:error.userInfo[NSLocalizedDescriptionKey]]);
            return;
        }
    }

    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
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
