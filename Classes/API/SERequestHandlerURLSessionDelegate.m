//
//  SERequestHandlerURLSessionDelegate.m
//  Salt Edge API Demo
//
//  Created by Constantin Lungu on 6/9/16.
//  Copyright © 2016 Salt Edge. All rights reserved.
//

#import "SERequestHandlerURLSessionDelegate.h"

@implementation SERequestHandlerURLSessionDelegate

#pragma mark - Public API

+ (instancetype)sharedInstance
{
    static SERequestHandlerURLSessionDelegate* _sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler
{
    SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
    SecCertificateRef certificate = SecTrustGetCertificateAtIndex(serverTrust, 0);
    NSData* remoteCertificateData = CFBridgingRelease(SecCertificateCopyData(certificate));
    NSString* cerPath = [[NSBundle mainBundle] pathForResource:@"saltedge.com" ofType:@"cer"];
    NSData* localCertificateData = [NSData dataWithContentsOfFile:cerPath];

    if ([remoteCertificateData isEqualToData:localCertificateData]) {
        NSURLCredential *credential = [NSURLCredential credentialForTrust:serverTrust];
        [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    } else {
        [[challenge sender] cancelAuthenticationChallenge:challenge];
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }
}

@end
