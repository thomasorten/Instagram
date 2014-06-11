//
//  PhotoViewController.h
//  Instagram
//
//  Created by Ryan Tiltz on 6/10/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "ViewController.h"

@interface PhotoViewController : ViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UITextView *textView;
- (IBAction)selectPhoto:(id)sender;
- (IBAction)takePhoto:(id)sender;
- (IBAction)doneWithCaption:(id)sender;
- (IBAction)clearCaption:(id)sender;
- (IBAction)upload:(id)sender;

@property UIImage *image;



@end
