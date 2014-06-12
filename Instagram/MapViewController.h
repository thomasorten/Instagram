//
//  MapViewController.h
//  Instagram
//
//  Created by Ryan Tiltz on 6/12/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "ViewController.h"
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@interface MapViewController : UIViewController
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@end