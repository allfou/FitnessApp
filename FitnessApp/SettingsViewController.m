//
//  SettingsViewController.m
//  FitnessApp
//
//  Created by Fouad Allaoui on 4/24/17.
//  Copyright © 2017 Fouad Allaoui. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *metricDetail;
@property (weak, nonatomic) IBOutlet UILabel *viewModeDetail;
@property (weak, nonatomic) IBOutlet UILabel *versionDetail;

@property NSString *selectedMetric;
@property NSString *selectedViewMode;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Init App Version Details
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    self.versionDetail.text = [infoDict objectForKey:@"CFBundleShortVersionString"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:NO];
    
    // Init default settings from NSUserDefaults
    self.selectedMetric = [[NSUserDefaults standardUserDefaults] stringForKey:@"selectedMetric"];
    self.selectedViewMode = [[NSUserDefaults standardUserDefaults] stringForKey:@"selectedViewMode"];
    
    self.metricDetail.text = self.selectedMetric;
    self.viewModeDetail.text = self.selectedViewMode;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    } else if (section == 1) {
        return 1;
    }
    
    return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Remove inset separator
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-light" size:17.0f];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(15, 15, self.view.frame.size.width, 40);
    myLabel.font = [UIFont fontWithName:@"HelveticaNeue-light" size:13.0f];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:myLabel];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 47;
}

@end
