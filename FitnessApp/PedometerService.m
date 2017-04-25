//
//  PedometerService.m
//  FitnessApp
//
//  Created by Fouad Allaoui on 4/24/17.
//  Copyright © 2017 Fouad Allaoui. All rights reserved.
//

#import "PedometerService.h"

@interface PedometerService ()

@property (nonatomic, strong)CMPedometer *pedometer;

@end

@implementation PedometerService

+ (instancetype)sharedManager {
    static PedometerService* sharedManager;
    if(!sharedManager) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedManager = [[self alloc] init];
        });
    }
    
    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    
    if(self) {
        self.pedometer = [[CMPedometer alloc] init];
    }

    return self;
}

- (PedometerData*)getPedometerDataForDate:(NSDate*)date {
    return nil;
}


@end
