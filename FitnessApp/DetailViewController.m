//
//  DetailViewController.m
//  FitnessApp
//
//  Created by Fouad Allaoui on 4/24/17.
//  Copyright © 2017 Fouad Allaoui. All rights reserved.
//

#import "DetailViewController.h"
#import "PedometerService.h"
#import "Theme.h"

@interface DetailViewController ()

@property (nonatomic) BEMSimpleLineGraphView *graph;
@property int totalNumber;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Init Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPedometerData:) name:@"refreshPedometerDataMessageEvent" object:nil];
    
    // Init Data
    [self initDataSet];
    [[PedometerService sharedManager]getPedometerDataForday:self.pedometerData.endDate];
    
    // Init Details
    [self.stepsLabel setText:[NSString stringWithFormat:@"%@", self.pedometerData.numberOfSteps]];
    [self.floorLabel setText:[NSString stringWithFormat:@"%@", [NSNumber numberWithFloat:([self.pedometerData.floorsAscended floatValue] + [self.pedometerData.floorsDescended floatValue])]]];
    [self.distanceLabel setText:[self convertToSelectedMetric:self.pedometerData.distance]];
    
    // Init Graph
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = {1.0, 1.0, 1.0, 1.0,1.0, 1.0, 1.0, 0.0};
    self.graph = [[BEMSimpleLineGraphView alloc] initWithFrame:self.graphContainerView.frame];
    self.graph.delegate = self;
    self.graph.dataSource = self;
    self.graph.gradientBottom = CGGradientCreateWithColorComponents(colorspace, components, locations, num_locations);
    self.graph.enableTouchReport = YES;
    self.graph.enablePopUpReport = YES;
    self.graph.enableBezierCurve = YES;
    self.graph.averageLine.enableAverageLine = YES;
    self.graph.averageLine.alpha = 0.6;
    self.graph.colorPoint = [UIColor whiteColor];;
    self.graph.colorTop = graphBackgroundColor;
    self.graph.colorBottom = orangeColor;
    self.graph.averageLine.color = [UIColor whiteColor];
    self.graph.averageLine.width = 4.0;
    self.graph.averageLine.dashPattern = @[@(2),@(2)];
    self.graph.animationGraphStyle = BEMLineAnimationDraw;
    self.graph.lineDashPatternForReferenceYAxisLines = @[@(2),@(2)];
    self.graph.formatStringForValues = @"%.0f";
    self.labelValues.text = [NSString stringWithFormat:@"%i Total Steps", [[self.graph calculatePointValueSum] intValue]];
    self.labelDates.text = @"(24-hour data)";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// ************************************************************************************************************

#pragma mark Notifications

- (void)refreshPedometerData:(NSNotification*)notification {
    self.arrayOfValues = [notification object];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.graphContainerView addSubview:self.graph];
    });
}

// ************************************************************************************************************

#pragma mark Data

- (void)initDataSet {
    if (!self.arrayOfValues) self.arrayOfValues = [[NSMutableArray alloc] init];
    if (!self.arrayOfDates) self.arrayOfDates = [[NSMutableArray alloc] init];
    [self.arrayOfValues removeAllObjects];
    [self.arrayOfDates removeAllObjects];
    
    for (int i = 0; i < 24; i++) {
        [self.arrayOfValues addObject:@([self getRandomFloat])]; // Random values for the graph
        [self.arrayOfDates addObject:[self dateForHour:i forDate:[NSDate date]]];
        self.totalNumber = self.totalNumber + [[self.arrayOfValues objectAtIndex:i] intValue]; // All of the values added together
    }
}

// ************************************************************************************************************

#pragma mark - SimpleLineGraph Data Source

- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph {
    return (int)[self.arrayOfValues count];
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index {
    return [[[self.arrayOfValues objectAtIndex:index] numberOfSteps] doubleValue];
}

// ************************************************************************************************************

#pragma mark - SimpleLineGraph Delegate

- (NSInteger)numberOfGapsBetweenLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph {
    return 2;
}

- (NSString *)lineGraph:(BEMSimpleLineGraphView *)graph labelOnXAxisForIndex:(NSInteger)index {
    
    NSString *label = [self labelForDateAtIndex:index];
    return [label stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
}

- (void)lineGraph:(BEMSimpleLineGraphView *)graph didTouchGraphWithClosestIndex:(NSInteger)index {
    self.labelValues.text = [NSString stringWithFormat:@"%@ steps", [[self.arrayOfValues objectAtIndex:index] numberOfSteps]];
    self.labelDates.text = [NSString stringWithFormat:@"at %@", [self labelForDateAtIndex:index]];
}

- (void)lineGraph:(BEMSimpleLineGraphView *)graph didReleaseTouchFromGraphWithClosestIndex:(CGFloat)index {
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.labelValues.alpha = 0.0;
        self.labelDates.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.labelValues.text = [NSString stringWithFormat:@"%i steps", [[self.graph calculatePointValueSum] intValue]];
        self.labelDates.text = [NSString stringWithFormat:@"%@ - %@", [self labelForDateAtIndex:0], [self labelForDateAtIndex:self.arrayOfDates.count - 1]];
        
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.labelValues.alpha = 1.0;
            self.labelDates.alpha = 1.0;
        } completion:nil];
    }];
}

- (void)lineGraphDidFinishLoading:(BEMSimpleLineGraphView *)graph {
    self.labelValues.text = [NSString stringWithFormat:@"%i steps", [[self.graph calculatePointValueSum] intValue]];
    self.labelDates.text = [NSString stringWithFormat:@"%@ - %@", [self labelForDateAtIndex:0], [self labelForDateAtIndex:self.arrayOfDates.count - 1]];
}

// ************************************************************************************************************

#pragma mark - Utils

- (float)getRandomFloat {
    float i1 = (float)(arc4random() % 1000000) / 100 ;
    return i1;
}

- (NSString*)convertToSelectedMetric:(NSNumber*)value {
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"selectedMetric"] isEqualToString:@"Miles"]) {
        [self.distanceMetricLabel setText:@"Distance - mi"];
        return [NSString stringWithFormat:@"%.2f", [value doubleValue] * 0.000621371192];
    }
    
    // return value in km
    [self.distanceMetricLabel setText:@"Distance - km"];
    return [NSString stringWithFormat:@"%.2f", [value doubleValue] / 1000];
}


- (NSDate*)dateForHour:(int)hour forDate:(NSDate*)date {
    return [date dateByAddingTimeInterval:-((60*60)*hour)];
}

- (NSDate *)dateForGraphAfterDate:(NSDate *)date {
    NSTimeInterval secondsInTwentyFourHours = 24 * 60 * 60;
    NSDate *newDate = [date dateByAddingTimeInterval:secondsInTwentyFourHours];
    return newDate;
}

- (NSString *)labelForDateAtIndex:(NSInteger)index {
    NSDate *date = self.arrayOfDates[index];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [df setDateStyle:NSDateFormatterMediumStyle];
    df.dateFormat = @"hha";
    NSString *label = [df stringFromDate:date];
    return label;
}

@end
