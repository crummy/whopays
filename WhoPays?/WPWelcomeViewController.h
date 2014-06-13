//
//  WPWelcomeViewController.h
//  WhoPays?
//
//  Created by sonossqa on 5/23/14.
//  Copyright (c) 2014 Malcolm Crum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WPLoginViewController.h"
#import "OAuthConsumer.h"

@interface WPWelcomeViewController : UIViewController <WPLoginViewControllerDelegate>

@property (strong, nonatomic) OAConsumer *consumer;
@property (strong, nonatomic) OAToken *accessToken;

@end
