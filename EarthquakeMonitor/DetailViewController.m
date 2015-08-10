//
//  DetailViewController.m
//  EarthquakeMonitor
//
//  Created by Rubén Jacobo on 10/08/15.
//
//

#import "DetailViewController.h"
#import <GoogleMaps/GMSMarker.h>

@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"DETAIL DATA = %@",_detailData);
    
    
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    
    double longitude = [[_detailData objectForKey:@"longitude"] doubleValue];
    double latitude = [[_detailData objectForKey:@"latitude"] doubleValue];
    double depth = [[_detailData objectForKey:@"depth"]doubleValue];
    UIColor *color = [_detailData objectForKey:@"color"];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:latitude
                                                            longitude:longitude
                                                                 zoom:5];
    _mapView.myLocationEnabled = YES;
    [_mapView setCamera:camera];
    //self.view = mapView_;
    
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.icon = [GMSMarker markerImageWithColor:color];
    marker.position = CLLocationCoordinate2DMake(latitude, longitude);
    marker.title = @"Sydney";
    marker.snippet = @"Australia";
    marker.map = _mapView;
    
    _lblPlace.text = [_detailData objectForKey:@"place"];
    _lblTime.text = [_detailData objectForKey:@"date"];
    _lblLocation.text = [NSString stringWithFormat:@"%.3f°N %.3f°W",latitude,longitude];
    _lblDepth.text = [NSString stringWithFormat:@"%.1f km",depth];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
