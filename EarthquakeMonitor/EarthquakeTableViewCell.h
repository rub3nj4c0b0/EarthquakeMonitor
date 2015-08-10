//
//  EarthquakeTableViewCell.h
//  EarthquakeMonitor
//
//  Created by Rubén Jacobo on 10/08/15.
//
//

#import <UIKit/UIKit.h>

@interface EarthquakeTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *lblPlace;
@property (strong, nonatomic) IBOutlet UILabel *lblMagnitude;

@end
