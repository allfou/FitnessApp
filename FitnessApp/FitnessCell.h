//
//  FitnessCell.h
//  FitnessApp
//
//  Created by Fouad Allaoui on 4/24/17.
//  Copyright © 2017 Fouad Allaoui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

@interface FitnessCell : UICollectionViewCell

// List View
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *stepsLabel;
@property (weak, nonatomic) IBOutlet UILabel *floorsLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceMetricLabel;

// Detail View
@property (weak, nonatomic) IBOutlet UILabel *floorDownLabel;
@property (weak, nonatomic) IBOutlet UILabel *floorUpLabel;
@property (weak, nonatomic) IBOutlet UILabel *averagePace;

- (void)updateCellWithPedometerData:(CMPedometerData*)pedometerData withViewMode:(NSString*)viewMode;

@end
