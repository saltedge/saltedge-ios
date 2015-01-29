//
//  CredentialsVC.h
//  SaltEdge API Demo
//
//  Created by nemesis on 7/23/14.
//  Copyright (c) 2015 Salt Edge. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CredentialsCompletionBlock)(NSDictionary*);

@interface CredentialsVC : UIViewController

@property (nonatomic, strong) NSArray* credentialFields;
@property (nonatomic, strong) NSString* interactiveHtml;
@property (nonatomic, strong) CredentialsCompletionBlock completionBlock;

@end
