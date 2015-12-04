//
//  CBAttendeesTableViewController.m
//  CampusBuzz
//
//  Created by Jorge Buzzi on 11/5/15.
//  Copyright © 2015 Jorge Buzzi. All rights reserved.
//

#import "CBAttendeesTableViewController.h"
#import "CBAttendeeTableViewCell.h"
#import "CBProfileViewController.h"
#import "MBProgressHUD.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import <Parse/Parse.h>

@interface CBAttendeesTableViewController ()

@property (nonatomic, strong) PFUser *selectedUser;

@end

@implementation CBAttendeesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
     self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.title = @"Going";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.attendees.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CBAttendeeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AttendeeCell" forIndexPath:indexPath];
   
    PFObject *attendee = [self.attendees objectAtIndex:indexPath.row];
    PFUser *creator = [attendee objectForKey:@"attendee"];
    PFFile *userImageFile = [creator objectForKey:@"image"];
    
    [cell.userImageView sd_setImageWithURL:[NSURL URLWithString:userImageFile.url]];
    cell.userLabel.text = [NSString stringWithFormat:@"%@ %@", [creator objectForKey:@"firstName"], [creator objectForKey:@"lastName"]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *attendee = [self.attendees objectAtIndex:indexPath.row];
    PFUser *creator = [attendee objectForKey:@"attendee"];
    self.selectedUser = creator;
    
    [self performSegueWithIdentifier:@"ShowUser" sender:self];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShowUser"]) {
        CBProfileViewController *profileVC = [segue destinationViewController];
        profileVC.user = self.selectedUser;
    }
}


@end
