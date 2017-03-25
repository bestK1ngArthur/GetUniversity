//
//  MPEIViewController.m
//  GetUniversity
//
//  Created by Artem Belkov on 14/07/15.
//  Copyright © 2015 Artem Belkov. All rights reserved.
//

#import "MPEIViewController.h"

#import "TFHpple.h"
#import "TFHppleElement.h"

#import "UniversityTableViewCell.h"

static NSString *kUserMarksCount = @"userMarksCount";

@interface MPEIViewController ()

@property (strong, nonatomic) NSMutableDictionary *departmentsDictionary;
@property (strong, nonatomic) NSArray *departmentNames;

@property (assign, nonatomic) NSInteger myMarksCount;

@property (strong, nonatomic) UIColor *cellRedColor;
@property (strong, nonatomic) UIColor *cellGreenColor;
@property (strong, nonatomic) UIColor *cellLightRedColor;
@property (strong, nonatomic) UIColor *cellLightGreenColor;

@property (assign, nonatomic) BOOL isLoadingAllDirections;

@end

@implementation MPEIViewController

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
    
    self.departmentsDictionary = [NSMutableDictionary dictionary];
    self.departmentNames = [NSArray array];
    
    // Refresh control
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refreshControl;
    
    [self.refreshControl beginRefreshing];
    
    // Change navigation title
    
    if (self.isLoadingAllDirections) {
        self.loadingAllDirectionBarItem.enabled = NO;
        //self.chooseDirectionBarItem.enabled = NO;
        self.navigationItem.title = @"Все направления МЭИ";
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    // Load data and animate
    
    [self refreshTable];
    
}

- (void)refreshTable {
    
    /*
    NSURL *url = [NSURL URLWithString:@"http://priem.bmstu.ru/ru/points/"];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    
    TFHpple *studentsParser = [TFHpple hppleWithHTMLData:urlData];
    self.studentsParser = studentsParser;
    
    NSString *studentsXpathQueryString = @"//div[@class='float-right']/b";
    TFHppleElement *lastUpdateNode = [[studentsParser searchWithXPathQuery:studentsXpathQueryString] objectAtIndex:0];
    NSString *lastUpdateString = [lastUpdateNode text];
    self.lastUpdateLabel.text = lastUpdateString;
    */
     
    if (self.isLoadingAllDirections) {
        [self reloadAllData];
    } else {
        [self reloadData];
    }
    
    [self.refreshControl endRefreshing];
    
    [self.tableView reloadData];
    
    //self.lastUpdateLabel.hidden = NO;
}

#pragma mark - University data

- (void)reloadData {
    
    NSArray *linksDepartmentsArray = [NSArray arrayWithObjects:@"http://www.pkmpei.ru/inform/list17e.html",
                                                               @"http://www.pkmpei.ru/inform/list14e.html", nil];
    
    for (NSString *link in linksDepartmentsArray) {
        
        NSURL *url = [NSURL URLWithString:link];
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        
        TFHpple *studentsParser = [TFHpple hppleWithHTMLData:urlData];
        
        TFHppleElement *departmentNameNode = [[studentsParser searchWithXPathQuery:@"//div[@class='competitive-group']"] objectAtIndex:0];
        NSString *departmentName = [departmentNameNode text];
        
        NSArray *studentsNodesArray = [studentsParser searchWithXPathQuery:@"//table[@class='thin-grid competitive-group-table']/tr"];
        NSArray *reversedStudentsNodesArray = [[studentsNodesArray reverseObjectEnumerator] allObjects];
        
        for (TFHppleElement *studentNode in reversedStudentsNodesArray) {
            
            NSDictionary *attirbutes = [studentNode attributes];
            NSString *classString = [attirbutes objectForKey:@"class"];
            
            if ([classString isEqualToString:@"accepted"]) {
                
                TFHppleElement *studentMarksNode = [[studentNode searchWithXPathQuery:@"//td"] objectAtIndex:0];
                
                NSInteger studentMarks = (NSInteger)[[studentMarksNode text] integerValue];
                
                [self.departmentsDictionary setObject:[NSNumber numberWithInt:(int)studentMarks] forKey:departmentName];
                
                if (studentMarks != 0) {
                    break;
                }
            }
        }
    }
    
    self.departmentNames = [self.departmentsDictionary allKeys];

}

