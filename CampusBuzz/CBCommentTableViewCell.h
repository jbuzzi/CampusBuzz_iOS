//
//  CBCommentTableViewCell.h
//  CampusBuzz
//
//  Created by Jorge Buzzi on 11/6/15.
//  Copyright © 2015 Jorge Buzzi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CBCommentTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end
