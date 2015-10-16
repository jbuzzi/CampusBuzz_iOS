//
//  UIColor+AppColors.h
//
//  Created by Jorge Buzzi on 3/31/15.
//  Copyright (c) 2015 Jorge Buzzi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (AppColors)

+ (UIColor *) colorFromHexString:(NSString *)hexString;
+ (UIColor *) CBBlueColor;
+ (UIColor *) CBLightGrayColor;
+ (UIColor *) CBGrayColor;

@end
