//
//  WPLoginViewController.m
//  WhoPays?
//
//  Created by sonossqa on 5/23/14.
//  Copyright (c) 2014 Malcolm Crum. All rights reserved.
//

#import "WPLoginViewController.h"

@interface WPLoginViewController ()

@end

@implementation WPLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.webView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeButtonPressed:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Webview delegate

// from https://github.com/anoopr/core-data-talk/blob/master/example/Classes/FoursquareAuthViewController.m
-(void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *urlString = [[self.webView.request URL] absoluteString];
    NSLog(@"URL: %@", urlString);
    if ([urlString rangeOfString:@"oauth_verifier="].location != NSNotFound) {
        NSString *accessToken = [[urlString componentsSeparatedByString:@"="] lastObject];
        NSLog(@"access token: %@", accessToken);
        [self.delegate loginSucceeded:accessToken];
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

@end
