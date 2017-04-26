//
//  DetailViewController.h
//  FitnessApp
//
//  Created by Fouad Allaoui on 4/24/17.
//  Copyright © 2017 Fouad Allaoui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import "BEMSimpleLineGraphView.h"

@interface DetailViewController : UIViewController <BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate>


@property (weak, nonatomic) IBOutlet UIView *graphContainerView;
@property (strong, nonatomic) IBOutlet UILabel *labelValues;
@property (strong, nonatomic) IBOutlet UILabel *labelDates;
@property (weak, nonatomic) IBOutlet UILabel *pedometerDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *stepsLabel;
@property (weak, nonatomic) IBOutlet UILabel *floorLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceMetricLabel;

@property (strong, nonatomic) NSMutableArray *arrayOfValues;
@property (strong, nonatomic) NSMutableArray *arrayOfDates;
@property CMPedometerData *pedometerData;

@end
