//
//  CBEventDetailTableViewController.m
//  CampusBuzz
//
//  Created by Jorge Buzzi on 10/26/15.
//  Copyright © 2015 Jorge Buzzi. All rights reserved.
//

#import "CBEventDetailTableViewController.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "UIColor+AppColors.h"
#import <MapKit/MapKit.h>

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
    self.attendee1ImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.attendee1ImageView.layer.borderWidth = 1.0f;
    self.attendee2ImageView.layer.masksToBounds = YES;
    self.attendee2ImageView.layer.cornerRadius = self.attendee2ImageView.frame.size.height/2;
    self.attendee2ImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.attendee2ImageView.layer.borderWidth = 1.0f;
    self.attendee3ImageView.layer.masksToBounds = YES;
    self.attendee3ImageView.layer.cornerRadius = self.attendee3ImageView.frame.size.height/2;
    self.attendee3ImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.attendee3ImageView.layer.borderWidth = 1.0f;
    self.attendee4ImageView.layer.masksToBounds = YES;
    self.attendee4ImageView.layer.cornerRadius = self.attendee4ImageView.frame.size.height/2;
    self.attendee4ImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.attendee4ImageView.layer.borderWidth = 1.0f;
    self.attendee5ImageView.layer.masksToBounds = YES;
    self.attendee5ImageView.layer.cornerRadius = self.attendee5ImageView.frame.size.height/2;
    self.attendee5ImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.attendee5ImageView.layer.borderWidth = 1.0f;
    self.attendee6ImageView.layer.masksToBounds = YES;
    self.attendee6ImageView.layer.cornerRadius = self.attendee6ImageView.frame.size.height/2;
    self.attendee6ImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.attendee6ImageView.layer.borderWidth = 1.0f;
    
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

- (void)setupEvent {
    PFFile *eventImageFile = [self.event objectForKey:@"image"];
    [self.eventImageView sd_setImageWithURL:[NSURL URLWithString:eventImageFile.url]];
    
    self.titleLabel.text = [self.event objectForKey:@"title"];
    
    PFUser *creator = [self.event objectForKey:@"creator"];
    PFFile *userImageFile = [creator objectForKey:@"image"];
    [self.userImageView sd_setImageWithURL:[NSURL URLWithString:userImageFile.url]];
    self.creatorLabel.text = [NSString stringWithFormat:@"Hosted by %@", [creator username]];
    
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

- (IBAction)goingPressed:(id)sender {
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
