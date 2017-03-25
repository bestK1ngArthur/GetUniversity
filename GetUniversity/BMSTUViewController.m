//
//  BMSTUViewController.m
//  GetUniversity
//
//  Created by Artem Belkov on 14/07/15.
//  Copyright © 2015 Artem Belkov. All rights reserved.
//

#import "BMSTUViewController.h"

#import "TFHpple.h"
#import "TFHppleElement.h"

#import "UniversityTableViewCell.h"

static NSString *kUserMarksCount = @"userMarksCount";

@interface BMSTUViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) TFHpple *studentsParser;

@property (strong, nonatomic) NSMutableArray *directionsWithDepartmentsNodes;
@property (strong, nonatomic) NSArray *directionNodes;
@property (strong, nonatomic) NSArray *directionNamesNodes;

@property (strong, nonatomic) NSString *updateValue;

@property (strong, nonatomic) NSMutableArray *inDirectionsWithDepartmentsNodes;
@property (strong, nonatomic) NSArray *inDirectionNodes;
@property (strong, nonatomic) NSArray *inDidirectionNamesNodes;

@property (assign, nonatomic) NSInteger myMarksCount;

@property (strong, nonatomic) UIColor *cellRedColor;
@property (strong, nonatomic) UIColor *cellGreenColor;
@property (strong, nonatomic) UIColor *cellLightRedColor;
@property (strong, nonatomic) UIColor *cellLightGreenColor;

@property (assign, nonatomic) BOOL isLoadingAllDirections;

@end

@implementation BMSTUViewController

#pragma mark - Initialization

- (instancetype)initWithLoadingAllDirections:(BOOL)isLoadingAllDirections
{
    self = [super init];
    if (self) {
        self.isLoadingAllDirections = isLoadingAllDirections;
    }
    return self;
}

- (instancetype)initWithDirectionNodes:(NSArray *)directionNodes directionNamesNodes:(NSArray *)directionNamesNodes
{
    self = [super init];
    if (self) {
        self.directionNodes = directionNodes;
        self.directionNamesNodes = directionNamesNodes;
    }
    return self;
}

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Take userMarksCount
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.myMarksCount = [userDefaults integerForKey:kUserMarksCount];
    
    // Set colors
    
    self.cellRedColor = [UIColor colorWithRed: 255 /255.f
                                        green: 62  /255.f
                                         blue: 74  /255.f
                                        alpha:1.f];
    self.cellGreenColor = [UIColor colorWithRed: 85 /255.f
                                        green:  186 /255.f
                                         blue:  134 /255.f
                                        alpha:1.f];
    self.cellLightRedColor = [UIColor colorWithRed: 255 /255.f
                                             green: 245 /255.f
                                              blue: 245 /255.f
                                             alpha:1.f];
    self.cellLightGreenColor = [UIColor colorWithRed: 245 /255.f
                                               green: 255 /255.f
                                                blue: 245 /255.f
                                               alpha:1.f];
    
    self.directionsWithDepartmentsNodes = [NSMutableArray array];
    
    // Refresh control
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refreshControl;
    
    [self.refreshControl beginRefreshing];
    
    // Change navigation title
    
    if (self.isLoadingAllDirections) {
        self.loadingAllDirectionBarItem.enabled = NO;
        self.chooseDirectionBarItem.enabled = NO;
        self.navigationItem.title = @"Все направления МГТУ";
    }
    
    self.updateValue = @"";
}

- (void)viewDidAppear:(BOOL)animated {
    
    // Load data and animate
    
    [self refreshTable];
    
}

- (void)refreshTable {
        
    NSURL *url = [NSURL URLWithString:@"http://priem.bmstu.ru/ru/points/"];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    
    TFHpple *studentsParser = [TFHpple hppleWithHTMLData:urlData];
    self.studentsParser = studentsParser;
    
    NSString *studentsXpathQueryString = @"//div[@class='float-right']/b";
    TFHppleElement *lastUpdateNode = [[studentsParser searchWithXPathQuery:studentsXpathQueryString] objectAtIndex:0];
    NSString *lastUpdateString = [lastUpdateNode text];
    self.lastUpdateLabel.text = lastUpdateString;
    
    if (self.isLoadingAllDirections) {
        [self reloadAllData];
    } else {
        [self reloadData];
    }
    
    [self.refreshControl endRefreshing];
    
    self.lastUpdateLabel.hidden = NO;
}

#pragma mark - University data

- (void)reloadData {
    
    if (!self.inDirectionNodes) {
        
        NSURL *url = [NSURL URLWithString:@"http://priem.bmstu.ru/ru/points/"];
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        
        TFHpple *studentsParser = [TFHpple hppleWithHTMLData:urlData];
        self.studentsParser = studentsParser;
        
        NSString *studentsXpathQueryString = @"//div[@class='speciality-content']";
        NSArray *allDirectionsNodes = [studentsParser searchWithXPathQuery:studentsXpathQueryString];
        
        TFHppleElement *direction1Node = [allDirectionsNodes objectAtIndex:3];
        TFHppleElement *direction2Node = [allDirectionsNodes objectAtIndex:4];
        TFHppleElement *direction3Node = [allDirectionsNodes objectAtIndex:12];
        
        self.directionNodes = [NSArray arrayWithObjects:direction1Node,
                               direction2Node,
                               direction3Node, nil];
        
        studentsXpathQueryString = @"//div[@class='speciality-container']";
        NSArray *allDirectionsNamesNodes = [studentsParser searchWithXPathQuery:studentsXpathQueryString];
        
        TFHppleElement *direction1NameNode = [allDirectionsNamesNodes objectAtIndex:3];
        TFHppleElement *direction2NameNode = [allDirectionsNamesNodes objectAtIndex:4];
        TFHppleElement *direction3NameNode = [allDirectionsNamesNodes objectAtIndex:12];
        
        self.directionNamesNodes = [NSArray arrayWithObjects:direction1NameNode,
                                    direction2NameNode,
                                    direction3NameNode, nil];
        
    }
    
    for (TFHppleElement *directionNode in self.directionNodes) {
        
        NSArray *departmentsNodes = [directionNode searchWithXPathQuery:@"//tbody/tr"];
        [self.directionsWithDepartmentsNodes addObject:departmentsNodes];
        
    }
    
    [self.tableView reloadData];
    
}

