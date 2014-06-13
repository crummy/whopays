//
//  WPWelcomeViewController.m
//  WhoPays?
//
//  Created by sonossqa on 5/23/14.
//  Copyright (c) 2014 Malcolm Crum. All rights reserved.
//

#import "WPWelcomeViewController.h"
#import "WPLoginViewController.h"
#import "WPGroupsViewController.h"
#import "OAuthConsumer.h"

@interface WPWelcomeViewController ()

@property (strong, nonatomic) IBOutlet UIButton *signInButton;
- (IBAction)signInButtonPressed:(UIButton *)sender;

@end

@implementation WPWelcomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [self.signInButton setTitle:@"Sign In With Splitwise" forState:UIControlStateNormal];
    [self.signInButton setEnabled:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signInButtonPressed:(UIButton *)sender {
    [self.signInButton setTitle:@"Signing in..." forState:UIControlStateNormal];
    [self.signInButton setEnabled:NO];
    self.accessToken = [[OAToken alloc] initWithUserDefaultsUsingServiceProviderName:@"WhoPays" prefix:@"WP"];
    if (!self.accessToken) {
        [self getUnauthorizedRequestToken];
    } else {
        [self performSegueWithIdentifier:@"toGroupsSegue" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue destinationViewController] isKindOfClass:[WPGroupsViewController class]]) {
        WPGroupsViewController *groupsVC = (WPGroupsViewController *)[segue destinationViewController];
        groupsVC.token = self.accessToken;
        groupsVC.consumer = self.consumer;
    }
}


/*- (void)testAPIConnection {
    NSURL *testURL = [NSURL URLWithString:@"https://secure.splitwise.com/api/v3.0/test"];
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:testURL
                                                                   consumer:self.consumer
                                                                      token:self.accessToken
                                                                      realm:nil
                                                          signatureProvider:nil];
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(testTicket:didFinishWithData:)
                  didFailSelector:@selector(testTicket:didFailWithError:)];
    NSLog(@"Sent test request");
}

- (void)testTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
    NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
}

- (void)testTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
    NSLog(@"test error: %@", error);
}*/

#pragma mark - oauth classes

// First, getUnauthorizedRequestToken is called, to get an anonymous key for us.
// With this token, we form a special HTTP request to splitwise, and open a web browser, in requestTokenTicket:didFinishWithData.
// After logging in, we return to loginSucceeded, which parses out a returned token
// This token is used in getAuthorizedAccessToken to build the final good self.accessToken, which we'll use for future requests.

- (void)getUnauthorizedRequestToken {
    self.consumer = [[OAConsumer alloc] initWithKey:@"OeXIAvu6ykUFQb9Mas1aCVMG97aI3GtcRD1yq7Yb"
                                             secret:@"tMjE1DEH95fKvCprgQL2hfDf3ZdLpAldI3Qt6QNA"];
    NSURL *url = [NSURL URLWithString:@"https://secure.splitwise.com/api/v3.0/get_request_token"];
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:self.consumer
                                                                      token:nil
                                                                      realm:nil
                                                          signatureProvider:nil];
    [request setHTTPMethod:@"POST"];
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(requestTokenTicket:didFinishWithData:)
                  didFailSelector:@selector(requestTokenTicket:didFailWithError:)];
    NSLog(@"Sent anonymous OAuth request");
}

- (void)getAuthorizedAccessToken {
    NSURL *url = [NSURL URLWithString:@"https://secure.splitwise.com/api/v3.0/get_access_token"];
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:self.consumer
                                                                      token:self.accessToken
                                                                      realm:nil
                                                          signatureProvider:nil];
    [request setHTTPMethod:@"POST"];
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(accessTokenTicket:didFinishWithData:)
                  didFailSelector:@selector(accessTokenTicket:didFailWithError:)];
    NSLog(@"Sent access-token OAuth request");
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
    NSLog(@"requestTokenTicket didFinishWithData");
    if (ticket.didSucceed) {
        NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        self.accessToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
        
        NSURL *url = [NSURL URLWithString:@"https://secure.splitwise.com/authorize"];
        OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                        consumer:self.consumer
                                                                           token:self.accessToken
                                                                           realm:nil
                                                               signatureProvider:nil];
        OARequestParameter *param = [[OARequestParameter alloc] initWithName:@"oauth_token" value:self.accessToken.key];
        [request setParameters:@[param]];
        WPLoginViewController *loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Login"];
        loginViewController.delegate = self;
        loginViewController.webView = [[UIWebView alloc] init];
        [self presentViewController:loginViewController animated:YES completion:nil];
        [loginViewController.webView loadRequest:request];
    }
}

-(void)requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
    NSLog(@"requestTokenTicket failed: %@", error);
}

- (void)accessTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
    NSLog(@"accessTokenTicket didFinishWithData");
    if (ticket.didSucceed) {
        NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        self.accessToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
        [self.accessToken storeInUserDefaultsWithServiceProviderName:@"WhoPays" prefix:@"WP"];
        [self performSegueWithIdentifier:@"toGroupsSegue" sender:self];
    } else {
        NSLog(@"accessTokenTicket returned with failure!");
    }
}

-(void)accessTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
    NSLog(@"accessTokenTicket failed: %@", error);
}

#pragma mark - WPLoginViewController delegate

-(void)loginSucceeded:(NSString *)accessToken {
    self.accessToken.verifier = accessToken;
    [self getAuthorizedAccessToken];
}

@end
