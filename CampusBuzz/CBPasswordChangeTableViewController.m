//
//  CBPasswordChangeTableViewController.m
//  CampusBuzz
//
//  Created by Jorge Buzzi on 11/30/15.
//  Copyright © 2015 Jorge Buzzi. All rights reserved.
//

#import "CBPasswordChangeTableViewController.h"
#import <Parse/Parse.h>
#import "UIColor+AppColors.h"
#import "MBProgressHUD.h"

@interface CBPasswordChangeTableViewController ()

@property (weak, nonatomic) IBOutlet UITextField *currentPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordNewTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordNewConfirmationTextField;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@end

@implementation CBPasswordChangeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Change Password";
    
    //Set school color
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"SchoolColor" ofType:@"plist"];
    NSDictionary *colorDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    UIColor * mainColor = [UIColor colorFromHexString:[colorDictionary objectForKey:[[PFUser currentUser] objectForKey:@"school"]]];
    
    self.saveButton.layer.cornerRadius = 5.0f;
    self.saveButton.backgroundColor = mainColor;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)savePressed:(id)sender {
    if (self.currentPasswordTextField.text.length == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Enter your current passoword" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    } else if (self.passwordNewTextField.text.length < 8) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Enter a new password of minimum 8 characters" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    } else if (self.passwordNewConfirmationTextField.text.length == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Confrim your new password" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    } else if (![self.passwordNewTextField.text isEqualToString:self.passwordNewConfirmationTextField.text]){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Opps" message:@"New password do not match" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self.currentPasswordTextField resignFirstResponder];
        [self.passwordNewTextField resignFirstResponder];
        [self.passwordNewConfirmationTextField resignFirstResponder];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        [PFUser logInWithUsernameInBackground:[PFUser currentUser].username password:self.currentPasswordTextField.text block:^(PFUser *user, NSError *error) {
            if (user) {
                [PFUser currentUser].password = self.passwordNewConfirmationTextField.text;
                [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!error) {
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Password Updated" message:@"Your password has been updated. Use your new password from now on." preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                            [self.navigationController popViewControllerAnimated:YES];
                        }];
                        [alert addAction:ok];
                        [self presentViewController:alert animated:YES completion:nil];
                    }
                    else {
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Opps" message:@"There was an error please try again later." preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                        }];
                        [alert addAction:ok];
                        [self presentViewController:alert animated:YES completion:nil];
                    }
                    [hud hide:YES];
                }];
                
            } else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Incorrect credentials" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                }];
                [alert addAction:ok];
                [self presentViewController:alert animated:YES completion:nil];
                [hud hide:YES];
            }
        }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
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
