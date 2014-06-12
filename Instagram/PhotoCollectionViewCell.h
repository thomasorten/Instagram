//
//  myCell.h
//  FavoritePhotos
//
//  Created by Thomas Orten on 6/2/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyButton.h"

@interface PhotoCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *theImageView;
@property (weak, nonatomic) IBOutlet UIButton *checkMarkButton;
@property (weak, nonatomic) IBOutlet MyButton *likesButton;
@property (weak, nonatomic) IBOutlet MyButton *commentsButton;
@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;
@property NSString *photoId;
@end
