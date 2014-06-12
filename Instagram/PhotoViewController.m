//
//  PhotoViewController.m
//  Instagram
//
//  Created by Ryan Tiltz on 6/10/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "PhotoViewController.h"
#import <Parse/Parse.h>
#import "FavoritesViewController.h"

@interface PhotoViewController () <UITextViewDelegate>


@end

@implementation PhotoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated
{
    [self loginUser:@"user1" password:@"password"];
}

- (void)loginUser:(NSString *)username password:(NSString *)password
{
    [PFUser logInWithUsernameInBackground:username password:password
                                    block:^(PFUser *user, NSError *error) {
                                        if (user) {
                                        }
                                    }];
}

- (IBAction)doneWithCaption:(id)sender
{
    [self.textView resignFirstResponder];
}

- (IBAction)clearCaption:(id)sender
{
    self.textView.text = @"";
}

- (IBAction)upload:(id)sender
{

    NSData *imageData = UIImagePNGRepresentation(self.imageView.image);
    PFFile *imageFile = [PFFile fileWithData:imageData];
    PFObject *userPhoto = [PFObject objectWithClassName:@"Photo"];

    //userPhoto[@"theCaption"] = self.textView.text;
    userPhoto[@"user"] = [PFUser currentUser];
    userPhoto[@"photo"] = imageFile;
    [userPhoto saveInBackground];


    self.imageView.image = nil;
    self.textView.text = @"Type a caption here";
}

#pragma mark - Methods and Actions according to taking photos

- (IBAction)selectPhoto:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    [self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)takePhoto:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;

    [self presentViewController:picker animated:YES completion:NULL];
    
}



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *pickedImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = pickedImage;

    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
@end
