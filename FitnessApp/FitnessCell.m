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

- (void)updateCellWithPedometerData:(CMPedometerData*)pedometerData withViewMode:(BOOL)isDetailMode {
    [self.dateLabel setText:[NSString stringWithFormat:@"%@", [self getPastDate:pedometerData.startDate]]];
    [self.stepsLabel setText:[NSString stringWithFormat:@"%@", pedometerData.numberOfSteps]];
    [self.floorsLabel setText:[NSString stringWithFormat:@"%@", [NSNumber numberWithFloat:([pedometerData.floorsAscended floatValue] + [pedometerData.floorsDescended floatValue])]]];
    [self.distanceLabel setText:[NSString stringWithFormat:@"%.2f", [self convertMetersToMiles:pedometerData.distance]]];
}

// ****************************************************************************************************************

#pragma mark - Util

- (double)convertMetersToMiles:(NSNumber*)meters {
    return [meters doubleValue] * 0.000621371192;
}

- (NSString*)getPastDate:(NSDate*)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE dd"];
    
    return [formatter stringFromDate:date];
}

@end
