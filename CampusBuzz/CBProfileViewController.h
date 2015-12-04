//
//  CBProfileViewController.h
//  CampusBuzz
//
//  Created by Jorge Buzzi on 11/22/15.
//  Copyright © 2015 Jorge Buzzi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface CBProfileViewController : UIViewController

@property (nonatomic, strong) PFUser *user;

@end
