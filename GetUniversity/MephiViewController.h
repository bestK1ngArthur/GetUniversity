//
//  MephiViewController.h
//  GetUniversity
//
//  Created by Artem Belkov on 14/07/15.
//  Copyright © 2015 Artem Belkov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MephiViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *loadingAllDirectionBarItem;

- (IBAction)actionLoadAllDirections:(id)sender;

@end
