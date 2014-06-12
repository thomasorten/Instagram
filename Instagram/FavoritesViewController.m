//
//  FavoritesViewController.m
//  FavoritePhotos
//
//  Created by Thomas Orten on 6/2/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "FavoritesViewController.h"
#import "PhotoCollectionViewCell.h"
#import "Photo.h"
#import "User.h"
#import "MyButton.h"
#import "CommentViewController.h"
#import <Parse/Parse.h>

@interface FavoritesViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UITabBarControllerDelegate, UITabBarDelegate, UISearchBarDelegate>
@property NSString *selectedPhotoId;
@end

@implementation FavoritesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imagesArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MyFavoritesCell" forIndexPath:indexPath];

    NSArray *comments = [self.imagesArray objectAtIndex:indexPath.row][@"comments"];
    NSArray *likes = [self.imagesArray objectAtIndex:indexPath.row][@"likes"];
    NSString *photoId = [self.imagesArray objectAtIndex:indexPath.row][@"id"];
    NSString *firstComment = @"...";

    if (comments.count > 0) {
        firstComment = [comments firstObject];
    }

    cell.profileImageView.image = [self.imagesArray objectAtIndex:indexPath.row][@"profilePhoto"];
    cell.selectedImageView.image = [self.imagesArray objectAtIndex:indexPath.row][@"file"];
    cell.userNameLabel.text = [self.imagesArray objectAtIndex:indexPath.row][@"username"];
    [cell.commentsButton setTitle:firstComment forState:UIControlStateNormal];
    [cell.likesButton setTitle:@(likes.count).description forState:UIControlStateNormal];
    cell.commentThisButton.photoId = photoId;
    cell.likeThisButton.photoId = photoId;
    cell.likesButton.photoId = photoId;
    cell.commentsButton.photoId = photoId;

    return cell;
}

- (void)followUser:(NSString *)username
{
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:username];
    PFUser *followUser = [[query findObjects] firstObject];

    PFUser *currentUser = [PFUser currentUser];
    PFRelation *follow = [currentUser relationforKey:@"following"];
    [follow addObject:followUser];
    [currentUser saveInBackground];
}

- (void)unFollowUser:(NSString *)username
{
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:username];
    PFUser *followUser = [[query findObjects] firstObject];

    PFUser *currentUser = [PFUser currentUser];
    PFRelation *follow = [currentUser relationforKey:@"following"];
    [follow removeObject:followUser];
    [currentUser saveInBackground];
}

- (void)likePhoto:(NSString *)photoId
{
    PFObject *currentImage = [PFObject objectWithoutDataWithClassName:@"Photo" objectId:photoId];
    PFRelation *likes = [currentImage relationforKey:@"likes"];
    [likes addObject:[PFUser currentUser]];
    [currentImage saveInBackground];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self loginUser:@"user1" password:@"password"];
//[self signupUser:@"user5" password:@"password" email:@"user5@email.com"];

//    PFUser *user = [PFUser currentUser];
//    PFObject *photo = [PFObject objectWithClassName:@"Photo"];
//    photo[@"user"] = user;
//    [photo saveInBackground];

    [self.myFavoritesCollectionView reloadData];
}

- (void)loadPhotos:(PFUser *)user
{
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query whereKey:@"user" equalTo:user];
    [query includeKey:@"user"];
    [query orderByDescending:@"createdAt"];

    [query findObjectsInBackgroundWithBlock:^(NSArray *photos, NSError *error) {
        for (PFObject *object in photos) {
            if (object[@"photo"]) {
                PFFile *userImageFile = object[@"photo"];
                [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                    NSMutableArray *comments = [NSMutableArray new];
                    NSMutableArray *likes = [NSMutableArray new];
                    UIImage *profilePhoto = [[UIImage alloc] init];
                    if (object[@"comments"]) {
                        PFRelation *commentsRelation = [object relationForKey:@"comments"];
                        PFQuery *commentsQuery = [commentsRelation query];
                        [commentsQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
                            if (!error) {
                                 for (PFObject *comment in results) {
                                     if (comment[@"content"]) {
                                         [comments addObject:comment[@"content"]];
                                     }
                                 }
                            }
                            if (object[@"likes"]) {
                                PFRelation *likesRelation = [object relationForKey:@"likes"];
                                PFQuery *likesQuery = [likesRelation query];
                                [likesQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
                                    if (!error) {
                                        for (PFUser *likedUser in results) {
                                            if (likedUser[@"username"]) {
                                                [likes addObject:likedUser[@"username"]];
                                            }
                                        }
                                    }
                                    PFFile *userImageFile = object[@"user"][@"image"];
                                    if (userImageFile) {
                                        [userImageFile getDataInBackgroundWithBlock:^(NSData *profileData, NSError *error) {
                                            [self.imagesArray addObject:@{@"file" : [UIImage imageWithData:imageData], @"id" : object.objectId , @"comments": comments, @"likes": likes, @"username" : object[@"user"][@"username"], @"profilePhoto" :  [UIImage imageWithData:profileData]}];
                                            [self.myFavoritesCollectionView reloadData];
                                        }];
                                    } else {
                                        [self.imagesArray addObject:@{@"file" : [UIImage imageWithData:imageData], @"id" : object.objectId , @"comments": comments, @"likes": likes, @"username" : object[@"user"][@"username"]}];
                                    }
                                }];
                            }
                        }];
                    }
                }];
            }
        }
    }];
}

- (void)loadFollowing
{
    self.imagesArray = [NSMutableArray new];
    PFQuery *query = [PFUser query];
    [query whereKey:@"following" equalTo:[PFUser currentUser]];

    [query findObjectsInBackgroundWithBlock:^(NSArray *following, NSError *error) {
         for (PFUser *user in following) { // Show followers photos
             [self loadPhotos:user];
         }
         [self loadPhotos:[PFUser currentUser]]; // And my own photos
    }];
}

- (void)loginUser:(NSString *)username password:(NSString *)password
{
    [PFUser logInWithUsernameInBackground:username password:password
                                    block:^(PFUser *user, NSError *error) {
                                        if (user) {
                                            [self loadFollowing];
                                        }
                                    }];
}

- (void)signupUser:(NSString *)username password:(NSString *)password email:(NSString *)email
{
    PFUser *user = [PFUser user];
    user.username = username;
    user.password = password;
    user.email = email;

    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [self loginUser:user.username password:user.password];
        }
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"CommentSegue"]) {
        CommentViewController *vc = segue.destinationViewController;
        vc.photoId = self.selectedPhotoId;
    }
}

- (IBAction)onCommentButtonPressed:(MyButton *)sender
{
    self.selectedPhotoId = sender.photoId;
    [self performSegueWithIdentifier: @"CommentSegue" sender: self];
}

- (IBAction)onLikeButtonPressed:(MyButton *)sender
{
    [self likePhoto:sender.photoId];
}

@end
