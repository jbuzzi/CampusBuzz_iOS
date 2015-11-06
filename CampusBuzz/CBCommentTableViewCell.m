//
//  CBCommentTableViewCell.m
//  CampusBuzz
//
//  Created by Jorge Buzzi on 11/6/15.
//  Copyright © 2015 Jorge Buzzi. All rights reserved.
//

#import "CBCommentTableViewCell.h"

@implementation CBCommentTableViewCell

- (void)awakeFromNib {
    self.userImageView.layer.masksToBounds = YES;
    self.userImageView.layer.cornerRadius = self.userImageView.frame.size.height/2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
