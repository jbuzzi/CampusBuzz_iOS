//
//  CBProfileViewController.m
//  CampusBuzz
//
//  Created by Jorge Buzzi on 11/22/15.
//  Copyright © 2015 Jorge Buzzi. All rights reserved.
//

#import "CBProfileViewController.h"
#import "CBEventTableViewCell.h"
#import "CBEventDetailTableViewController.h"
#import "UIColor+AppColors.h"
#import "MBProgressHUD.h"
#import "SDWebImage/UIImageView+WebCache.h"

@interface CBProfileViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UIColor *mainColor;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UITableView *eventTableView;

@property (nonatomic, strong) PFObject *selectedEvent;

@property (nonatomic, strong) NSMutableArray *futureEvents;
@property (nonatomic, strong) NSMutableArray *pastEvents;
@property (nonatomic, strong) NSArray *events;

@property (weak, nonatomic) IBOutlet UILabel *attendingLabel;
@property (weak, nonatomic) IBOutlet UILabel *attendedLabel;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingBarButtonItem;
@property (weak, nonatomic) IBOutlet UIButton *attendingButton;
@property (weak, nonatomic) IBOutlet UIButton *attendedButton;
@property (weak, nonatomic) IBOutlet UIView *attendingSelectedView;
@property (weak, nonatomic) IBOutlet UIView *attendedSelectedView;

@end

@implementation CBProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    //Set school color
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"SchoolColor" ofType:@"plist"];
    NSDictionary *colorDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    self.mainColor = [UIColor colorFromHexString:[colorDictionary objectForKey:[[PFUser currentUser] objectForKey:@"school"]]];
    self.backgroundView.backgroundColor = self.mainColor;
    
    self.userImageView.layer.masksToBounds = YES;
    self.userImageView.layer.cornerRadius = self.userImageView.layer.frame.size.height/2;
    self.userImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.userImageView.layer.borderWidth = 2;
    
    self.attendingSelectedView.backgroundColor = self.mainColor;
    self.attendedSelectedView.backgroundColor = self.mainColor;
    
    self.attendedSelectedView.hidden = YES;
    
    self.attendingLabel.text = @"";
    self.attendedLabel.text = @"";
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading Events";
    
    self.futureEvents = [[NSMutableArray alloc] init];
    self.pastEvents = [[NSMutableArray alloc] init];
    
    [[PFUser currentUser] fetch];
    
    if (self.user == [PFUser currentUser]) {
        [self setupUser:[PFUser currentUser]];
    } else {
        [self setupUser:self.user];
    }
    
    [self queryEvents];
}

- (void)setupUser:(PFUser *)user {
    if (self.user != [PFUser currentUser]) {
        self.settingBarButtonItem.enabled = NO;
        self.settingBarButtonItem.tintColor = [UIColor clearColor];
    }
    
    self.title = [NSString stringWithFormat:@"%@ %@", [user objectForKey:@"firstName"], [user objectForKey:@"lastName"]];
    
    PFFile *userImageFile = [user objectForKey:@"image"];
    NSURL *url = [NSURL URLWithString:userImageFile.url];
    [self.userImageView sd_setImageWithURL:url];
    
}
- (IBAction)showAttendingPressed:(id)sender {
    self.attendedSelectedView.hidden = YES;
    self.attendingSelectedView.hidden = NO;
    
    self.events = self.futureEvents;
    [self.eventTableView reloadData];
}
- (IBAction)showAttendedPressed:(id)sender {
    self.attendedSelectedView.hidden = NO;
    self.attendingSelectedView.hidden = YES;
    
    self.events = self.pastEvents;
    [self.eventTableView reloadData];
}

- (void)queryEvents {
    PFQuery *query = [PFQuery queryWithClassName:@"Attendee"];
    [query whereKey:@"attendee" equalTo:self.user];
    [query includeKey:@"event"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu events.", (unsigned long)objects.count);
            
            NSDate *today = [NSDate date];
            
            for (PFObject *attending in objects) {
                PFObject *event = [attending objectForKey:@"event"];
                NSDate *eventDate = [event objectForKey:@"date"];
                
                NSComparisonResult result;
                
                result = [today compare:eventDate];
                if(result == NSOrderedAscending)
                   [self.futureEvents addObject:attending];
                else if(result == NSOrderedDescending)
                   [self.pastEvents addObject:attending];
                else
                    [self.futureEvents addObject:attending];
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (self.attendingSelectedView.isHidden) {
                self.events = self.pastEvents;
            } else {
                self.events = self.futureEvents;
            }
            [self.eventTableView reloadData];
            
            self.attendingLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.futureEvents.count];
            self.attendedLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.pastEvents.count];
        });
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.events.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CBEventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventCell" forIndexPath:indexPath];
    
    PFObject *attendee = [self.events objectAtIndex:indexPath.row];
    PFObject *event = [attendee objectForKey:@"event"];
    NSLog(@"%@", event);
    
    PFFile *eventImageFile = [event objectForKey:@"image"];
    if ([event objectForKey:@"image"]) {
        [cell.eventImageView sd_setImageWithURL:[NSURL URLWithString:eventImageFile.url]];
    }
    
    cell.titleLabel.text = [event objectForKey:@"title"];
    
    PFUser *creator = [event objectForKey:@"creator"];
    PFFile *userImageFile = [creator objectForKey:@"image"];
    [cell.userImageView sd_setImageWithURL:[NSURL URLWithString:userImageFile.url]];
    
    cell.locationLabel.text = [event objectForKey:@"location"];
    
    NSDate *date = [event objectForKey:@"date"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMMM d, yyyy 'at' h:mm a"];
    cell.dateLabel.text = [dateFormat stringFromDate:date];
    
    if ([event objectForKey:@"count"]) {
        cell.attendeesLabel.text = [NSString stringWithFormat:@"%@", [event objectForKey:@"count"]];
    } else {
        cell.attendeesLabel.text = @"0";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[PFUser currentUser] fetch];
    PFObject *attendee = [self.events objectAtIndex:indexPath.row];
    PFObject *event = [attendee objectForKey:@"event"];
    self.selectedEvent = event;
    [self performSegueWithIdentifier:@"ShowDetails" sender:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShowDetails"]) {
        CBEventDetailTableViewController *eventDetailVC = [segue destinationViewController];
        eventDetailVC.event = self.selectedEvent;
    }
}

@end
