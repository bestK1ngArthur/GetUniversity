//
//  MephiViewController.m
//  GetUniversity
//
//  Created by Artem Belkov on 14/07/15.
//  Copyright © 2015 Artem Belkov. All rights reserved.
//

#import "MephiViewController.h"

#import "TFHpple.h"
#import "TFHppleElement.h"

#import "UniversityTableViewCell.h"

static NSString *kUserMarksCount = @"userMarksCount";

typedef enum {
    
    MarksCountTypeAll,
    MarksCountTypeOriginal,
    
} MarksCountType;

@interface MephiViewController ()

@property (strong, nonatomic) NSArray *studentsNodesList;

@property (strong, nonatomic) NSMutableArray *directionsWithDepartmentsNodes;
@property (strong, nonatomic) NSArray *directionNames;

@property (strong, nonatomic) NSArray *directionsFreeSeats;

@property (strong, nonatomic) NSArray *allMarksCounts;
@property (strong, nonatomic) NSArray *originalMarksCounts;
@property (assign, nonatomic) NSInteger myMarksCount;

@property (strong, nonatomic) UIColor *cellRedColor;
@property (strong, nonatomic) UIColor *cellGreenColor;
@property (strong, nonatomic) UIColor *cellLightRedColor;
@property (strong, nonatomic) UIColor *cellLightGreenColor;

@property (assign, nonatomic) BOOL isLoadingAllDirections;


@end

@implementation MephiViewController

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.myMarksCount = [userDefaults integerForKey:kUserMarksCount] +1;
    
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
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refreshControl;
    
    if (self.isLoadingAllDirections) {
        self.loadingAllDirectionBarItem.enabled = NO;
        self.navigationItem.title = @"Все направления МИФИ";
    }
    
    
    [self.refreshControl beginRefreshing];
    
}

- (void)viewDidAppear:(BOOL)animated {
    

    if (self.isLoadingAllDirections) {
        [self reloadAllData];
    } else {
        [self reloadData];
    }
    
    [self.refreshControl endRefreshing];
    //[self.tableView reloadData];
    
}

#pragma mark - Memory

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - University data

