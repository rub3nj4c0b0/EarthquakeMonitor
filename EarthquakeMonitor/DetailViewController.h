//
//  DetailViewController.h
//  EarthquakeMonitor
//
//  Created by Rubén Jacobo on 10/08/15.
//
//

#import <UIKit/UIKit.h>
@import GoogleMaps;

@interface DetailViewController : UIViewController

@property(nonatomic,strong)NSDictionary *detailData;
@property(nonatomic,weak)IBOutlet GMSMapView *mapView;
@property (strong, nonatomic) IBOutlet UILabel *lblPlace;
@property (strong, nonatomic) IBOutlet UILabel *lblTime;
@property (strong, nonatomic) IBOutlet UILabel *lblLocation;
@property (strong, nonatomic) IBOutlet UILabel *lblDepth;
@end
