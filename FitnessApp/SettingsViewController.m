//
//  SettingsViewController.m
//  FitnessApp
//
//  Created by Fouad Allaoui on 4/24/17.
//  Copyright © 2017 Fouad Allaoui. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *settings1Detail;
@property (weak, nonatomic) IBOutlet UILabel *settings2Detail;
@property (weak, nonatomic) IBOutlet UILabel *versionDetail;

@property NSString *selectedFood;
@property NSString *selectedSortedBy;

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
    self.selectedFood = [[NSUserDefaults standardUserDefaults] stringForKey:@"settings1"];
    self.selectedSortedBy = [[NSUserDefaults standardUserDefaults] stringForKey:@"settings2"];
    
    self.settings1Detail.text = self.selectedFood;
    self.settings2Detail.text = self.selectedSortedBy;
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
