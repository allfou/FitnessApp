//
//  PedometerService.h
//  FitnessApp
//
//  Created by Fouad Allaoui on 4/24/17.
//  Copyright © 2017 Fouad Allaoui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

@interface PedometerService : NSObject

+ (instancetype)sharedManager;

- (void)startTracking;

- (CMPedometerData*)getPedometerDataForDate:(NSDate*)date;

@end
