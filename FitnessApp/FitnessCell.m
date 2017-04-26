//
//  FitnessCell.m
//  FitnessApp
//
//  Created by Fouad Allaoui on 4/24/17.
//  Copyright © 2017 Fouad Allaoui. All rights reserved.
//

#import "FitnessCell.h"

@implementation FitnessCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    // Reset values for reusable cell
}

- (void)updateCellWithPedometerData:(CMPedometerData*)pedometerData withViewMode:(NSString*)viewMode {
    
    [self.dateLabel setText:[NSString stringWithFormat:@"%@", [self getPastDate:pedometerData.startDate]]];
    [self.stepsLabel setText:[NSString stringWithFormat:@"%@", pedometerData.numberOfSteps]];
    [self.distanceLabel setText:[self convertToSelectedMetric:pedometerData.distance]];
    
    if ([viewMode isEqualToString:@"List"]) {
        [self.floorsLabel setText:[NSString stringWithFormat:@"%@", [NSNumber numberWithFloat:([pedometerData.floorsAscended floatValue] + [pedometerData.floorsDescended floatValue])]]];
    } else {
        [self.floorUpLabel setText:[NSString stringWithFormat:@"%@", [NSNumber numberWithFloat:[pedometerData.floorsAscended floatValue]]]];
        [self.floorDownLabel setText:[NSString stringWithFormat:@"%@", [NSNumber numberWithFloat:[pedometerData.floorsDescended floatValue]]]];
        [self.averagePace setText:[NSString stringWithFormat:@"%.2f", [pedometerData.averageActivePace floatValue]]];
    }
}

// ****************************************************************************************************************

#pragma mark - Util

- (NSString*)convertToSelectedMetric:(NSNumber*)value {
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"selectedMetric"] isEqualToString:@"Miles"]) {
        [self.distanceMetricLabel setText:@"mi"];
        return [NSString stringWithFormat:@"%.2f", [value doubleValue] * 0.000621371192];
    }
    
    // return value in km
    [self.distanceMetricLabel setText:@"km"];
    return [NSString stringWithFormat:@"%.2f", [value doubleValue] / 1000];
}

- (NSString*)getPastDate:(NSDate*)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE dd"];
    
    return [formatter stringFromDate:date];
}

@end
