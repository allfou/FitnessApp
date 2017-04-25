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
@property (nonatomic, strong)NSMutableArray *pastPedometer;

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
        self.pastPedometer = [NSMutableArray new];
    }

    return self;
}

- (void)startTracking {
    [self.pedometer startPedometerUpdatesFromDate:[self getDateFromMidnightForDate:[NSDate date]] withHandler:^(CMPedometerData *_Nullable pedometerData, NSError *_Nullable error) {
        NSLog(@"PedometerData = %@", pedometerData);
        
        // Post Refresh Notification to Fitness View Controller
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshCurrentPedometerMessageEvent" object:pedometerData];
    }];
}

- (void)getPastPedometerDataSince:(int)days {
    
    dispatch_group_t group = dispatch_group_create();
    for (int i = 0; i <= days; i++) {
        dispatch_group_enter(group);
        
        [self.pedometer queryPedometerDataFromDate:[self getPreviousDateAt:i+1] toDate:[self getPreviousDateAt:i] withHandler:^(CMPedometerData * _Nullable pedometerData, NSError * _Nullable error) {
            [self.pastPedometer addObject:pedometerData];
        
            dispatch_group_leave(group);
        }];
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // Post Refresh Notification to Fitness View Controller
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshPastPedometerMessageEvent" object:[self.pastPedometer copy]];
    });
}

- (nullable NSDate *)getDateFromMidnightForDate:(NSDate*)date {
    NSCalendar *calendar = NSCalendar.currentCalendar;
    NSCalendarUnit preservedComponents = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
    NSDateComponents *components = [calendar components:preservedComponents fromDate:date];
    
    return [calendar dateFromComponents:components];
}

- (NSDate*)getPreviousDateAt:(int)daysAgo {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *date = [NSDate date];
    NSDateComponents *comps = [cal components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    NSDate *today = [cal dateFromComponents:comps];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:-daysAgo];
    
    return [cal dateByAddingComponents:components toDate:today options:0];
}

@end
