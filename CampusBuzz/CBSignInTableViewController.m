//
//  CBSignInTableViewController.m
//  CampusBuzz
//
//  Created by Jorge Buzzi on 9/29/15.
//  Copyright © 2015 Jorge Buzzi. All rights reserved.
//

#import "CBSignInTableViewController.h"

@interface CBSignInTableViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;

@end

@implementation CBSignInTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.signInButton.layer.cornerRadius = 5.0f;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Hide navigation bar
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

- (IBAction)signInPressed:(id)sender {
    
}

- (IBAction)forgotPasswordPressed:(id)sender {
    
}

- (IBAction)createAccountPressed:(id)sender {
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
