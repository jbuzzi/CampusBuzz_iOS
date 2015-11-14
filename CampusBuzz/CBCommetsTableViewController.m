//
//  CBCommetsTableViewController.m
//  CampusBuzz
//
//  Created by Jorge Buzzi on 11/5/15.
//  Copyright © 2015 Jorge Buzzi. All rights reserved.
//

#import "CBCommetsTableViewController.h"
#import "CBCommentTableViewCell.h"
#import "RDRGrowingTextView.h"
#import "MBProgressHUD.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "NSDate+DisplayDates.h"

@interface CBCommetsTableViewController () <UITextViewDelegate, UIGestureRecognizerDelegate>

@end

@implementation CBCommetsTableViewController {
    UIToolbar *_toolbar;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Comments";
    self.tableView.tableFooterView = [UIView new];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 57.0;
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.0;
    lpgr.delegate = self;
    [self.tableView addGestureRecognizer:lpgr];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)queryComments {
    PFQuery *query = [PFQuery queryWithClassName:@"Comment"];
    [query whereKey:@"event" equalTo:self.event];
    [query orderByAscending:@"date"];
    [query includeKey:@"creator"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu events.", (unsigned long)objects.count);
            self.comments = objects;
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self.tableView reloadData];
            });
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)sendComment:(NSString *)content {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"";
    
    PFObject *comment = [PFObject objectWithClassName:@"Comment"];
    comment[@"content"] = content;
    comment[@"creator"] = [PFUser currentUser];
    comment[@"event"] = self.event;
    
    [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (!error) {
            [self queryComments];
        }
    }];
}

#pragma mark - Overrides

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (UIView *)inputAccessoryView {
    if (_toolbar) {
        return _toolbar;
    }
    
    _toolbar = [UIToolbar new];
    
    RDRGrowingTextView *textView = [RDRGrowingTextView new];
    textView.font = [UIFont systemFontOfSize:15.0f];
    textView.textContainerInset = UIEdgeInsetsMake(4.0f, 3.0f, 3.0f, 3.0f);
    textView.layer.cornerRadius = 4.0f;
    textView.layer.borderColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:205.0f/255.0f alpha:1.0f].CGColor;
    textView.layer.borderWidth = 1.0f;
    textView.layer.masksToBounds = YES;
    textView.returnKeyType =  UIReturnKeySend;
    textView.delegate = self;
    [_toolbar addSubview:textView];
    
    textView.translatesAutoresizingMaskIntoConstraints = NO;
    _toolbar.translatesAutoresizingMaskIntoConstraints = NO;
    
    [_toolbar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[textView]-8-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(textView)]];
    [_toolbar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[textView]-8-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(textView)]];
    
    [textView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [textView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [_toolbar setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    
    [_toolbar addConstraint:[NSLayoutConstraint constraintWithItem:_toolbar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:200]];
    
    return _toolbar;
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    
    if (indexPath == nil) {
        NSLog(@"Long press on table view but not on a row");
    } else if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        PFObject *comment = [self.comments objectAtIndex:indexPath.row];
        PFUser *creator = [comment objectForKey:@"creator"];
        if (creator == [PFUser currentUser]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *remove = [UIAlertAction actionWithTitle:@"Delete Comment" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
                [comment deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (!error) {
                        [self queryComments];
                    }
                }];
            }];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
            }];
            [alert addAction:remove];
            [alert addAction:cancel];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CBCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell" forIndexPath:indexPath];
    PFObject *comment = [self.comments objectAtIndex:indexPath.row];
    
    PFUser *creator = [comment objectForKey:@"creator"];
    PFFile *userImageFile = [creator objectForKey:@"image"];
    
    [cell.userImageView sd_setImageWithURL:[NSURL URLWithString:userImageFile.url]];
    cell.userLabel.text = [creator username];
    cell.timeLabel.text = [comment.createdAt timeAgo];
    cell.contentLabel.text = [comment objectForKey:@"content"] ;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.comments.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        NSString *comment = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (comment.length > 0) {
            [self sendComment:comment];
            textView.text = nil;
        }
        return NO;
    }
    return YES;
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
