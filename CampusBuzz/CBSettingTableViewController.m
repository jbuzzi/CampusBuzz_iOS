//
//  CBSettingTableViewController.m
//  CampusBuzz
//
//  Created by Jorge Buzzi on 11/22/15.
//  Copyright © 2015 Jorge Buzzi. All rights reserved.
//

#import "CBSettingTableViewController.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "MBProgressHUD.h"

@interface CBSettingTableViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *usernameValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailValueLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;


@end

@implementation CBSettingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.userImageView.layer.masksToBounds = YES;
    self.userImageView.layer.cornerRadius = self.userImageView.layer.frame.size.height/2;
    
    [self setupUser];
}

- (void)setupUser {
    self.usernameValueLabel.text = [PFUser currentUser].username;
    self.emailValueLabel.text = [PFUser currentUser].email;
    
    
    PFFile *userImageFile = [[PFUser currentUser] objectForKey:@"image"];
    NSURL *url = [NSURL URLWithString:userImageFile.url];
    [self.userImageView sd_setImageWithURL:url];
}

- (void)addImagePressed {
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        return 4;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.section == 1) {
            //Change email
        } else if (indexPath.row == 2) {
            //Change password
        } else if (indexPath.row == 3) {
            //Change profile picture
            [self addImagePressed];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            //Log out
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Are you sure you want to logout?" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
            }];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Log Out" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                [PFUser logOut];
                
                UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
                UIViewController *theTabBar = (UIViewController *)[secondStoryBoard instantiateViewControllerWithIdentifier:@"login"];
                [self.navigationController pushViewController:theTabBar animated:YES];
            }];
            [alert addAction:cancel];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
        } else if (indexPath.row == 1) {
            //Delete account
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirm Account Deletion" message:@"This action is permanent and cannot be undone. All your account information will be erased." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
            }];
            UIAlertAction *delete = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
                
                //Delete user account
            }];
            [alert addAction:cancel];
            [alert addAction:delete];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self.navigationController dismissViewControllerAnimated: YES completion: nil];
    UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
    [self.userImageView setImage:image];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"";
    
    PFUser *user = [PFUser currentUser];
    
    if (self.userImageView.image) {
        NSData *imageData = UIImageJPEGRepresentation(self.userImageView.image, 0.5f);
        PFFile *imageFile = [PFFile fileWithName:@"user_image.jpg" data:imageData];
        [user setObject:imageFile forKey:@"image"];
    }
    
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker; {
    [self.navigationController dismissViewControllerAnimated: YES completion: nil];
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
