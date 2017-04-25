//
//  FitnessViewController.m
//  FitnessApp
//
//  Created by Fouad Allaoui on 4/24/17.
//  Copyright © 2017 Fouad Allaoui. All rights reserved.
//

#import "FitnessViewController.h"
#import "PedometerService.h"
#import "FitnessCell.h"
#import "Theme.h"

@interface UIViewController (PRScrollToTop)

- (void)scrollToTop;

@end

@interface FitnessViewController ()

// Current Pedometer View
@property (weak, nonatomic) IBOutlet UILabel *currentDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *stepsLabel;
@property (weak, nonatomic) IBOutlet UILabel *floorLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *metricLabel;

// Other UI Components
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) UIRefreshControl *refreshControl;
@property UIBarButtonItem *switchViewModeButton;
@property UIImageView *logo;

// Data
@property (nonatomic) CMPedometerData *currentPedometer;
@property (nonatomic) NSArray *pastPedometers;
@property NSString *viewMode;
@property BOOL isRefreshing;

@end

@implementation FitnessViewController

static NSString * const listCellID = @"ListFitnessCell";
static NSString * const detailCellID = @"DetailFitnessCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Init Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCurrentPedometerData:) name:@"refreshCurrentPedometerMessageEvent" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPastPedometerData:) name:@"refreshPastPedometerMessageEvent" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initData) name:@"refreshAllDataMessageEvent" object:nil];
    
    // Used for double tap on tabbar items
    self.tabBarController.delegate = self;
    
    // Init Navigation Bar (Logo)
    self.logo = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"nav_logo.png"]];
    [self.logo setUserInteractionEnabled:YES];
    UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchViewMode)];
    [singleTap setNumberOfTapsRequired:1];
    [self.logo addGestureRecognizer:singleTap];
    self.tabBarController.navigationItem.titleView = self.logo;
    
    // Init Refresh Control
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = refreshControllerColor;
    [self.refreshControl addTarget:self action:@selector(pullToRefresh) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    self.collectionView.alwaysBounceVertical = YES;
    self.isRefreshing = NO;
    
    // Init CollectionView
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0); // unhide last cell from tabbar
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    // Init Current Date Label
    [self.currentDateLabel setText:[NSString stringWithFormat:@"Today, %@", [self getCurrentTime]]];
    
    // Init Data
    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setCurrentMetric];
    self.viewMode = [[NSUserDefaults standardUserDefaults] stringForKey:@"selectedViewMode"];
    [self setCollectionMode];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Bug with refreshcontrol being position above cells
    [self.refreshControl.superview sendSubviewToBack:self.refreshControl];
}

// ************************************************************************************************************

#pragma mark Data

- (void)initData {
    // Init Current Pedometer Data
    [[PedometerService sharedManager]startTracking];
    
    // Init Past Pedometer Data from the last N days
    [[PedometerService sharedManager]getPastPedometerDataSince:9];
}

// ************************************************************************************************************

#pragma mark Notifications

- (void)refreshCurrentPedometerData:(NSNotification*)notification {
    self.currentPedometer = [notification object];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.currentDateLabel setText:[NSString stringWithFormat:@"Today, %@", [self getCurrentTime]]];
        [self.stepsLabel setText:[NSString stringWithFormat:@"%@", self.currentPedometer.numberOfSteps]];
        [self.floorLabel setText:[NSString stringWithFormat:@"%@", [NSNumber numberWithFloat:([self.currentPedometer.floorsAscended floatValue] + [self.currentPedometer.floorsDescended floatValue])]]];
        [self.distanceLabel setText:[NSString stringWithFormat:@"%.2f", [self convertMetersToMiles:self.currentPedometer.distance]]];
    });
}

- (void)refreshPastPedometerData:(NSNotification*)notification {
    self.pastPedometers = [notification object];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}

// ************************************************************************************************************

#pragma mark CollectionView DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.pastPedometers count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    FitnessCell *cell;
    
    if ([self.viewMode isEqualToString:@"List"]) {
        cell = (FitnessCell*) [collectionView dequeueReusableCellWithReuseIdentifier:listCellID forIndexPath:indexPath];
    } else {
        cell = (FitnessCell*) [collectionView dequeueReusableCellWithReuseIdentifier:detailCellID forIndexPath:indexPath];
    }
    
    if (!cell) {
        cell = [[FitnessCell alloc]init];
    }
    
    // Set Pedometer Info
    [cell updateCellWithPedometerData:self.pastPedometers[indexPath.row] withViewMode:self.viewMode];
    
    // Set Cell Color
    if(indexPath.row % 2 == 0)
        cell.backgroundColor = cellBackgroundColorLight;
    else
        cell.backgroundColor = cellBackgroundColorDark;
    
    return cell;
}

// ************************************************************************************************************

#pragma mark CollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"detailSegue" sender:self];
}

// ************************************************************************************************************

#pragma mark Fitness View Mode

