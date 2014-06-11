//
//  Photo.h
//  Instagram
//
//  Created by Thomas Orten on 6/10/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Photo : PFObject <PFSubclassing>

+ (id)parseClassName;

@property PFFile *photo;

@end

