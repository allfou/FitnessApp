//
//  FitnessAPI.h
//  FitnessApp
//
//  Created by Fouad Allaoui on 4/24/17.
//  Copyright © 2017 Fouad Allaoui. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *
 * This Class simulate a client/server call to an API in order to get/post all the pedometer data to/from a user accountt
 *
 **/
@interface FitnessAPI : NSObject

// Returns User's pedometer data for the last n days
- (NSArray*)getLatestPedometerData:(int)days forUserId:(NSString*)userId;

// Post pedometer data to
- (void)postPedometerData:(NSDictionary*)data toUserId:(NSString*)userId;

@end
