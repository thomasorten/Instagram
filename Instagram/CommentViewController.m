//
//  CommentViewController.m
//  Instagram
//
//  Created by Thomas Orten on 6/12/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "CommentViewController.h"
#import <Parse/Parse.h>

@interface CommentViewController ()
@property (weak, nonatomic) IBOutlet UITextView *commentTextField;

@end

@implementation CommentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (IBAction)onCommentPressed:(id)sender
{
    PFObject *comment = [PFObject objectWithClassName:@"Comment"];
    comment[@"content"] = self.commentTextField.text;
    comment[@"user"] = [PFUser currentUser];

    [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            PFObject *currentImage = [PFObject objectWithoutDataWithClassName:@"Photo" objectId:self.photoId];
            PFRelation *comments = [currentImage relationforKey:@"comments"];
            [comments addObject:comment];

            [currentImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }];
        }
    }];
}

- (IBAction)onCancelPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)dismissKeyboard {
    [self.commentTextField resignFirstResponder];
}

@end
