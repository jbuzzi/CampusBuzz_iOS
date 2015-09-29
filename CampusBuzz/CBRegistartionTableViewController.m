//
//  CBRegistartionTableViewController.m
//  CampusBuzz
//
//  Created by Jorge Buzzi on 9/29/15.
//  Copyright © 2015 Jorge Buzzi. All rights reserved.
//

#import "CBRegistartionTableViewController.h"

@interface CBRegistartionTableViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *createButton;
@property (weak, nonatomic) IBOutlet UIButton *securePasswordButton;

@end

@implementation CBRegistartionTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.userImageView.layer.cornerRadius = self.userImageView.frame.size.height/2;
    self.createButton.layer.cornerRadius = 5.0f;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Show navigation bar
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (IBAction)createPressed:(id)sender {
    
}

- (IBAction)addImagePressed:(id)sender {
    
}

- (IBAction)securePasswordPressed:(id)sender {
    if (self.passwordTextField.isSecureTextEntry) {
        [self.securePasswordButton setTitle:@"Hide" forState:UIControlStateNormal];
        [self.passwordTextField setSecureTextEntry:NO];
    } else {
        [self.securePasswordButton setTitle:@"Show" forState:UIControlStateNormal];
        [self.passwordTextField setSecureTextEntry:YES];
    }
}

- (BOOL)validateEmail:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    if (![emailTest evaluateWithObject:email]) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    switch (indexPath.row) {
        case 0:
            return screenHeight - 420 - 64;
        case 1:
            return 60;
        case 2:
            return 60;
        case 3:
            return 60;
        case 4:
            return 60;
        case 5:
            return 60;
        case 6:
            return 120;
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
