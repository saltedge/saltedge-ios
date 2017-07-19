//
//  SERequestHandlerURLSessionDelegate.m
//  Salt Edge API Demo
//
//  Created by Constantin Lungu on 6/9/16.
//  Copyright © 2016 Salt Edge. All rights reserved.
//

#import "SERequestHandlerURLSessionDelegate.h"
#import "SEAPIRequestManager.h"

@implementation SERequestHandlerURLSessionDelegate

#pragma mark - Public API

+ (instancetype)sharedInstance
{
    static SERequestHandlerURLSessionDelegate* _sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
        NSString* cerPath = [[NSBundle mainBundle] pathForResource:@"saltedge.com" ofType:@"cer"];
        NSAssert(cerPath != nil, @"The saltedge.com SSL certificate could not be located in the app bundle. SSL pinning will not be possible without it.");
        NSString* newCerPath = [[NSBundle mainBundle] pathForResource:@"saltedge.com.new" ofType:@"cer"];
        NSAssert(newCerPath != nil, @"The saltedge.com.new SSL certificate could not be located in the app bundle. SSL pinning will not be possible without it.");
    });
    return _sharedInstance;
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler
{
    SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;

    void (^useChallengeCredential)() = ^{
        NSURLCredential *credential = [NSURLCredential credentialForTrust:serverTrust];
        [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    };

    if (![SEAPIRequestManager SSLPinningEnabled]) {
        useChallengeCredential();
        return;
    }

    SecCertificateRef certificate = SecTrustGetCertificateAtIndex(serverTrust, 0);
    NSData* remoteCertificateData = CFBridgingRelease(SecCertificateCopyData(certificate));
    NSString* cerPath = [[NSBundle mainBundle] pathForResource:@"saltedge.com" ofType:@"cer"];
    NSData* localCertificateData = [NSData dataWithContentsOfFile:cerPath];
    NSString* newCerPath = [[NSBundle mainBundle] pathForResource:@"saltedge.com.new" ofType:@"cer"];
    NSData* newLocalCertificateData = [NSData dataWithContentsOfFile:newCerPath];

    if ([remoteCertificateData isEqualToData:localCertificateData] || [remoteCertificateData isEqualToData:newLocalCertificateData]) {
        useChallengeCredential();
    } else {
        [[challenge sender] cancelAuthenticationChallenge:challenge];
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        NSLog(@"*** SSL Pinning FAILED *** Request to %@://%@ cancelled.", challenge.protectionSpace.protocol, challenge.protectionSpace.host);
    }
}

@end
