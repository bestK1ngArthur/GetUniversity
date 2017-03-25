//
//  MainViewController.h
//  GetUniversity
//
//  Created by Artem Belkov on 14/07/15.
//  Copyright © 2015 Artem Belkov. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MainViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *marksCountLabel;

- (IBAction)actionEnterMarksCount:(id)sender;

@end
