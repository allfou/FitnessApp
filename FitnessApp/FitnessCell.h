//
//  FitnessCell.h
//  FitnessApp
//
//  Created by Fouad Allaoui on 4/24/17.
//  Copyright © 2017 Fouad Allaoui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PedometerData.h"

@interface FitnessCell : UICollectionViewCell

- (void)updateCellWithPedometerData:(PedometerData*)PedometerData withViewMode:(BOOL)isDetailMode;

@end
