//
//  CBAddEventTableViewController.m
//  CampusBuzz
//
//  Created by Jorge Buzzi on 10/2/15.
//  Copyright © 2015 Jorge Buzzi. All rights reserved.
//

#import "CBAddEventTableViewController.h"
#import "UIColor+AppColors.h"
#import "MBProgressHUD.h"
#import <Parse/Parse.h>

@interface CBAddEventTableViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *eventImageView;
@property (weak, nonatomic) IBOutlet UIButton *addImageButton;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UITextField *cityTextField;
@property (weak, nonatomic) IBOutlet UITextField *zipcodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *dateTextField;
@property (weak, nonatomic) IBOutlet UITextField *categoryTextField;
@property (weak, nonatomic) IBOutlet UIButton *createButton;

@property (assign) NSString *placeholder;
@property (strong, nonatomic) UIPickerView *categoryPicker;
@property (nonatomic, strong) NSArray *categoties;
@property (nonatomic, strong) NSDate *eventDate;

@end

@implementation CBAddEventTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Set school color
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"SchoolColor" ofType:@"plist"];
    NSDictionary *colorDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    UIColor * mainColor = [UIColor colorFromHexString:[colorDictionary objectForKey:[[PFUser currentUser] objectForKey:@"school"]]];
    
    self.titleTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Event Title" attributes:@{NSForegroundColorAttributeName:[UIColor CBGrayColor]}];
    self.dateTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"When" attributes:@{NSForegroundColorAttributeName:[UIColor CBGrayColor]}];
    self.locationTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Location Name" attributes:@{NSForegroundColorAttributeName:[UIColor CBGrayColor]}];
    self.addressTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Street Address" attributes:@{NSForegroundColorAttributeName:[UIColor CBGrayColor]}];
    self.cityTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"City" attributes:@{NSForegroundColorAttributeName:[UIColor CBGrayColor]}];
    self.zipcodeTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Zip Code" attributes:@{NSForegroundColorAttributeName:[UIColor CBGrayColor]}];
    self.categoryTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Category" attributes:@{NSForegroundColorAttributeName:[UIColor CBGrayColor]}];
    
    self.placeholder = @"Description   ";
    self.descriptionTextView.text = self.placeholder;
    self.descriptionTextView.textColor = [UIColor CBGrayColor];
    self.descriptionTextView.delegate = self;
    self.descriptionTextView.contentInset = UIEdgeInsetsMake(10, 0, 10, 0);
    
    self.createButton.layer.cornerRadius = 5.0f;
    self.createButton.backgroundColor = mainColor;
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    NSDate *currentDate = [NSDate date];
    [datePicker setMinimumDate:currentDate];
    self.dateTextField.inputView = datePicker;
    
    self.categoties = @[@"Academic", @"Alumni", @"Art", @"Careers", @"Clubs", @"Concerts", @"Conferences", @"Dance", @"Film", @"Food", @"Fundraisers", @"Lectures", @"Meetings", @"Parties", @"Religious", @"Science", @"Special Interest", @"Sports", @"Study Abroad", @"Theater", @"Volunteering"];
    UIPickerView *categoryPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 216)];
    categoryPicker.dataSource = self;
    categoryPicker.delegate = self;
    self.categoryTextField.inputView = categoryPicker;
}

