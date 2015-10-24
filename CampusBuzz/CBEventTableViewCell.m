//
//  CBEventTableViewCell.m
//  CampusBuzz
//
//  Created by Jorge Buzzi on 10/24/15.
//  Copyright © 2015 Jorge Buzzi. All rights reserved.
//

#import "CBEventTableViewCell.h"

@implementation CBEventTableViewCell

- (void)awakeFromNib {
    self.userImageView.layer.masksToBounds = YES;
    self.userImageView.layer.cornerRadius = self.userImageView.frame.size.height/2;
    self.userImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.userImageView.layer.borderWidth = 2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
