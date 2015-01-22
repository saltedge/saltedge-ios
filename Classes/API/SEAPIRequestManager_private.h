//
//  SEAPIRequestManager_private.h
//  Salt Edge API Demo
//
//  Created by nemesis on 10/29/14.
//  Copyright (c) 2015 Salt Edge. All rights reserved.
//

@interface SEAPIRequestManager()

@property (nonatomic, weak) id<SELoginFetchingDelegate> loginFetchingDelegate;

- (void)pollLoginWithSecret:(NSString*)loginSecret;

@end