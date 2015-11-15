//
//  CBAddEventTableViewController.h
//  CampusBuzz
//
//  Created by Jorge Buzzi on 10/2/15.
//  Copyright © 2015 Jorge Buzzi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface CBAddEventTableViewController : UITableViewController

@property (strong, nonatomic) PFObject *event;
@property (assign, nonatomic) BOOL editMode;

@end
