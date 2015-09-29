//
//  ViewController.m
//  CampusBuzz
//
//  Created by Jorge Buzzi on 9/28/15.
//  Copyright (c) 2015 Jorge Buzzi. All rights reserved.
//

#import "CBViewController.h"

@interface CBViewController ()

@end

@implementation CBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PFObject *testObject = [PFObject objectWithClassName:@"TestObject"];
    testObject[@"foo"] = @"bar";
    [testObject saveInBackground];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
