//
//  User.h
//  Instagram
//
//  Created by Thomas Orten on 6/10/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface User : NSObject

+ (id)parseClassName;

@property NSString *email;
@property PFFile *profilePhoto;

@end
