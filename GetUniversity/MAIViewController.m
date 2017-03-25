//
//  MAIViewController.m
//  GetUniversity
//
//  Created by Artem Belkov on 14/07/15.
//  Copyright © 2015 Artem Belkov. All rights reserved.
//

#import "MAIViewController.h"

#import "UniversityTableViewCell.h"

@implementation MAIViewController

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
}

#pragma mark - Memory

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - University data



#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"Cell";
    
    UniversityTableViewCell *cell = (UniversityTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"UniversityTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        
        cell.nameLabel.text = @"Информация будет доступна позже";
        cell.departmentLabel.text = @"";
        
        //cell.allMarksLabel.text = @"";
        cell.originalMarksLabel.text = @"";
        
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

@end

