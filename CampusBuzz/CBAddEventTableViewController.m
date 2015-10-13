//
//  CBAddEventTableViewController.m
//  CampusBuzz
//
//  Created by Jorge Buzzi on 10/2/15.
//  Copyright © 2015 Jorge Buzzi. All rights reserved.
//

#import "CBAddEventTableViewController.h"
#import "UIColor+AppColors.h"

@interface CBAddEventTableViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *eventImageView;
@property (weak, nonatomic) IBOutlet UIButton *addImageButton;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
@property (weak, nonatomic) IBOutlet UITextField *dateTextField;
@property (weak, nonatomic) IBOutlet UIButton *createButton;

@property (assign) NSString *placeholder;

@end

@implementation CBAddEventTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Set school color
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"SchoolColor" ofType:@"plist"];
    NSDictionary *colorDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    UIColor * mainColor = [UIColor colorFromHexString:[colorDictionary objectForKey:@"Boston University"]];
    
    self.createButton.backgroundColor = mainColor;
    
    self.placeholder = @"Description   ";
    self.descriptionTextView.text = self.placeholder;
    self.descriptionTextView.delegate = self;
    self.descriptionTextView.contentInset = UIEdgeInsetsMake(10, 0, 10, 0);
    
    self.createButton.layer.cornerRadius = 5.0f;
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    NSDate *currentDate = [NSDate date];
    [datePicker setMinimumDate:currentDate];
    self.dateTextField.inputView = datePicker;
}

- (IBAction)createPressed:(id)sender {
    
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
            controller.allowsEditing = YES;
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
    
    [self.dateTextField setText:[dateFormatter stringFromDate:sender.date]];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    switch (indexPath.row) {
        case 0:
            return 215;
        case 1:
            return 110;
        case 2:
            return 60;
        case 3:
            return 60;
        case 4:
            return 60;
        case 5: {
            float height = screenHeight - 215 - 110 - 60 - 60 - 60 - 64;
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
    UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
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
        textView.textColor = [UIColor CBLightGrayColor];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if(range.length + range.location > textView.text.length) {
        return NO;
    }
    
    if ([textView.text isEqualToString:self.placeholder]) {
        textView.text = @"";
        textView.textColor = [UIColor CBLightGrayColor];
    } else {
        textView.textColor = [UIColor blackColor];
    }
    
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    if (newLength == 0) {
        textView.text = self.placeholder;
        textView.textColor = [UIColor CBLightGrayColor];
        textView.selectedTextRange = [textView textRangeFromPosition:textView.beginningOfDocument toPosition:textView.beginningOfDocument];
    } else {
        textView.textColor = [UIColor blackColor];
    }
    
    return YES;
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
