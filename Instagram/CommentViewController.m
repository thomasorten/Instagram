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

@end

@implementation CommentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)commentOnPhoto
{
    PFObject *comment = [PFObject objectWithClassName:@"Comment"];
    comment[@"content"] = @"This is awesome";
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

@end