- (void)reloadAllData {
    
    NSURL *url = [NSURL URLWithString:@"http://priem.bmstu.ru/ru/points/"];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    
    TFHpple *studentsParser = [TFHpple hppleWithHTMLData:urlData];
    self.studentsParser = studentsParser;
    
    NSString *studentsXpathQueryString = @"//div[@class='speciality-content']";
    NSArray *allDirectionsNodes = [studentsParser searchWithXPathQuery:studentsXpathQueryString];
    
    self.directionNodes = allDirectionsNodes;
    
    studentsXpathQueryString = @"//div[@class='speciality-container']";
    NSArray *allDirectionsNamesNodes = [studentsParser searchWithXPathQuery:studentsXpathQueryString];
    
    self.directionNamesNodes = allDirectionsNamesNodes;
    
    for (TFHppleElement *directionNode in self.directionNodes) {
        
        NSArray *departmentsNodes = [directionNode searchWithXPathQuery:@"//tbody/tr"];
        [self.directionsWithDepartmentsNodes addObject:departmentsNodes];
        
    }
    
    [self.tableView reloadData];
    
}

#pragma mark - Memory

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [self.directionNodes count];
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    TFHppleElement *directionNameNode = [self.directionNamesNodes objectAtIndex:section];
    TFHppleElement *titleNode = [[directionNameNode searchWithXPathQuery:@"//h3"] objectAtIndex:0];
    
    return [titleNode text];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSArray *departmentNodes = [self.directionsWithDepartmentsNodes objectAtIndex:section];
    
    return [departmentNodes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"Cell";
    
    UniversityTableViewCell *cell = (UniversityTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"UniversityTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        
        NSArray *departmentNodes = [self.directionsWithDepartmentsNodes objectAtIndex:indexPath.section];
        TFHppleElement *departmentNode = [departmentNodes objectAtIndex:indexPath.row];

        NSArray *infoDepartmentNodes = [departmentNode searchWithXPathQuery:@"//td"];
        
        cell.departmentLabel.text = [[infoDepartmentNodes objectAtIndex:0] text];
        cell.nameLabel.text = [[infoDepartmentNodes objectAtIndex:1] text];
        //cell.allMarksLabel.text = [[infoDepartmentNodes objectAtIndex:3] text]; //DEPRECATED
        cell.originalMarksLabel.text = [[infoDepartmentNodes objectAtIndex:4] text];
        
        //NSInteger allMarksCount = [cell.allMarksLabel.text integerValue]; //DEPRECATED
        NSInteger originalMarksCount = [cell.originalMarksLabel.text integerValue];
        
        //NSInteger averageMarksCount = (allMarksCount + originalMarksCount) / 2; //DEPRECATED
        
        if ((int)self.myMarksCount >= (int)originalMarksCount) {
            
            cell.backgroundColor = self.cellLightGreenColor;
        
        } else {
            
            cell.backgroundColor = self.cellLightRedColor;
            
        }
        
        if (originalMarksCount > (int)self.myMarksCount) {
            
            cell.originalMarksLabel.textColor = [UIColor whiteColor];
            cell.originalMarksView.backgroundColor = [self cellRedColor];
            
        } else {
            
            cell.originalMarksLabel.textColor = [UIColor whiteColor];
            cell.originalMarksView.backgroundColor = [self cellGreenColor];
            
        }
    }
    
    // Select my directions
    
    if ((self.isLoadingAllDirections) && (self.inDirectionNodes)) {
        
        NSArray *inDepartmentNodes = [self.inDirectionsWithDepartmentsNodes objectAtIndex:indexPath.section];
        TFHppleElement *inDepartmentNode = [inDepartmentNodes objectAtIndex:indexPath.row];
        
        NSArray *infoInDepartmentNodes = [inDepartmentNode searchWithXPathQuery:@"//td"];
        
        NSString *inDirectionName = [[infoInDepartmentNodes objectAtIndex:1] text];
        
        if ([inDirectionName isEqualToString:cell.nameLabel.text]) {
            
            cell.nameLabel.textColor = [UIColor whiteColor];
            cell.departmentLabel.textColor = [UIColor whiteColor];
            
            [cell setSelected:YES animated:YES];
            
        }
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

#pragma mark - Actions

- (IBAction)actionLoadAllDirections:(id)sender {
    
    BMSTUViewController *bmstuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"BMSTUViewController"];
    bmstuViewController.isLoadingAllDirections = YES;
    
    [self.navigationController pushViewController:bmstuViewController animated:YES];
    
}

- (IBAction)actionChooseDirections:(id)sender {

    BMSTUViewController *bmstuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"BMSTUDirectionsViewController"];
    bmstuViewController.isLoadingAllDirections = YES;
    
    bmstuViewController.inDirectionsWithDepartmentsNodes = self.directionsWithDepartmentsNodes;
    bmstuViewController.inDirectionNodes = self.directionNodes;
    bmstuViewController.inDidirectionNamesNodes = self.directionNamesNodes;
    
    bmstuViewController.tableView.editing = YES;
    
    [self.navigationController pushViewController:bmstuViewController animated:YES];

}

@end
