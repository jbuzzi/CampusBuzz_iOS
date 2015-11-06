//
//  CBEventDetailTableViewController.h
//  CampusBuzz
//
//  Created by Jorge Buzzi on 10/26/15.
//  Copyright © 2015 Jorge Buzzi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface CBEventDetailTableViewController : UITableViewController

@property (strong, nonatomic) PFObject *event;

@end
