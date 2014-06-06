//
//  WPLoginViewController.h
//  WhoPays?
//
//  Created by sonossqa on 5/23/14.
//  Copyright (c) 2014 Malcolm Crum. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WPLoginViewControllerDelegate

-(void)loginSucceeded:(NSString *)accessToken;

@end

@interface WPLoginViewController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) id<WPLoginViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end
