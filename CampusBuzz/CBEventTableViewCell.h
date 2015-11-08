//
//  CBEventTableViewCell.h
//  CampusBuzz
//
//  Created by Jorge Buzzi on 10/24/15.
//  Copyright © 2015 Jorge Buzzi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CBEventTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *eventImageView;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *attendeesLabel;

@end
