//
//  WPGroupsViewController.h
//  WhoPays?
//
//  Created by sonossqa on 6/10/14.
//  Copyright (c) 2014 Malcolm Crum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OAuthConsumer.h"

@interface WPGroupsViewController : UITableViewController

@property (strong, nonatomic) OAToken *token;
@property (strong, nonatomic) OAConsumer *consumer;

@end
