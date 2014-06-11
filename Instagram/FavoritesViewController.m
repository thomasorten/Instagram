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
#import <Parse/Parse.h>

@interface FavoritesViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UITabBarControllerDelegate, UITabBarDelegate, UISearchBarDelegate>
@property NSMutableArray *imagesArray;
@property (weak, nonatomic) IBOutlet UICollectionView *myFavoritesCollectionView;
@end

@implementation FavoritesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)load
{
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        if (!self.imagesArray)
        {
            self.imagesArray = [NSMutableArray array];
        }
        PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            for (PFObject *object in objects) {
                PFFile *userImageFile = object[@"photo"];
                [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                    if (!error) {
                        UIImage *image = [UIImage imageWithData:imageData];
                        [self.imagesArray addObject:image];
                        [self.myFavoritesCollectionView reloadData];
                    }
                }];
            }
        }];
    } else {

    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imagesArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MyFavoritesCell" forIndexPath:indexPath];
    cell.selectedImageView.image = [self.imagesArray objectAtIndex:indexPath.row];
    return cell;
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

- (void)loadUserPhotos
{
    PFUser *user = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query whereKey:@"user" equalTo:user];

    [query findObjectsInBackgroundWithBlock:^(NSArray *photos, NSError *error) {
        for (PFObject *object in photos) {
            PFFile *userImageFile = object[@"photo"];
            [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                if (!error) {
                    UIImage *image = [UIImage imageWithData:imageData];
                    [self.imagesArray addObject:image];
                    [self.myFavoritesCollectionView reloadData];
                }
            }];
        }
    }];
}

- (void)loginUser:(NSString *)username password:(NSString *)password
{
    [PFUser logInWithUsernameInBackground:username password:password
                                    block:^(PFUser *user, NSError *error) {
                                        if (user) {
                                            [self load];
                                            //[self loadUserPhotos];
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

@end