- (void)refreshTable {
    
    [self reloadData];
    
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

- (void)reloadData {
    
    // Download free seats
    
    self.directionsFreeSeats = [NSArray arrayWithObjects:[NSNumber numberWithInt:20 -2],
                                [NSNumber numberWithInt:10 -0],
                                [NSNumber numberWithInt:10 -2], nil];
    
    // Download student's lists
    
    NSURL *url1 = [NSURL URLWithString:@"https://org.mephi.ru/pupil-rating/get-rating/entity/3626/original/no"];
    NSURL *url2 = [NSURL URLWithString:@"https://org.mephi.ru/pupil-rating/get-rating/entity/3632/original/no"];
    NSURL *url3 = [NSURL URLWithString:@"https://org.mephi.ru/pupil-rating/get-rating/entity/3630/original/no"];
    
    NSData *url1Data = [NSData dataWithContentsOfURL:url1];
    NSData *url2Data = [NSData dataWithContentsOfURL:url2];
    NSData *url3Data = [NSData dataWithContentsOfURL:url3];
    
    TFHpple *studentsParser1 = [TFHpple hppleWithHTMLData:url1Data];
    TFHpple *studentsParser2 = [TFHpple hppleWithHTMLData:url2Data];
    TFHpple *studentsParser3 = [TFHpple hppleWithHTMLData:url3Data];
    
    NSString *studentsXpathQueryString = @"//tr[@class='trPosBen']";
    NSArray *studentsNodes1 = [studentsParser1 searchWithXPathQuery:studentsXpathQueryString];
    NSArray *studentsNodes2 = [studentsParser2 searchWithXPathQuery:studentsXpathQueryString];
    NSArray *studentsNodes3 = [studentsParser3 searchWithXPathQuery:studentsXpathQueryString];
    
    self.studentsNodesList = [NSArray arrayWithObjects:studentsNodes1,
                              studentsNodes2,
                              studentsNodes3, nil];
    
    NSNumber *allMarksCount1 = [NSNumber numberWithInt:(int)[self calculateMarksCount:MarksCountTypeAll forStudentsNodes:studentsNodes1]];
    NSNumber *allMarksCount2 = [NSNumber numberWithInt:(int)[self calculateMarksCount:MarksCountTypeAll forStudentsNodes:studentsNodes2]];
    NSNumber *allMarksCount3 = [NSNumber numberWithInt:(int)[self calculateMarksCount:MarksCountTypeAll forStudentsNodes:studentsNodes3]];

    NSNumber *originalMarksCount1 = [NSNumber numberWithInt:(int)[self calculateMarksCount:MarksCountTypeOriginal forStudentsNodes:studentsNodes1]];
    NSNumber *originalMarksCount2 = [NSNumber numberWithInt:(int)[self calculateMarksCount:MarksCountTypeOriginal forStudentsNodes:studentsNodes2]];
    NSNumber *originalMarksCount3 = [NSNumber numberWithInt:(int)[self calculateMarksCount:MarksCountTypeOriginal forStudentsNodes:studentsNodes3]];
     
    self.allMarksCounts = [NSArray arrayWithObjects:allMarksCount1, allMarksCount2, allMarksCount3, nil];
    self.originalMarksCounts = [NSArray arrayWithObjects:originalMarksCount1, originalMarksCount2, originalMarksCount3, nil];
    
    // Download direction's names
    
    TFHppleElement *directionName1Node = [[studentsParser1 searchWithXPathQuery:@"//tr[@class='throw']/th"] objectAtIndex:0];
    TFHppleElement *directionName2Node = [[studentsParser2 searchWithXPathQuery:@"//tr[@class='throw']/th"] objectAtIndex:0];
    TFHppleElement *directionName3Node = [[studentsParser3 searchWithXPathQuery:@"//tr[@class='throw']/th"] objectAtIndex:0];
    
    self.directionNames = [NSArray arrayWithObjects:[[directionName1Node text] substringFromIndex:8],
                                                    [[directionName2Node text] substringFromIndex:8],
                                                    [[directionName3Node text] substringFromIndex:8], nil];
    
    [self.tableView reloadData];
    
}

- (void)reloadAllData {
    
    // Download student's lists
    
    NSURL *freeSeatsUrl = [NSURL URLWithString:@"http://priem.mephi.ru/admission-2015/amount/undergraduate"];
    NSURL *directionsListUrl = [NSURL URLWithString:@"https://org.mephi.ru/pupil-rating/"];
    
    NSData *freeSeatsUrlData = [NSData dataWithContentsOfURL:freeSeatsUrl];
    NSData *directionsListUrlData = [NSData dataWithContentsOfURL:directionsListUrl];
    
    TFHpple *freeSeatsParser = [TFHpple hppleWithHTMLData:freeSeatsUrlData];
    TFHpple *directionsListParser = [TFHpple hppleWithHTMLData:directionsListUrlData];
    
    // Load free seats
    
    TFHppleElement *freeSeatsTableNode = [[freeSeatsParser searchWithXPathQuery:@"//table/tbody"] objectAtIndex:1];;
    NSMutableArray *currentFreeSeatsNodes = (NSMutableArray *)[freeSeatsTableNode searchWithXPathQuery:@"//tr"];
    [currentFreeSeatsNodes removeObjectAtIndex:0];
    NSArray *freeSeatsNodes = [NSArray arrayWithArray:currentFreeSeatsNodes];
    
    // Load directions
    
    TFHppleElement *directionsLinksListNode = [[directionsListParser searchWithXPathQuery:@"//table[@class='w100']"] objectAtIndex:0];
    NSArray *directionsLinkNodes = [directionsLinksListNode searchWithXPathQuery:@"//tr"];
    
    NSMutableArray *currentDirectionsLinkNodes = [NSMutableArray arrayWithArray:directionsLinkNodes];
    [currentDirectionsLinkNodes removeObjectAtIndex:1];
    [currentDirectionsLinkNodes removeObjectAtIndex:0];
    
    // Remove unnecessary directions
    
    NSMutableArray *newDirectionLinkNodes = [NSMutableArray array];

    for (TFHppleElement *directionsLinkNode in currentDirectionsLinkNodes) {
        
        NSArray *directionLinkInfoNodes = [directionsLinkNode searchWithXPathQuery:@"//td"];
        
        TFHppleElement *directionNameNode = [directionLinkInfoNodes objectAtIndex:0];
        NSString *directionRaw = [directionNameNode raw];
                
        NSString *directionNameType = [[[directionRaw componentsSeparatedByString:@", "] lastObject] substringToIndex:6];
        
        if ([directionNameType isEqualToString:@"Бюджет"]) {
            [newDirectionLinkNodes addObject:directionsLinkNode];
        }
        
    }
    
    directionsLinkNodes = [NSArray arrayWithArray:newDirectionLinkNodes];
    
    // Save all data
    
    NSMutableArray *directionNames = [NSMutableArray array];
    NSMutableArray *studentsNodesList = [NSMutableArray array];
    NSMutableArray *allMarksCounts = [NSMutableArray array];
    NSMutableArray *originalMarksCounts = [NSMutableArray array];
    NSMutableArray *freeSeats = [NSMutableArray array];
    
    for (TFHppleElement *directionsLinkNode in directionsLinkNodes) {
        
        NSArray *directionLinkInfoNodes = [directionsLinkNode searchWithXPathQuery:@"//td"];
        
        TFHppleElement *directionNameNode = [directionLinkInfoNodes objectAtIndex:0];
        TFHppleElement *directionLinkNode = [[directionsLinkNode searchWithXPathQuery:@"//td/a"] objectAtIndex:0];
        
        NSString *directionRaw = [directionNameNode raw];
        
        NSString *directionName = [[[directionRaw componentsSeparatedByString:@", "] objectAtIndex:0] substringFromIndex:180];
        
        [directionNames addObject:directionName];
        
        
        NSString *mainUrl = @"https://org.mephi.ru";
        NSString *urlString = [mainUrl stringByAppendingString:[directionLinkNode.attributes objectForKey:@"href"]];
        
        NSURL *url = [NSURL URLWithString:urlString];
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        TFHpple *studentsParser = [TFHpple hppleWithHTMLData:urlData];
        
        NSString *studentsXpathQueryString = @"//tr[@class='trPosBen']";
        NSArray *studentsNodes = [studentsParser searchWithXPathQuery:studentsXpathQueryString];
        
        for (TFHpple *freeSeatNode in freeSeatsNodes) {
            
            NSArray *freeSeatInfoNodes = [freeSeatNode searchWithXPathQuery:@"//td"];
            TFHppleElement *freeSeatDirectionNameNode = [freeSeatInfoNodes objectAtIndex:2];
            TFHppleElement *freeSeatCountNode = [freeSeatInfoNodes objectAtIndex:3];
            
            NSString *freeSeatDirectionName = [[freeSeatDirectionNameNode text] substringFromIndex:5];
            NSInteger freeSeatsCount = [[[freeSeatCountNode text] substringFromIndex:5] integerValue];
            
            if ([freeSeatDirectionName isEqualToString:directionName]) {
            
                [freeSeats addObject:[NSNumber numberWithInt:(int)freeSeatsCount]];
                
                [studentsNodesList addObject:studentsNodes];
                
            }
        }
        
        self.directionsFreeSeats = freeSeats;

    }
    
    self.studentsNodesList = [NSArray arrayWithArray:studentsNodesList];
    self.directionNames = [NSArray arrayWithArray:directionNames];
    
    for (NSArray *studentsNodes in self.studentsNodesList) {
        
        NSNumber *allMarksCount = [NSNumber numberWithInt:(int)[self calculateMarksCount:MarksCountTypeAll forStudentsNodes:studentsNodes]];
        
        [allMarksCounts addObject:allMarksCount];
        
        NSNumber *originalMarksCount = [NSNumber numberWithInt:(int)[self calculateMarksCount:MarksCountTypeOriginal forStudentsNodes:studentsNodes]];
        
        
        [originalMarksCounts addObject:originalMarksCount];
        
    }
    
    self.allMarksCounts = [NSArray arrayWithArray:allMarksCounts];
    self.originalMarksCounts = [NSArray arrayWithArray:originalMarksCounts];
    
    [self.tableView reloadData];
    
}
    

- (NSInteger)calculateMarksCount:(MarksCountType)marksCountType forStudentsNodes:(NSArray *)studentsNodes {
    
    NSMutableArray *marksCounts = [NSMutableArray array];
    
    //NSLog(@"%@", studentsNodes);
    
    if (marksCountType == MarksCountTypeAll) {
        
        for (TFHppleElement *studentNode in studentsNodes) {
            
            NSArray *studentMarksNodes = [studentNode searchWithXPathQuery:@"//td[@class='fullSumSt']"];
            TFHppleElement *studentMarksNode = [studentMarksNodes objectAtIndex:0];
            
            //NSLog(@"%@", [studentMarksNode text]);
            NSInteger currenMarksCount = [[studentMarksNode text] integerValue];
            [marksCounts addObject:[NSNumber numberWithInt:(int)currenMarksCount]];
            
        }
        
    } else if (marksCountType == MarksCountTypeOriginal) {
        
        for (TFHppleElement *studentNode in studentsNodes) {
            
            NSArray *studentInformationNodes = [studentNode searchWithXPathQuery:@"//td"];
            TFHppleElement *studentOriginalNode = [studentInformationNodes objectAtIndex:8];
            
            if (![[studentOriginalNode text] isEqualToString:@"Копия"]) {
                
                TFHppleElement *studentMarksNode = [studentInformationNodes objectAtIndex:7];
                
                NSInteger currenMarksCount = [[studentMarksNode text] integerValue];
                [marksCounts addObject:[NSNumber numberWithInt:(int)currenMarksCount]];
                
            }
        }
    }
    
    [marksCounts sortUsingComparator:^NSComparisonResult(id  __nonnull obj1, id  __nonnull obj2) {
        return [obj2 compare:obj1];
    }];
    
    NSInteger index = [self.studentsNodesList indexOfObject:studentsNodes];
    NSInteger lastMarksCountIndex = [[self.directionsFreeSeats objectAtIndex:index] integerValue] -1;
    
    NSInteger marksCount = [[marksCounts objectAtIndex:lastMarksCountIndex] integerValue];
    
    return marksCount;
}



#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [self.studentsNodesList count];
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *directionFullName = [self.directionNames objectAtIndex:section];
    
    NSString *directionName = [[directionFullName componentsSeparatedByString:@","] objectAtIndex:0];
    
    return directionName;
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
        
        NSString *directionFullName = [self.directionNames objectAtIndex:indexPath.section];
        NSString *directionName = [[directionFullName componentsSeparatedByString:@","] objectAtIndex:0];
        
        NSString *departmentName = [[directionFullName componentsSeparatedByString:@","] objectAtIndex:1];
        
        NSRange departmentRange = NSMakeRange(11, 3);
        departmentName = [departmentName substringWithRange:departmentRange];
        
        cell.departmentLabel.text = departmentName;
        cell.nameLabel.text = directionName;
        
        //NSInteger allMarksCount = [[self.allMarksCounts objectAtIndex:indexPath.section] integerValue];
        NSInteger originalMarksCount = [[self.originalMarksCounts objectAtIndex:indexPath.section] integerValue];
        
        //cell.allMarksLabel.text = [NSString stringWithFormat:@"%d", (int)allMarksCount];
        cell.originalMarksLabel.text = [NSString stringWithFormat:@"%d", (int)originalMarksCount];
        
        //NSInteger averageMarksCount = (allMarksCount + originalMarksCount) / 2;
        
        if ((int)self.myMarksCount >= (int)originalMarksCount) {
            
            cell.backgroundColor = self.cellLightGreenColor;
            
        } else {
            
            cell.backgroundColor = self.cellLightRedColor;
            
        }
        
        /*
        if (allMarksCount > (int)self.myMarksCount) {
            
            cell.allMarksLabel.textColor = [UIColor whiteColor];
            cell.allMarksView.backgroundColor = [self cellRedColor];
            
        } else {
            
            cell.allMarksLabel.textColor = [UIColor whiteColor];
            cell.allMarksView.backgroundColor = [self cellGreenColor];
            
        }
        */ 
        
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

    MephiViewController *mephiViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MephiViewController"];
    mephiViewController.isLoadingAllDirections = YES;
    
    [self.navigationController pushViewController:mephiViewController animated:YES];

}

@end
