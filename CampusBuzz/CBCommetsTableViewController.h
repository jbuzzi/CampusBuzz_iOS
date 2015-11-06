//
//  CBCommetsTableViewController.h
//  CampusBuzz
//
//  Created by Jorge Buzzi on 11/5/15.
//  Copyright © 2015 Jorge Buzzi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface CBCommetsTableViewController : UITableViewController

@property (strong, nonatomic) PFObject *event;
@property (strong, nonatomic) NSArray *comments;

@end
