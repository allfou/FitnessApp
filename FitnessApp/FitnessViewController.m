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

// Other UI Components
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) UIRefreshControl *refreshControl;
@property UIBarButtonItem *switchViewModeButton;
@property UIImageView *logo;

// Data
@property (nonatomic) CMPedometerData *currentPedometer;
@property (nonatomic) NSArray *pedometers;
@property BOOL isDetailMode;
@property BOOL isRefreshing;

@end

@implementation FitnessViewController

static NSString * const listCellID = @"listCell";
static NSString * const detailCellID = @"detailCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Init Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCurrentPedometerData:) name:@"refreshCurrentPedometerMessageEvent" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPastPedometerData:) name:@"refreshPastPedometerMessageEvent" object:nil];
    
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
    self.isDetailMode = NO; // Set List Mode by default
    [self setCollectionMode];
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 49, 0); // unhide last cell from tabbar
    
    // Init Current Date Label
    [self.currentDateLabel setText:[NSString stringWithFormat:@"Today, %@", [self getCurrentTime]]];
    
    // Init Location Service
    [[PedometerService sharedManager]startTracking];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Bug with refreshcontrol being position above cells
    [self.refreshControl.superview sendSubviewToBack:self.refreshControl];
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
    self.pedometers = [notification object];
    
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
    return [self.pedometers count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    FitnessCell *cell;
    
    if (self.isDetailMode) {
        cell = (FitnessCell*) [collectionView dequeueReusableCellWithReuseIdentifier:detailCellID forIndexPath:indexPath];
    } else {
        cell = (FitnessCell*) [collectionView dequeueReusableCellWithReuseIdentifier:listCellID forIndexPath:indexPath];
    }
    
    if (!cell) {
        cell = [[FitnessCell alloc]init];
    }
    
    // Set Pedometer Info
    [cell updateCellWithPedometerData:self.pedometers[indexPath.row] withViewMode:self.isDetailMode];
    
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
    if (self.isDetailMode) {
        self.isDetailMode = NO;
        [self setNavigationLogoImage:@"nav_logo.png"];
    } else {
        self.isDetailMode = YES;
        [self setNavigationLogoImage:@"nav_logo_open.png"];
    }
    
    [self setCollectionMode];
}

- (void)setCollectionMode {
    UINib *fitnessCellNib;
    
    if (!self.isDetailMode) {
        fitnessCellNib = [UINib nibWithNibName:@"ListFitnessCell" bundle:nil];
        [self.collectionView registerNib:fitnessCellNib forCellWithReuseIdentifier:listCellID];
        [self.collectionView reloadData];
        
        __block UICollectionViewFlowLayout *flowLayout;
        
        [self.collectionView performBatchUpdates:^{
            float width;
            CGSize mElementSize;
            [self.collectionView.collectionViewLayout invalidateLayout];
            width = self.collectionView.frame.size.width / 1;
            mElementSize = CGSizeMake(width, 155);
            flowLayout = [[UICollectionViewFlowLayout alloc] init];
            [flowLayout setItemSize:mElementSize];
            flowLayout.minimumLineSpacing = 10.0f;
            flowLayout.minimumInteritemSpacing = 0.0f;
            flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
            [self.collectionView setCollectionViewLayout:flowLayout animated:YES];
        } completion:^(BOOL finished) {
            
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
            [self.collectionView setCollectionViewLayout:flowLayout animated:YES];
        } completion:^(BOOL finished) {
            
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
        // Init Data here
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
   


@end
