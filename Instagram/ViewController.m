//
//  ViewController.m
//  FavoritePhotos
//
//  Created by Thomas Orten on 6/2/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "ViewController.h"
#import "PhotoCollectionViewCell.h"

#define kLatestUpdatekey @"Latest Update"

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UITabBarControllerDelegate, UITabBarDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
@property NSMutableArray *imagesArray;
@property NSMutableArray *favoritesArray;
@property (weak, nonatomic) IBOutlet UICollectionView *myCollectionView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property NSMutableArray *selectedCellIndexes;
@property NSArray *searchResults;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.favoritesArray = [[NSMutableArray alloc] init];
    self.selectedCellIndexes = [[NSMutableArray alloc] init];
    self.myTableView.hidden = YES;
}

- (void)getPhotosByTerm:(NSString *)searchTerm
{
    self.imagesArray = [[NSMutableArray alloc] init];

    NSString *searchString = [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=9401ce3d1573537ff059cca44fe122f4&text=%@&content_type=1&extras=url_m&per_page=10&format=json&nojsoncallback=1", searchTerm];
    NSURL *url = [NSURL URLWithString:searchString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&connectionError];
        NSArray *images = [[json objectForKey:@"photos"] objectForKey:@"photo"];
        for (NSDictionary *imageDictionary in images) {
            [self.imagesArray addObject:[imageDictionary objectForKey:@"url_m"]];
        }
        [self.myTableView reloadData];
    }];

}

- (void)save
{
    NSURL *imagelist = [[self documentsDirectory] URLByAppendingPathComponent:@"images.plist"];
    [self.favoritesArray writeToURL:imagelist atomically:YES];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSDate date] forKey:kLatestUpdatekey];
    [defaults synchronize];
}

- (NSURL *)documentsDirectory
{
    return [[[NSFileManager defaultManager]URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask]firstObject];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imagesArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"myCell" forIndexPath:indexPath];
    cell.alpha = 1.0;
    NSURL *url = [NSURL URLWithString:[self.imagesArray objectAtIndex:indexPath.row]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        cell.theImageView.image = [UIImage imageWithData:data];
    }];
    
    if ([self.favoritesArray containsObject:[self.imagesArray objectAtIndex:indexPath.row]]) {
        cell.theImageView.alpha = 0.5;
    } else {
        cell.theImageView.alpha = 1.0;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCollectionViewCell *cell = (PhotoCollectionViewCell *) [collectionView cellForItemAtIndexPath:indexPath];
    if ([self.favoritesArray containsObject:[self.imagesArray objectAtIndex:indexPath.row]]) {
        cell.theImageView.alpha = 1.0;
        [self.favoritesArray removeObject:[self.imagesArray objectAtIndex:indexPath.row]];
    } else {
        cell.theImageView.alpha = 0.5;
        [self.favoritesArray addObject:[self.imagesArray objectAtIndex:indexPath.row]];
    }
    [self save];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self getPhotosByTerm:searchBar.text];
    [searchBar resignFirstResponder];

    //self.myTableView.hidden = YES;
   //self.myCollectionView.hidden = NO;
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{


    self.myCollectionView.hidden = YES;
    self.myTableView.hidden = NO;
}



#pragma mark - UITableView Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.imagesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyCell"];
    cell.alpha = 1.0;
    NSURL *url = [NSURL URLWithString:[self.imagesArray objectAtIndex:indexPath.row]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        cell.imageView.image = [UIImage imageWithData:data];
    }];

    if ([self.favoritesArray containsObject:[self.imagesArray objectAtIndex:indexPath.row]]) {
        cell.imageView.alpha = 0.5;
    } else {
        cell.imageView.alpha = 1.0;
    }
    return cell;
}
@end
