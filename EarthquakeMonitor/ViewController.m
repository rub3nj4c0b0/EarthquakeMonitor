//
//  ViewController.m
//  EarthquakeMonitor
//
//  Created by Rubén Jacobo on 10/08/15.
//
//

#import "ViewController.h"
#import "EarthquakeTableViewCell.h"
#import "DetailViewController.h"

#define UIColorFromRGBWithAlpha(rgbValue,a) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Summary";
    
    _btnRefresh = [[UIBarButtonItem alloc]
                   initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                   target:self
                   action:@selector(refreshTable)];
    self.navigationItem.rightBarButtonItem = _btnRefresh;

    _refreshControl = [[UIRefreshControl alloc]init];
    _refreshControl.tintColor = [UIColor blackColor];
    [_refreshControl addTarget:self action:@selector(downloadData) forControlEvents:UIControlEventValueChanged];
    _tblSummary.delegate = self;
    _tblSummary.dataSource = self;
    
    [self.tblSummary addSubview:_refreshControl];
    [self downloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshTable
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.refreshControl beginRefreshing];
    });
    
    [self downloadData];
}

-(void)stopRefresh
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.refreshControl endRefreshing];
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"EarthquakeCell";
    
    EarthquakeTableViewCell *cell = (EarthquakeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    if(cell == nil){
        cell = [[EarthquakeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    
    NSDictionary *feature = [_items objectAtIndex:indexPath.row];
    NSDictionary *properties = [feature objectForKey:@"properties"];
    
    cell.lblPlace.text = [properties objectForKey:@"place"];
    cell.lblMagnitude.text = [NSString stringWithFormat:@"%@",[properties objectForKey:@"mag"]];
    
    double mag = [[properties objectForKey:@"mag"] doubleValue];
    cell.backgroundColor = [self getColorForMagnitude:mag];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([_items count] >0)
    {
        _tblSummary.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _lblEmpty.hidden = YES;
        _tblSummary.hidden = NO;
        _mapView.hidden = NO;
        
        return 1;
    }
    else
    {
        _lblEmpty.hidden = NO;
        _mapView.hidden = YES;
        self.title = @"Summary";
        _tblSummary.separatorStyle = UITableViewCellSeparatorStyleNone;
        return 0;
    }
}

-(void)downloadData
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        _btnRefresh.enabled = NO;
    });
    
    NSString *urlString = @"http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_hour.geojson";
    //NSString *urlString = @"http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson";
    NSURL *url = [NSURL URLWithString:urlString]; ;
    
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:url];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    
    if (error || !data)
    {
        NSLog(@"Download did fail !");
        _items = nil;
    }
    else
    {
        NSLog(@"Successfull Download !");
        NSError *jsonError;
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
        
        if (dictionary)
        {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
            [defaults setObject:data forKey:@"cache"];
            [defaults synchronize];
        }
    }
    [self stopRefresh];
    
    [self loadCache];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        _btnRefresh.enabled = YES;
    });
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath =  [_tblSummary indexPathForSelectedRow];
        _test = [NSString stringWithFormat:@"ROW %li",(long)indexPath.row];
        
        
        NSDictionary *feature = [_items objectAtIndex:indexPath.row];
        NSDictionary *properties = [feature objectForKey:@"properties"];
        NSDictionary *geometry = [feature objectForKey:@"geometry"];
        NSArray *locationData = [geometry objectForKey:@"coordinates"];
        
        double mag = [[properties objectForKey:@"mag"] doubleValue];
        double time = [[properties objectForKey:@"time"] doubleValue];
        UIColor *color = [self getColorForMagnitude:mag];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:time/1000];
        [dateFormat setDateFormat:@"MM/dd/yyyy HH:mm:ss ZZZZ"];
        NSString* stringDate = [dateFormat stringFromDate:date];
        
        
        NSLog(@"JSON DATE = %@",stringDate);
        
        NSDictionary *locationDic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[properties objectForKey:@"place"],stringDate,[NSString stringWithFormat:@"%@",[properties objectForKey:@"mag"]],[locationData objectAtIndex:0],[locationData objectAtIndex:1],[locationData objectAtIndex:2],color, nil] forKeys:[NSArray arrayWithObjects:@"place",@"date",@"mag",@"longitude",@"latitude",@"depth",@"color", nil]];
        
        
        DetailViewController *detailView = segue.destinationViewController;
        detailView.detailData = locationDic;
    }
}

-(UIColor*)getColorForMagnitude:(double)mag
{
    UIColor *color = nil;
    
    if (mag < 1.0)
    {
        color = UIColorFromRGBWithAlpha(0x038703, 1);
    }
    else if (mag < 2.0)
    {
        color = UIColorFromRGBWithAlpha(0x218d02, 1);
    }
    else if (mag < 3.0)
    {
        color = UIColorFromRGBWithAlpha(0x429302, 1);
    }
    else if (mag < 4.0)
    {
        color = UIColorFromRGBWithAlpha(0x669902, 1);
    }
    else if (mag < 5.0)
    {
        color = UIColorFromRGBWithAlpha(0x8d9f01, 1);
    }
    else if (mag < 6.0)
    {
        color = UIColorFromRGBWithAlpha(0xa59201, 1);
    }
    else if (mag < 7.0)
    {
        color = UIColorFromRGBWithAlpha(0xab7201, 1);
    }
    else if (mag < 8.0)
    {
        color = UIColorFromRGBWithAlpha(0xb14f00, 1);
    }
    else if (mag < 9.0)
    {
        color = UIColorFromRGBWithAlpha(0xb72900, 1);
    }
    else if (mag < 10.0)
    {
        color = UIColorFromRGBWithAlpha(0xBD0000, 1);
    }
    else
    {
        color = UIColorFromRGBWithAlpha(0xBD0000, 1);
    }
    
    return color;
}

-(void)loadCache
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:@"cache"];
    NSDictionary *dictionary = [NSKeyedUnarchiver unarchiveObjectWithData:data];

    if (dictionary)
    {
        _items = [dictionary objectForKey:@"features"];
        _summaryData = dictionary;
        [_tblSummary reloadData];
        
        NSLog(@"DIC JSON = %@",dictionary);
        _items = [dictionary objectForKey:@"features"];
        
        NSDictionary *metadata = [dictionary objectForKey:@"metadata"];
        self.title = [metadata objectForKey:@"title"];
        
        
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:8.4987789
                                                                longitude:-98.3200779
                                                                     zoom:0];
        _mapView.myLocationEnabled = YES;
        [_mapView setCamera:camera];
        
        
        for (int i = 0; i<[_items count]; i++)
        {
            NSDictionary *feature = [_items objectAtIndex:i];
            NSDictionary *properties = [feature objectForKey:@"properties"];
            NSDictionary *geometry = [feature objectForKey:@"geometry"];
            NSArray *locationData = [geometry objectForKey:@"coordinates"];
            
            double longitude = [[locationData objectAtIndex:0] doubleValue];
            double latitude = [[locationData objectAtIndex:1] doubleValue];
            double mag = [[properties objectForKey:@"mag"] doubleValue];
            UIColor *color = [self getColorForMagnitude:mag];
            
            GMSMarker *marker = [[GMSMarker alloc] init];
            marker.icon = [GMSMarker markerImageWithColor:color];
            marker.position = CLLocationCoordinate2DMake(latitude, longitude);
            marker.title = [properties objectForKey:@"place"];
            marker.map = _mapView;
        }
    }
}
@end