//
//  CBSignInTableViewController.m
//  CampusBuzz
//
//  Created by Jorge Buzzi on 9/29/15.
//  Copyright © 2015 Jorge Buzzi. All rights reserved.
//

#import "CBSignInTableViewController.h"
#import "MBProgressHUD.h"

@interface CBSignInTableViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;

@property (strong, nonatomic) NSArray *fieldArray;

@end

@implementation CBSignInTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:self.view.window];
    
    self.usernameTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.fieldArray = [NSArray arrayWithObjects:self.usernameTextField, self.passwordTextField, nil];

    self.signInButton.layer.cornerRadius = 5.0f;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Hide navigation bar
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

- (IBAction)signInPressed:(id)sender {
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    
    NSString * username = [self.usernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString * password = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (!username.length || !password.length) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Opps!" message:@"All fields must be complete" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"";
        [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
            if (user) {
                NSLog(@"User sign in successful");
                [self performSegueWithIdentifier:@"Enter" sender:self];
            } else {
                NSString *errorString = [NSString stringWithFormat:@"%@%@",[[error.localizedDescription substringToIndex:1] uppercaseString],[error.localizedDescription substringFromIndex:1]];
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Opps!" message:errorString preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                    [alert dismissViewControllerAnimated:YES completion:nil];
                }];
                [alert addAction:ok];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }];

    }
}

- (void)scrollToTheBottom:(BOOL)animated
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:3 inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    switch (indexPath.row) {
        case 0:
            return screenHeight - 60 - 60 - 120 - 20;
        case 1:
            return 60;
        case 2:
            return 60;
        case 3:
            return 120;
        default:
            return 0;
    }
    
    return 0;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSUInteger index = [self.fieldArray indexOfObject:textField];
    if (index == NSNotFound || index + 1 == self.fieldArray.count) {
        [textField resignFirstResponder];
        return NO;
    }
    
    id nextField = [self.fieldArray objectAtIndex:index + 1];
    [nextField becomeFirstResponder];
    
    return NO;
}

#pragma mark - Keyboard Show/Hide

- (void)keyboardWillShow:(NSNotification *)notification {
    // When keyboard shows scroll to bottom of screen
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self scrollToTheBottom:YES];
    });
}

- (void)keyboardWillHide:(NSNotification *)notification {
    // When keyboard hides scroll to bottom of screen
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self scrollToTheBottom:YES];
    });
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
