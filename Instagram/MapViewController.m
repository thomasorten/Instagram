//
//  MapViewController.m
//  Instagram
//
//  Created by Ryan Tiltz on 6/12/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>

@interface MapViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;


@end

@implementation ViewController

- (void)viewDidLoad

{
    [super viewDidLoad];
	self.mobileMakersAnnotation = [[MKPointAnnotation alloc] init];
    self.mobileMakersAnnotation.coordinate = CLLocationCoordinate2DMake(41.89373984, -87.63532979);
    self.mobileMakersAnnotation.title = @"Mobile Makers HQ";
    [self.mapView addAnnotation:self.mobileMakersAnnotation];



    self.mapView.showsUserLocation = YES;
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if (annotation == self.mobileMakersAnnotation)
    {
        MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
        pin.canShowCallout = YES;
        pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];

        if (annotation == self.mobileMakersAnnotation)
        {
            pin.image = [UIImage imageNamed:@"mobilemakers"];

        return pin;

    }

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    CLLocationCoordinate2D centerCoordinate = view.annotation.coordinate;
    MKCoordinateSpan span = MKCoordinateSpanMake(.01, .01);
    MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, span);
    [self.mapView setRegion:region animated:YES];
    
}
    
@end