- (void)switchViewMode {
    if ([self.viewMode isEqualToString:@"List"]) {
        self.viewMode = @"Detail";
        [self setNavigationLogoImage:@"nav_logo_open.png"];
    } else {
        self.viewMode = @"List";
        [self setNavigationLogoImage:@"nav_logo.png"];
    }
    
    // Save selected View Mode into NSUserDefaults
    [[NSUserDefaults standardUserDefaults] setValue:self.viewMode forKey:@"selectedViewMode"];
    
    [self setCollectionMode];
}

- (void)setCollectionMode {
    UINib *fitnessCellNib;
    
    if ([self.viewMode isEqualToString:@"List"]) {
        fitnessCellNib = [UINib nibWithNibName:@"ListFitnessCell" bundle:nil];
        [self.collectionView registerNib:fitnessCellNib forCellWithReuseIdentifier:listCellID];
        [self.collectionView reloadData];
        
        __block UICollectionViewFlowLayout *flowLayout;
        
        [self.collectionView performBatchUpdates:^{
            float width;
            CGSize mElementSize;
            [self.collectionView.collectionViewLayout invalidateLayout];
            width = self.collectionView.frame.size.width / 1;
            mElementSize = CGSizeMake(width, 90);
            flowLayout = [[UICollectionViewFlowLayout alloc] init];
            [flowLayout setItemSize:mElementSize];
            flowLayout.minimumLineSpacing = 0.0f;
            flowLayout.minimumInteritemSpacing = 0.0f;
            flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
            
        } completion:^(BOOL finished) {
            [self.collectionView setCollectionViewLayout:flowLayout animated:YES];
        }];
    } else {
        fitnessCellNib = [UINib nibWithNibName:@"DetailFitnessCell" bundle:nil];
        [self.collectionView registerNib:fitnessCellNib forCellWithReuseIdentifier:detailCellID];
        [self.collectionView reloadData];
        
        __block UICollectionViewFlowLayout *flowLayout;
        [self.collectionView performBatchUpdates:^{
            float width;
            CGSize mElementSize;
            [self.collectionView.collectionViewLayout invalidateLayout];
            width = self.collectionView.frame.size.width / 1;
            mElementSize = CGSizeMake(width, 270);
            flowLayout = [[UICollectionViewFlowLayout alloc] init];
            [flowLayout setItemSize:mElementSize];
            flowLayout.minimumLineSpacing = 0.0f;
            flowLayout.minimumInteritemSpacing = 0.0f;
            flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
            
        } completion:^(BOOL finished) {
            [self.collectionView setCollectionViewLayout:flowLayout animated:YES];
        }];
    }
}

- (void)setNavigationLogoImage:(NSString*)imageName {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.logo.image = [UIImage imageNamed:imageName];
    });
}

//*****************************************************************************************************************************************

#pragma mark - Refresh Control

- (void)pullToRefresh {
    // Improve refresh UI effect
    double delayInSeconds = 0.5f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.refreshControl endRefreshing];
    });
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.isRefreshing = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self containingScrollViewDidEndDragging:scrollView];
    
    if (self.isRefreshing) {
        [self initData];
    }
}

- (void)containingScrollViewDidEndDragging:(UIScrollView *)containingScrollView {
    CGFloat minOffsetToTriggerRefresh = 130.0f;
    if (!self.isRefreshing && (containingScrollView.contentOffset.y <= -minOffsetToTriggerRefresh)) {
        self.isRefreshing = YES;
    }
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView {
    [self containingScrollViewDidEndDragging:scrollView];
}


//***************************************************************************************************************************************

#pragma mark - Tab bar Delegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    static UIViewController *previousController;
    previousController = previousController ?: viewController;
    if (previousController == viewController) {
        if ([viewController isKindOfClass:UINavigationController.class]) {
            UINavigationController *navigationController = (UINavigationController *)viewController;
            if (navigationController.viewControllers.count == 1) {
                UIViewController *rootViewController = navigationController.viewControllers.firstObject;
                if ([rootViewController respondsToSelector:@selector(scrollToTop)]) {
                    [rootViewController scrollToTop];
                }
            }
        } else {
            if ([viewController respondsToSelector:@selector(scrollToTop)]) {
                [viewController scrollToTop];
            }
        }
    }
    previousController = viewController;
    return YES;
}

-(void)scrollToTop {
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionTop
                                        animated:YES];
}

// ****************************************************************************************************************

#pragma mark - Util

- (double)convertMetersToMiles:(NSNumber*)meters {
    return [meters doubleValue] * 0.000621371192;
}

- (NSString*)getCurrentTime {
   NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
   [formatter setDateFormat:@"HH:mm"];
   NSDate *currentDate = [NSDate date];

   return [formatter stringFromDate:currentDate];
}

- (void)setCurrentMetric {
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"selectedMetric"] isEqualToString:@"Miles"]) {
        [self.metricLabel setText:@"mi"];
    } else {
        [self.metricLabel setText:@"km"];
    }
}

@end
