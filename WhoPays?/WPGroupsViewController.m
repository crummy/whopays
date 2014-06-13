//
//  WPGroupsViewController.m
//  WhoPays?
//
//  Created by sonossqa on 6/10/14.
//  Copyright (c) 2014 Malcolm Crum. All rights reserved.
//

#import "WPGroupsViewController.h"
#import "WPMembersViewController.h"
#import "WPWelcomeViewController.h"

@interface WPGroupsViewController () <UIAlertViewDelegate>

@property (strong, nonatomic) NSArray *groups;

@end

@implementation WPGroupsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self setTitle:@"Loading..."];
    [self getGroupsFromSplitwise];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Handle sign out button + delegates

- (IBAction)signOutButtonPressed:(UIBarButtonItem *)sender {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Sign Out"
                          message:@"Are you sure you want to sign out?"
                          delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"Sign Out", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self performSegueWithIdentifier:@"signOutSegue" sender:self];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (self.groups) {
        return [self.groups count] - 1;  // minus one to subtract the "transactions in no group" item
    } else {
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Group Cell" forIndexPath:indexPath];

    cell.textLabel.text = [NSString stringWithFormat:@"%@", [self.groups[indexPath.row+1] objectForKey:@"name"]]; // plus one to skip over "transactions in no group" item
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"toMembersSegue" sender:self];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"toMembersSegue"]) {
        WPMembersViewController *membersVC = (WPMembersViewController *)[segue destinationViewController];
        int groupIndex = [self.tableView indexPathForSelectedRow].row + 1;
        NSLog(@"groupIndex: %d", groupIndex);
        membersVC.group = self.groups[groupIndex];
    } else if ([[segue identifier] isEqualToString:@"signOutSegue"]) {
        WPWelcomeViewController *welcomeVC = (WPWelcomeViewController *)[segue destinationViewController];
        [OAToken removeFromUserDefaultsWithServiceProviderName:@"WhoPays" prefix:@"WP"];
        welcomeVC.accessToken = nil;
        welcomeVC.consumer = nil;
    }
}


#pragma mark - Helper methods

- (void)getGroupsFromSplitwise {
    NSURL *testURL = [NSURL URLWithString:@"https://secure.splitwise.com/api/v3.0/get_groups"];
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:testURL
                                                                   consumer:self.consumer
                                                                      token:self.token
                                                                      realm:nil
                                                          signatureProvider:nil];
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(getGroups:didFinishWithData:)
                  didFailSelector:@selector(getGroups:didFailWithError:)];
}

- (void)getGroups:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
    NSError *jsonError = nil;
    NSJSONSerialization *jsonObj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
    if (jsonError != nil) {
        NSLog(@"JSON Error: %@", jsonError);
        return;
    }
    NSDictionary *jsonDict = (NSDictionary *)jsonObj;

    self.groups = [jsonDict objectForKey:@"groups"];
    [self.tableView reloadData];
    [self setTitle:@"Groups"];
}

- (void)getGroups:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
    NSLog(@"Error: %@", error);
}

@end
