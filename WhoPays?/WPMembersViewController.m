//
//  WPMembersViewController.m
//  WhoPays?
//
//  Created by sonossqa on 6/11/14.
//  Copyright (c) 2014 Malcolm Crum. All rights reserved.
//

#import "WPMembersViewController.h"

@interface WPMembersViewController ()

@property (strong, nonatomic) NSMutableDictionary *selectedMembers;

@end

@implementation WPMembersViewController

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
    [self setTitle:@"Select who is present"];
    self.selectedMembers = [@{} mutableCopy];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)calculateWhoOwes {
    if ([self.selectedMembers count] == 0) {
        [self setTitle:@"Select who is present"];
        return;
    }
    NSString *whoPays = @"";
    float worstDebt = -FLT_MAX;
    for (NSNumber *memberIndex in self.selectedMembers) {
        NSDictionary *member = self.group[@"members"][[memberIndex intValue]];
        float totalOwed = 0;
        for (NSDictionary *debt in self.group[@"original_debts"]) {
            if ([debt[@"from"] intValue] == [member[@"id"] intValue]) {
                totalOwed += [debt[@"amount"] floatValue];
            } else if ([debt[@"to"] intValue] == [member[@"id"] intValue]) {
                totalOwed -= [debt[@"amount"] floatValue];
            }
        }
        if (totalOwed > worstDebt) {
            worstDebt = totalOwed;
            whoPays = member[@"first_name"];
        }
    }
    [self setTitle:whoPays];
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
    if (self.group) {
        return [self.group count];
    } else {
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Member Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", self.group[@"members"][indexPath.row][@"first_name"], self.group[@"members"][indexPath.row][@"last_name"]];
    NSString *memberIndex = [NSString stringWithFormat:@"%ld", indexPath.row];
    if ([self.selectedMembers[memberIndex] isEqualToNumber:@YES]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *memberIndex = [NSString stringWithFormat:@"%ld", indexPath.row];
    if (self.selectedMembers[memberIndex]) {
        [self.selectedMembers removeObjectForKey:memberIndex];
    } else {
        self.selectedMembers[memberIndex] = @YES;
    }
    [self calculateWhoOwes];
    [self.tableView reloadData];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
