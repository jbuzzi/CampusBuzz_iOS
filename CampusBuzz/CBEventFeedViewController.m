//
//  CBEventFeedViewController.m
//  CampusBuzz
//
//  Created by Jorge Buzzi on 10/1/15.
//  Copyright © 2015 Jorge Buzzi. All rights reserved.
//

#import "CBEventFeedViewController.h"

@interface CBEventFeedViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *filtersScrollView;

@end

@implementation CBEventFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createScrollMenu];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createScrollMenu {
    int x = 5;
    for (int i = 0; i < 10; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(x, 5, 54, 54)];
        [button setBackgroundColor:[UIColor greenColor]];
        button.layer.cornerRadius = button.frame.size.height/2;
        [button setTitle:[NSString stringWithFormat:@"B %d", i] forState:UIControlStateNormal];
        
        [self.filtersScrollView addSubview:button];
        
        x += button.frame.size.width + 5;
    }
    
    self.filtersScrollView.contentSize = CGSizeMake(x, self.filtersScrollView.frame.size.height);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
