//
//  ViewController.h
//  EarthquakeMonitor
//
//  Created by Rubén Jacobo on 10/08/15.
//
//

#import <UIKit/UIKit.h>
@import GoogleMaps;

@class DetailViewController;

@interface ViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UIRefreshControl *refreshControl;
@property(nonatomic,strong)IBOutlet UITableView *tblSummary;
@property(nonatomic,strong)NSArray *items;
@property(nonatomic,strong)IBOutlet UILabel *lblEmpty;
@property(nonatomic,strong)IBOutlet DetailViewController *detailView;
@property(nonatomic,strong)IBOutlet GMSMapView *mapView;
@property(nonatomic,strong)UIBarButtonItem *btnRefresh;
@property(nonatomic,strong)NSString *test;
@property(nonatomic,strong)NSDictionary *summaryData;

@end

