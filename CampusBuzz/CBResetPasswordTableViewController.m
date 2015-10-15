//
//  CBResetPasswordTableViewController.m
//  CampusBuzz
//
//  Created by Jorge Buzzi on 9/29/15.
//  Copyright © 2015 Jorge Buzzi. All rights reserved.
//

#import "CBResetPasswordTableViewController.h"
#import "UIColor+AppColors.h"

@interface CBResetPasswordTableViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailTextFields;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@end

@implementation CBResetPasswordTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.emailTextFields.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"School Email" attributes:@{NSForegroundColorAttributeName:[UIColor CBGrayColor]}];
    
    self.sendButton.layer.cornerRadius = 5.0f;
    
    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Show navigation bar
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (IBAction)sendButtonPressed:(id)sender {
    [self.emailTextFields resignFirstResponder];
    
    NSString * email = [self.emailTextFields.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    [PFUser requestPasswordResetForEmailInBackground:email block:^(BOOL succeeded, NSError *error) {
        if (!error) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Done!" message:[NSString stringWithFormat:@"Instructions to reset you password have been sent to %@", email] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
                [self.navigationController popViewControllerAnimated:YES];
            }];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
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
