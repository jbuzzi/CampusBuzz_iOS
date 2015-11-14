//
//  CBEventDetailTableViewController.m
//  CampusBuzz
//
//  Created by Jorge Buzzi on 10/26/15.
//  Copyright © 2015 Jorge Buzzi. All rights reserved.
//

#import "CBEventDetailTableViewController.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "CBCommetsTableViewController.h"
#import "CBAttendeesTableViewController.h"
#import "UIColor+AppColors.h"
#import "MBProgressHUD.h"
#import <MapKit/MapKit.h>
#import <EventKit/EventKit.h>

@interface CBEventDetailTableViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *eventImageView;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *creatorLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIImageView *attendee1ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *attendee2ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *attendee3ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *attendee4ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *attendee5ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *attendee6ImageView;
@property (weak, nonatomic) IBOutlet UIButton *attendeesButton;
@property (weak, nonatomic) IBOutlet UIButton *commentsButton;
@property (weak, nonatomic) IBOutlet UIButton *goingButton;

@property (strong, nonatomic) NSArray *comments;
@property (strong, nonatomic) NSArray *attendees;
@property (assign, nonatomic) BOOL loadingComments;
@property (assign, nonatomic) BOOL loadingAttendees;

@property (strong, nonatomic) PFObject *currentRSVP;

@end

@implementation CBEventDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    //Set school color
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"SchoolColor" ofType:@"plist"];
    NSDictionary *colorDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    UIColor * mainColor = [UIColor colorFromHexString:[colorDictionary objectForKey:[[PFUser currentUser] objectForKey:@"school"]]];
    
    self.title = [self.event objectForKey:@"title"];
    
    self.userImageView.layer.masksToBounds = YES;
    self.userImageView.layer.cornerRadius = self.userImageView.frame.size.height/2;
    self.userImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.userImageView.layer.borderWidth = 2.0f;
    
    self.mapView.layer.cornerRadius = 5;
    
    self.descriptionTextView.editable = NO;
    
    self.attendee1ImageView.layer.masksToBounds = YES;
    self.attendee1ImageView.layer.cornerRadius = self.attendee1ImageView.frame.size.height/2;
    self.attendee1ImageView.hidden = YES;
    self.attendee2ImageView.layer.masksToBounds = YES;
    self.attendee2ImageView.layer.cornerRadius = self.attendee2ImageView.frame.size.height/2;
    self.attendee2ImageView.hidden = YES;
    self.attendee3ImageView.layer.masksToBounds = YES;
    self.attendee3ImageView.layer.cornerRadius = self.attendee3ImageView.frame.size.height/2;
    self.attendee3ImageView.hidden = YES;
    self.attendee4ImageView.layer.masksToBounds = YES;
    self.attendee4ImageView.layer.cornerRadius = self.attendee4ImageView.frame.size.height/2;
    self.attendee4ImageView.hidden = YES;
    self.attendee5ImageView.layer.masksToBounds = YES;
    self.attendee5ImageView.layer.cornerRadius = self.attendee5ImageView.frame.size.height/2;
    self.attendee5ImageView.hidden = YES;
    self.attendee6ImageView.layer.masksToBounds = YES;
    self.attendee6ImageView.layer.cornerRadius = self.attendee6ImageView.frame.size.height/2;
    self.attendee6ImageView.hidden = YES;
    
    self.goingButton.layer.cornerRadius = 5.0f;
    self.goingButton.backgroundColor = mainColor;
    
    [self.attendeesButton setTitleColor:mainColor forState:UIControlStateNormal];
    self.attendeesButton.layer.cornerRadius = 5;
    self.attendeesButton.layer.borderColor = mainColor.CGColor;
    self.attendeesButton.layer.borderWidth = 1.5;
    [self.attendeesButton setTintColor:mainColor];
    UIImage * attendeesImage = [self.attendeesButton.currentImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.attendeesButton setImage:attendeesImage forState:UIControlStateNormal];
    
    [self.commentsButton setTitleColor:mainColor forState:UIControlStateNormal];
    self.commentsButton.layer.cornerRadius = 5;
    self.commentsButton.layer.borderColor = mainColor.CGColor;
    self.commentsButton.layer.borderWidth = 1.5;
    [self.commentsButton setTintColor:mainColor];
    UIImage * commentImage = [self.commentsButton.currentImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.commentsButton setImage:commentImage forState:UIControlStateNormal];
    
    [self setupEvent];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading Event";
    
    self.loadingComments = YES;
    [self queryComments];
    
    self.loadingAttendees = YES;
    [self queryAttendees];
}

- (void)viewDidLayoutSubviews {
    [self.descriptionTextView setContentOffset:CGPointZero animated:NO];
}

