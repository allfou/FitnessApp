//
//  PedometerData.h
//  FitnessApp
//
//  Created by Fouad Allaoui on 4/24/17.
//  Copyright © 2017 Fouad Allaoui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PedometerData : NSObject

@property int numberOfSteps;
@property int distance;
@property int currentPace;
@property int currentCadence;
@property int floorsAscended;
@property int floorsDescended;

@end
