//
//  CBEventFeedViewController.m
//  CampusBuzz
//
//  Created by Jorge Buzzi on 10/1/15.
//  Copyright © 2015 Jorge Buzzi. All rights reserved.
//

#import "CBEventFeedViewController.h"
#import "CBEventTableViewCell.h"
#import "CBSignInTableViewController.h"
#import "CBProfileViewController.h"
#import "UIColor+AppColors.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "CBEventDetailTableViewController.h"
#import "MBProgressHUD.h"
#import <Parse/Parse.h>

@interface CBEventFeedViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *filtersScrollView;
@property (strong, nonatomic) UIColor *mainColor;

@property (strong, nonatomic) UIButton *selectedButton;
@property (strong, nonatomic) UIView *selectedView;
@property (strong, nonatomic) NSArray *categoriesImage;

@property (weak, nonatomic) IBOutlet UITableView *eventTableView;
@property (weak, nonatomic) IBOutlet UIView *noResultView;

@property (strong, nonatomic) NSArray *events;
@property (strong, nonatomic) PFObject *selectedEvent;
@property (strong, nonatomic) NSString *selectedCategory;

@property (assign, nonatomic) BOOL isLoading;

@end

@implementation CBEventFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    //Set school color
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"SchoolColor" ofType:@"plist"];
    NSDictionary *colorDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    self.mainColor = [UIColor colorFromHexString:[colorDictionary objectForKey:[[PFUser currentUser] objectForKey:@"school"]]];
    
    self.navigationController.navigationBar.barTintColor = self.mainColor;
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.categoriesImage = @[@"Academic", @"Alumni", @"Art", @"Careers", @"Clubs", @"Concerts", @"Conferences", @"Dance", @"Film", @"Food", @"Fundraisers", @"Lectures", @"Meetings", @"Parties", @"Religious", @"Science", @"Special Interest", @"Sports", @"Study Abroad", @"Theater", @"Volunteering"];
    [self createScrollMenu];
    
    self.noResultView.hidden = YES;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading Events";
    
    self.isLoading = YES;
    [self queryEvents:self.selectedCategory];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)createScrollMenu {
    int x = 0;
    for (int i = 0; i < self.categoriesImage.count; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(x, 0, 64, 64)];
        button.tag = i;
        [button setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
        button.layer.cornerRadius = button.frame.size.height/2;
        [button setImage:[UIImage imageNamed:[self.categoriesImage objectAtIndex:i]] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(categoryPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.filtersScrollView addSubview:button];
    
        x += button.frame.size.width;
    }
    
    self.filtersScrollView.contentSize = CGSizeMake(x, self.filtersScrollView.frame.size.height);
    self.filtersScrollView.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

- (void)categoryPressed:(UIButton *)sender {
    if (sender.isSelected) {
        [self.selectedView removeFromSuperview];
        [sender setSelected:NO];
        self.selectedButton = nil;
        self.title = @"Events";
        
        //Query all events
        [self queryEvents:nil];
    } else {
        //Deselect previous
        [self.selectedButton setSelected:NO];
        [self.selectedView removeFromSuperview];
        
        //Select new one
        self.selectedView = [[UIView alloc] initWithFrame:CGRectMake(0, sender.frame.size.height-5, sender.frame.size.width, 5)];
        self.selectedView.backgroundColor = self.mainColor;
        [sender addSubview:self.selectedView];
        [sender setSelected:YES];
        self.selectedButton = sender;
        self.title = [self.categoriesImage objectAtIndex:sender.tag];
        
        //Query events in category
        [self queryEvents:[self.categoriesImage objectAtIndex:sender.tag]];
    }
}

- (void)queryEvents:(NSString *)category {
    if (category) {
        self.selectedCategory = category;
        PFQuery *query = [PFQuery queryWithClassName:@"Event"];
        [query whereKey:@"school" equalTo:[[PFUser currentUser] objectForKey:@"school"]];
        [query whereKey:@"category" equalTo:category];
        [query whereKey:@"date" greaterThanOrEqualTo:[NSDate date]];
        [query orderByAscending:@"date"];
        [query includeKey:@"creator"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            self.isLoading = YES;
            if (!error) {
                // The find succeeded.
                NSLog(@"Successfully retrieved %lu events.", (unsigned long)objects.count);
                self.events = objects;
                [self.eventTableView reloadData];
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        }];
    } else {
        self.selectedCategory = nil;
        PFQuery *query = [PFQuery queryWithClassName:@"Event"];
        [query whereKey:@"school" equalTo:[[PFUser currentUser] objectForKey:@"school"]];
        [query whereKey:@"date" greaterThanOrEqualTo:[NSDate date]];
        [query orderByAscending:@"date"];
        [query includeKey:@"creator"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            self.isLoading = YES;
            if (!error) {
                // The find succeeded.
                NSLog(@"Successfully retrieved %lu events.", (unsigned long)objects.count);
                self.events = objects;
                [self.eventTableView reloadData];
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        }];
    }
}

- (IBAction)userProfilePressed:(id)sender {
    [self performSegueWithIdentifier:@"ShowUser" sender:self];
}

#pragma mark - UITableViewDataSource 

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.events.count) {
        self.noResultView.hidden = YES;
    } else {
        if (self.isLoading) {
            self.noResultView.hidden = YES;
        } else {
            self.noResultView.hidden = NO;
        }
    }
    return self.events.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CBEventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventCell" forIndexPath:indexPath];
    
    PFObject *event = [self.events objectAtIndex:indexPath.row];
    
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
    if ([[[PFUser currentUser] objectForKey:@"emailVerified"] boolValue]) {
        self.selectedEvent = [self.events objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"ShowDetails" sender:self];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Opps!" message:@"Email must be verify before you can view events in your school. Please check your inbox or spam folder and verify your account." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShowDetails"]) {
        CBEventDetailTableViewController *eventDetailVC = [segue destinationViewController];
        eventDetailVC.event = self.selectedEvent;
    } else if ([[segue identifier] isEqualToString:@"ShowUser"]) {
        CBProfileViewController *profileVC = [segue destinationViewController];
        profileVC.user = [PFUser currentUser];
    }
}


@end