- (void)setupEvent {
    PFFile *eventImageFile = [self.event objectForKey:@"image"];
    if ([self.event objectForKey:@"image"]) {
        [self.eventImageView sd_setImageWithURL:[NSURL URLWithString:eventImageFile.url]];
    }
    
    self.titleLabel.text = [self.event objectForKey:@"title"];
    
    PFUser *creator = [self.event objectForKey:@"creator"];
    PFFile *userImageFile = [creator objectForKey:@"image"];
    [self.userImageView sd_setImageWithURL:[NSURL URLWithString:userImageFile.url]];
    self.creatorLabel.text = [NSString stringWithFormat:@"Hosted by %@ %@", [creator objectForKey: @"firstName"], [creator objectForKey: @"lastName"]];
    
    NSDate *date = [self.event objectForKey:@"date"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMMM d, yyyy 'at' h:mm a"];
    self.dateLabel.text = [dateFormat stringFromDate:date];
    
    self.locationLabel.text = [NSString stringWithFormat:@"%@, %@, %@ %@", [self.event objectForKey:@"address"], [self.event objectForKey:@"city"], [self.event objectForKey:@"state"], [self.event objectForKey:@"zipcode"]];
    
    PFGeoPoint *location = [self.event objectForKey:@"locationPoint"];
    MKCoordinateRegion mapRegion;
    mapRegion.center.latitude = location.latitude;
    mapRegion.center.longitude = location.longitude;
    mapRegion.span.latitudeDelta = 0.005;
    mapRegion.span.longitudeDelta = 0.005;
    [self.mapView setRegion:mapRegion animated:YES];
    
    self.descriptionTextView.text = [self.event objectForKey:@"description"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)queryComments {
    PFQuery *query = [PFQuery queryWithClassName:@"Comment"];
    [query whereKey:@"event" equalTo:self.event];
    [query orderByAscending:@"date"];
    [query includeKey:@"creator"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu events.", (unsigned long)objects.count);
            self.comments = objects;
            [self.commentsButton setTitle:[NSString stringWithFormat:@"%lu", (unsigned long)self.comments.count] forState:UIControlStateNormal];
            self.loadingComments = NO;
            if (!self.loadingComments && !self.loadingAttendees) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                });
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)queryAttendees {
    PFQuery *query = [PFQuery queryWithClassName:@"Attendee"];
    [query whereKey:@"event" equalTo:self.event];
    [query includeKey:@"attendee"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu events.", (unsigned long)objects.count);
            self.attendees = objects;
            [self.attendeesButton setTitle:[NSString stringWithFormat:@"%lu", (unsigned long)self.attendees.count] forState:UIControlStateNormal];
            
            [self.goingButton setTitle:@"I'M GOING" forState:UIControlStateNormal];
            
            for (int i = 0; i < self.attendees.count; i++) {
                PFObject * attendee = [self.attendees objectAtIndex:i];
                if ([attendee objectForKey:@"attendee"] == [PFUser currentUser]) {
                    [self.goingButton setTitle:@"NOT GOING" forState:UIControlStateNormal];
                    self.currentRSVP = attendee;
                }
                
                PFUser *creator = [attendee objectForKey:@"attendee"];
                PFFile *userImageFile = [creator objectForKey:@"image"];
                switch (i) {
                    case 0:
                        self.attendee1ImageView.hidden = NO;
                        [self.attendee1ImageView sd_setImageWithURL:[NSURL URLWithString:userImageFile.url]];
                        break;
                    case 1:
                        self.attendee2ImageView.hidden = NO;
                        [self.attendee2ImageView sd_setImageWithURL:[NSURL URLWithString:userImageFile.url]];
                        break;
                    case 2:
                        self.attendee3ImageView.hidden = NO;
                        [self.attendee3ImageView sd_setImageWithURL:[NSURL URLWithString:userImageFile.url]];
                        break;
                    case 3:
                        self.attendee4ImageView.hidden = NO;
                        [self.attendee4ImageView sd_setImageWithURL:[NSURL URLWithString:userImageFile.url]];
                        break;
                    case 4:
                        self.attendee5ImageView.hidden = NO;
                        [self.attendee5ImageView sd_setImageWithURL:[NSURL URLWithString:userImageFile.url]];
                        break;
                    case 5:
                        self.attendee6ImageView.hidden = NO;
                        [self.attendee6ImageView sd_setImageWithURL:[NSURL URLWithString:userImageFile.url]];
                        break;
                        
                    default:
                        break;
                }
            }
            
            self.loadingAttendees = NO;
            if (!self.loadingComments && !self.loadingAttendees) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                });
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (IBAction)goingPressed:(id)sender {
    if (self.currentRSVP) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Changed Your Mind" message:@"Are you sure you want to be removed from this event?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *yes = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"";

            self.loadingAttendees = YES;
            [self.currentRSVP deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (!error) {
                    EKEventStore* store = [[EKEventStore alloc] init];
                    EKEvent* event = [store eventWithIdentifier:[self.currentRSVP objectForKey:@"iCalEventId"]];
                    if (event != nil) {
                        NSError* error = nil;
                        [store removeEvent:event span:EKSpanThisEvent error:&error];
                    }
                    self.currentRSVP = nil;
                    [self queryAttendees];
                    [self.event incrementKey:@"count" byAmount:[NSNumber numberWithInt:-1]];
                    [self.event saveInBackground];
                } else {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Opps!" message:@"There was an error removing this event. Try again later." preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                    }];
                    [alert addAction:ok];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }];
        }];
        UIAlertAction *no = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        }];
        [alert addAction:yes];
        [alert addAction:no];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Yay!" message:@"Would you like to add this event to your phone calendar?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *yes = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            EKEventStore *store = [EKEventStore new];
            [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
                if (!granted) {
                    return;
                }
                EKEvent *event = [EKEvent eventWithEventStore:store];
                event.title = [self.event objectForKey:@"title"];
                event.location = [NSString stringWithFormat:@"%@, %@, %@ %@", [self.event objectForKey:@"address"], [self.event objectForKey:@"city"], [self.event objectForKey:@"state"], [self.event objectForKey:@"zipcode"]];
                event.startDate = [self.event objectForKey:@"date"];
                event.endDate = [event.startDate dateByAddingTimeInterval:60*60];  //set 1 hour meeting
                event.calendar = [store defaultCalendarForNewEvents];
                NSError *err = nil;
                [store saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
                
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.labelText = @"";
                
                PFObject *attendee = [PFObject objectWithClassName:@"Attendee"];
                attendee[@"attendee"] = [PFUser currentUser];
                attendee[@"event"] = self.event;
                attendee[@"iCalEventId"] = event.eventIdentifier;
                
                self.loadingAttendees = YES;
                [attendee saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (!error) {
                        [self queryAttendees];
                        [self.event incrementKey:@"count"];
                        [self.event saveInBackground];
                    } else {
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Opps!" message:@"There was an error removing this event. Try again later." preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                        }];
                        [alert addAction:ok];
                        [self presentViewController:alert animated:YES completion:nil];
                    }
                }];
            }];
        }];
        UIAlertAction *no = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"";
            
            PFObject *attendee = [PFObject objectWithClassName:@"Attendee"];
            attendee[@"attendee"] = [PFUser currentUser];
            attendee[@"event"] = self.event;
            
            self.loadingAttendees = YES;
            [attendee saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (!error) {
                    [self queryAttendees];
                    [self.event incrementKey:@"count"];
                    [self.event saveInBackground];
                } else {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Opps!" message:@"There was an error removing this event. Try again later." preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                    }];
                    [alert addAction:ok];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }];
        }];
        [alert addAction:yes];
        [alert addAction:no];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (IBAction)mapPressed:(id)sender {
    NSString * address = [NSString stringWithFormat:@"%@, %@, %@ %@", [self.event objectForKey:@"address"], [self.event objectForKey:@"city"], [self.event objectForKey:@"state"], [self.event objectForKey:@"zipcode"]];
    address = [address stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    NSString *addressURL = [NSString stringWithFormat: @"http://maps.apple.com/?q=%@", address];
    NSURL *url = [NSURL URLWithString:addressURL];
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)morePressed:(id)sender {
    PFUser *creator = [self.event objectForKey:@"creator"];
    
    if (creator == [PFUser currentUser]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *edit = [UIAlertAction actionWithTitle:@"Edit Event" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            
        }];
        UIAlertAction *remove = [UIAlertAction actionWithTitle:@"Remove Event" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
            
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addAction:edit];
        [alert addAction:remove];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *report = [UIAlertAction actionWithTitle:@"Report Event" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addAction:report];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            return 200;
        case 1:
            return 61;
        case 2:
            return 270;
        case 3:
            return 66;
        default:
            return 0;
    }
    
    return 0;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShowComments"]) {
        CBCommetsTableViewController *eventCommentsVC = [segue destinationViewController];
        eventCommentsVC.event = self.event;
        eventCommentsVC.comments = self.comments;
    } else if ([[segue identifier] isEqualToString:@"ShowAttendees"]) {
        CBAttendeesTableViewController *eventAttendeesVC = [segue destinationViewController];
        eventAttendeesVC.attendees = self.attendees;
    }
}


@end