- (void)reloadAllData {
    
    
    
    
    NSArray *linksDepartmentsArray = [NSArray arrayWithObjects:@"http://www.pkmpei.ru/inform/list1e.html",
                                                               @"http://www.pkmpei.ru/inform/list2e.html",
                                                               @"http://www.pkmpei.ru/inform/list3e.html",
                                                               @"http://www.pkmpei.ru/inform/list4e.html",
                                                               @"http://www.pkmpei.ru/inform/list5e.html",
                                                               @"http://www.pkmpei.ru/inform/list7e.html",
                                                               @"http://www.pkmpei.ru/inform/list8e.html",
                                                               @"http://www.pkmpei.ru/inform/list10e.html",
                                                               @"http://www.pkmpei.ru/inform/list11e.html",
                                                               @"http://www.pkmpei.ru/inform/list13e.html",
                                                               @"http://www.pkmpei.ru/inform/list14e.html",
                                                               @"http://www.pkmpei.ru/inform/list15e.html",
                                                               @"http://www.pkmpei.ru/inform/list16e.html",
                                                               @"http://www.pkmpei.ru/inform/list17e.html",
                                                               @"http://www.pkmpei.ru/inform/list18e.html",
                                                               @"http://www.pkmpei.ru/inform/list19e.html",
                                                               @"http://www.pkmpei.ru/inform/list20e.html",
                                                               @"http://www.pkmpei.ru/inform/list21e.html",
                                                               @"http://www.pkmpei.ru/inform/list22e.html",
                                                               @"http://www.pkmpei.ru/inform/list27e.html",
                                                               @"http://www.pkmpei.ru/inform/list35e.html", nil];
    
    for (NSString *link in linksDepartmentsArray) {
        
        NSURL *url = [NSURL URLWithString:link];
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        
        TFHpple *studentsParser = [TFHpple hppleWithHTMLData:urlData];
        
        TFHppleElement *departmentNameNode = [[studentsParser searchWithXPathQuery:@"//div[@class='competitive-group']"] objectAtIndex:0];
        NSString *departmentName = [departmentNameNode text];
        
        NSArray *studentsNodesArray = [studentsParser searchWithXPathQuery:@"//table[@class='thin-grid competitive-group-table']/tr"];
        NSArray *reversedStudentsNodesArray = [[studentsNodesArray reverseObjectEnumerator] allObjects];
        
        for (TFHppleElement *studentNode in reversedStudentsNodesArray) {
            
            NSDictionary *attirbutes = [studentNode attributes];
            NSString *classString = [attirbutes objectForKey:@"class"];
            
            if ([classString isEqualToString:@"accepted"]) {
                
                TFHppleElement *studentMarksNode = [[studentNode searchWithXPathQuery:@"//td"] objectAtIndex:0];
                
                NSInteger studentMarks = (NSInteger)[[studentMarksNode text] integerValue];
                
                [self.departmentsDictionary setObject:[NSNumber numberWithInt:(int)studentMarks] forKey:departmentName];
                
                if (studentMarks != 0) {
                    break;
                }
            }
        }
    }
    
    self.departmentNames = [self.departmentsDictionary allKeys];
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [self.departmentNames count];
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSArray *departmentArray = [[self.departmentNames objectAtIndex:section] componentsSeparatedByString:@" "];
    
    NSString *number = [departmentArray objectAtIndex:1];
    
    NSRange range = [[self.departmentNames objectAtIndex:section] rangeOfString:number];
    NSString *name = [[self.departmentNames objectAtIndex:section] substringFromIndex:(range.location + range.length)];
    
    return [NSString stringWithFormat:@"%@ %@", number, name];
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
        
        NSString *key = [self.departmentNames objectAtIndex:indexPath.section];
        
        NSArray *departmentArray = [key componentsSeparatedByString:@" "];
        
        NSString *departmentName = [departmentArray objectAtIndex:0];
        NSString *number = [departmentArray objectAtIndex:1];
        
        NSRange range = [key rangeOfString:number];
        NSString *name = [key substringFromIndex:(range.location + range.length)];
        
        cell.nameLabel.text = name;
        
        cell.departmentLabel.text = departmentName;
        
        NSInteger studentMarks = [[self.departmentsDictionary objectForKey:key] integerValue];
        
        cell.originalMarksLabel.text = [NSString stringWithFormat:@"%d", (int)studentMarks];
        
        NSInteger originalMarksCount = [cell.originalMarksLabel.text integerValue];
        
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
    
    MPEIViewController *mpeiViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MPEIViewController"];
    mpeiViewController.isLoadingAllDirections = YES;
    
    [self.navigationController pushViewController:mpeiViewController animated:YES];
    
}

@end
