//
//  InteractiveCredentialsVC.h
//  SaltEdge API Demo
//
//  Created by nemesis on 7/23/14.
//  Copyright (c) 2014 Salt Edge. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^InteractiveCompletionBlock)(NSDictionary*);

@interface InteractiveCredentialsVC : UIViewController

@property (nonatomic, strong) NSArray* interactiveFields;
@property (nonatomic, strong) InteractiveCompletionBlock completionBlock;

@end
