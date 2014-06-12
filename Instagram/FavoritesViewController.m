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
#import <Parse/Parse.h>

@interface FavoritesViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UITabBarControllerDelegate, UITabBarDelegate, UISearchBarDelegate>

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

    cell.selectedImageView.image = [self.imagesArray objectAtIndex:indexPath.row][@"file"];
    [cell.commentsButton setTitle:@(comments.count).description forState:UIControlStateNormal];
    [cell.likesButton setTitle:@(likes.count).description forState:UIControlStateNormal];
    cell.commentsButton.photoId = photoId;
    cell.likesButton.photoId = photoId;

    return cell;
}

- (void)commentOnPhoto:(NSString *)photoId
{
    PFObject *comment = [PFObject objectWithClassName:@"Comment"];
    comment[@"content"] = @"This is awesome";
    comment[@"user"] = [PFUser currentUser];
    [comment save];

    PFObject *currentImage = [PFObject objectWithoutDataWithClassName:@"Photo" objectId:photoId];
    PFRelation *comments = [currentImage relationforKey:@"comments"];
    [comments addObject:comment];
    [currentImage saveInBackground];
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
    [query orderByDescending:@"createdAt"];

    [query findObjectsInBackgroundWithBlock:^(NSArray *photos, NSError *error) {
        for (PFObject *object in photos) {
            if (object[@"photo"]) {
                PFFile *userImageFile = object[@"photo"];
                [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                    NSMutableArray *comments = [NSMutableArray new];
                    NSMutableArray *likes = [NSMutableArray new];
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
                                    [self.imagesArray addObject:@{@"file" : [UIImage imageWithData:imageData], @"id" : object.objectId , @"comments": comments, @"likes": likes}];
                                    [self.myFavoritesCollectionView reloadData];

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

- (IBAction)onCommentButtonPressed:(MyButton *)sender
{
    [self commentOnPhoto:sender.photoId];
}

- (IBAction)onLikeButtonPressed:(MyButton *)sender
{
    [self likePhoto:sender.photoId];
}

@end
