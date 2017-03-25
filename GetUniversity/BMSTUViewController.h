//
//  BMSTUViewController.h
//  GetUniversity
//
//  Created by Artem Belkov on 14/07/15.
//  Copyright © 2015 Artem Belkov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BMSTUViewController : UITableViewController <UITabBarDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *loadingAllDirectionBarItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *chooseDirectionBarItem;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdateLabel;


- (IBAction)actionLoadAllDirections:(id)sender;
- (IBAction)actionChooseDirections:(id)sender;


@end
