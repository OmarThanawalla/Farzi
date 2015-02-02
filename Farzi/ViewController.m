//
//  ViewController.m
//  Farzi
//
//  Created by Omar Thanawalla on 1/23/15.
//  Copyright (c) 2015 Omar Thanawalla. All rights reserved.
//

#import "ViewController.h"
#import <GoogleMaps/GoogleMaps.h>
@import CoreLocation;
@import CoreMotion;

@interface ViewController () <CLLocationManagerDelegate>

@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) int locationEvents;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (nonatomic, strong) CMMotionActivityManager *motionActivityManager;
@property (weak, nonatomic) IBOutlet UILabel *activityLabel;

@end

@implementation ViewController

- (void)viewDidLoad
{
    NSLog(@"viewDidLoad");
    
    [super viewDidLoad];
    self.locationEvents = 0;
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    
    [self.locationManager requestAlwaysAuthorization];
    //[self.locationManager startMonitoringSignificantLocationChanges];
    [self.locationManager startMonitoringVisits];
    
    self.motionActivityManager = [[CMMotionActivityManager alloc]init];
    [self.motionActivityManager startActivityUpdatesToQueue:[[NSOperationQueue alloc]init] withHandler:^(CMMotionActivity *activity) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([activity stationary]) {
                NSLog(@"stationary");
                self.activityLabel.text = @"stationary";
                self.activityLabel.backgroundColor = [UIColor blueColor];
            }
            else if ([activity walking]) {
                NSLog(@"walking");
                self.activityLabel.text = @"walking";
                self.activityLabel.backgroundColor = [UIColor orangeColor];

            }
            else if ([activity running]) {
                NSLog(@"running");
                self.activityLabel.text = @"running";
                self.activityLabel.backgroundColor = [UIColor redColor];

            }
            else if ([activity automotive]){
                NSLog(@"automativie");
                self.activityLabel.text = @"automativie";
                self.activityLabel.backgroundColor = [UIColor greenColor];

            }
            else if ([activity cycling]){
                NSLog(@"cycling");
                self.activityLabel.text = @"cycling";
                self.activityLabel.backgroundColor = [UIColor yellowColor];

            }
        });
    }];
    
//    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//    self.locationManager.distanceFilter = kCLDistanceFilterNone; // meters
    
//    [self.locationManager startUpdatingLocation];

    
    // Do any additional setup after loading the view, typically from a nib.
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86
                                                            longitude:151.20
                                                                 zoom:14];
    
    self.mapView = [GMSMapView mapWithFrame:CGRectMake(0, 150, 320, 400) camera:camera];
    self.mapView.myLocationEnabled = YES;
    [self.view addSubview:self.mapView];
    
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(-33.86, 151.20);
    marker.title = @"Sydney";
    marker.snippet = @"Australia";
    marker.map = self.mapView;
    
    //UILocalNotification
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    localNotif.fireDate = [[NSDate alloc]initWithTimeIntervalSinceNow:10];
    localNotif.alertAction = @"View details";
    localNotif.alertBody = @"Body";
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    NSLog(@"sig loc change");
    self.locationEvents++;
    CLLocation *location = [locations lastObject];
    NSLog(@"User's latitude is: %f", location.coordinate.latitude );
    NSLog(@"User's longitude is: %f", location.coordinate.longitude );

    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude
                                                            longitude:location.coordinate.longitude
                                                                 zoom:14];
//    [self.mapView moveCamera:[GMSCameraUpdate setCamera:camera]];
    self.mapView.camera = camera;
    
    GMSMarker *marker = [[GMSMarker alloc]init];
    marker.position = location.coordinate;
    marker.map = self.mapView;

    self.statusLabel.text = [NSString stringWithFormat:@"%i Significant location change update",self.locationEvents];

}

- (void)locationManager:(CLLocationManager *)manager
               didVisit:(CLVisit *)visit
{
    NSLog(@"visit");
    self.locationEvents++;
    NSLog(@"User's latitude is: %f", visit.coordinate.latitude );
    NSLog(@"User's longitude is: %f", visit.coordinate.longitude );
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:visit.coordinate.latitude
                                                            longitude:visit.coordinate.longitude
                                                                 zoom:14];
    self.mapView.camera = camera;
    
    GMSMarker *marker = [[GMSMarker alloc]init];
    marker.position = visit.coordinate;
    marker.map = self.mapView;
    
    self.statusLabel.text = [NSString stringWithFormat:@"%i Visit",self.locationEvents];
    
    
}

@end