- (IBAction)createPressed:(id)sender {
    if ([self checkForCompletion]) {
        [self.titleTextField resignFirstResponder];
        [self.descriptionTextView resignFirstResponder];
        [self.dateTextField resignFirstResponder];
        [self.locationTextField resignFirstResponder];
        [self.addressTextField resignFirstResponder];
        [self.cityTextField resignFirstResponder];
        [self.zipcodeTextField resignFirstResponder];
        [self.categoryTextField resignFirstResponder];
        
        NSString *title = [self.titleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *description = [self.descriptionTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *location = [self.locationTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *address = [self.addressTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *city = [self.cityTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *zipcode = [self.zipcodeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *category = [self.categoryTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Creating Event";
        
        PFObject *event = [PFObject objectWithClassName:@"Event"];
        event[@"title"] = title;
        event[@"description"] = description;
        event[@"date"] = self.eventDate;
        event[@"category"] = category;
        event[@"location"] = location;
        event[@"address"] = address;
        event[@"city"] = city;
        event[@"zipcode"] = zipcode;
        event[@"school"] = [[PFUser currentUser] objectForKey:@"school"];
        event[@"creator"] = [PFUser currentUser];
        event[@"count"] = @0;
        
        if (self.eventImageView.image) {
            NSData *imageData = UIImageJPEGRepresentation(self.eventImageView.image, 0.5f);
            PFFile *imageFile = [PFFile fileWithName:@"event_image.jpg" data:imageData];
            [event setObject:imageFile forKey:@"image"];
        }
        
        NSString *fullAddress = [NSString stringWithFormat:@"%@, %@, %@", address, city, zipcode];
        CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
        [geoCoder geocodeAddressString:fullAddress completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            CLLocation *location = placemark.location;
            CLLocationCoordinate2D coordinate = location.coordinate;
            NSLog(@"Latitude %f", coordinate.latitude);
            NSLog(@"Longitude %f", coordinate.longitude);
            
            if (placemark) {
                event[@"state"] = placemark.administrativeArea;
            
                PFGeoPoint *locationPoint =  [PFGeoPoint geoPointWithLocation:location];
                event[@"locationPoint"] = locationPoint;
                
                [[PFUser currentUser] fetch];
                if ([[[PFUser currentUser] objectForKey:@"emailVerified"] boolValue]) {
                    [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                        });
                        if (succeeded) {
                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"New Event Created!" message:@"Congrats, your event has been created and added to your school events." preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                [self.navigationController popViewControllerAnimated:YES];
                            }];
                            [alert addAction:ok];
                            [self presentViewController:alert animated:YES completion:nil];
                        } else {
                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Opps!" message:@"There was an error adding your event." preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                [self.navigationController popViewControllerAnimated:YES];
                            }];
                            [alert addAction:ok];
                            [self presentViewController:alert animated:YES completion:nil];
                        }
                    }];
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                    });
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Opps!" message:@"Email must be verify before you can post events in your school. Please check your inbox or spam folder and verify your account." preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                    }];
                    [alert addAction:ok];
                    [self presentViewController:alert animated:YES completion:nil];
                }
                
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                });
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Opps!" message:@"Address not found, make sure the address is correct." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                }];
                [alert addAction:ok];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Opps!" message:@"All fields must be completed" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (BOOL)checkForCompletion {
    NSString *title = [self.titleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *description = [self.descriptionTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *location = [self.locationTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *address = [self.addressTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *city = [self.cityTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *zipcode = [self.zipcodeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *date = [self.dateTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *category = [self.categoryTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (title.length > 0 && description.length > 0 && location.length > 0 && address.length > 0 && city.length > 0 && zipcode.length > 0 && date.length > 0 && category.length > 0) {
        return YES;
    } else {
        return NO;
    }
}

- (IBAction)addImagePressed:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"Take a new photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
        {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypeCamera;
            controller.allowsEditing = YES;
            controller.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeCamera];
            controller.delegate = self;
            [self.navigationController presentViewController:controller animated: YES completion: nil];
        }
    }];
    UIAlertAction *library = [UIAlertAction actionWithTitle:@"Choose from existing" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary])
        {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            controller.allowsEditing = NO;
            controller.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypePhotoLibrary];
            controller.delegate = self;
            [self.navigationController presentViewController:controller animated: YES completion: nil];
        }
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:camera];
    [alert addAction:library];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)datePickerValueChanged:(UIDatePicker *)sender{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM d, yyyy 'at' h:mm a"];
    
    self.eventDate = sender.date;
    [self.dateTextField setText:[dateFormatter stringFromDate:sender.date]];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    switch (indexPath.row) {
        case 0:
            return 200;
        case 1:
            return 105;
        case 2:
            return 60;
        case 3:
            return 60;
        case 4:
            return 60;
        case 5:
            return 60;
        case 6:
            return 60;
        case 7: {
            float height = screenHeight - 200 - 105 - 60 - 60 - 60 - 60 - 60;
            if (height < 89) {
                return 89;
            } else {
                return height;
            }
        }
        default:
            return 0;
    }
    return 0;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self.navigationController dismissViewControllerAnimated: YES completion: nil];
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [self.addImageButton setImage:nil forState:UIControlStateNormal];
    [self.eventImageView setImage:image];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker; {
    [self.navigationController dismissViewControllerAnimated: YES completion: nil];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:self.placeholder]) {
        [self performSelector:@selector(setCursorToBeginning:) withObject:textView afterDelay:0.01];
    } 
}

- (void)setCursorToBeginning:(UITextView *)textView {
    textView.selectedRange = NSMakeRange(0, 0);
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.text.length == 0) {
        textView.text = self.placeholder;
        textView.textColor = [UIColor CBGrayColor];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if(range.length + range.location > textView.text.length) {
        return NO;
    }
    
    if ([textView.text isEqualToString:self.placeholder]) {
        textView.text = @"";
        textView.textColor = [UIColor CBGrayColor];
    } else {
        textView.textColor = [UIColor blackColor];
    }
    
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    if (newLength == 0) {
        textView.text = self.placeholder;
        textView.textColor = [UIColor CBGrayColor];
        textView.selectedTextRange = [textView textRangeFromPosition:textView.beginningOfDocument toPosition:textView.beginningOfDocument];
    } else {
        textView.textColor = [UIColor blackColor];
    }
    
    return YES;
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.categoties.count;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.categoties[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self.categoryTextField setText:self.categoties[row]];
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
