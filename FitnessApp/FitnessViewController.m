//
//  FitnessViewController.m
//  FitnessApp
//
//  Created by Fouad Allaoui on 4/24/17.
//  Copyright © 2017 Fouad Allaoui. All rights reserved.
//

#import "FitnessViewController.h"
#import "PedometerData.h"
#import "FitnessCell.h"
#import "Theme.h"

@interface UIViewController (PRScrollToTop)

- (void)scrollToTop;

@end

@interface FitnessViewController ()

@property (nonatomic) UIRefreshControl *refreshControl;
@property UIBarButtonItem *switchViewModeButton;
@property (nonatomic) NSArray *pedometers;
@property UIImageView *logo;
@property BOOL isDetailMode;
@property BOOL isRefreshing;

@end

@implementation FitnessViewController

static NSString * const listCellID = @"listCell";
static NSString * const detailCellID = @"detailCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Init Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPedometerList:) name:@"refreshPedometerMessageEvent" object:nil];
    
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

- (void)refreshPedometerList:(NSNotification*)notification {
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

//*****************************************************************************************************************************************

- (void)setNavigationLogoImage:(NSString*)imageName {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.logo.image = [UIImage imageNamed:imageName];
    });
}


@end
