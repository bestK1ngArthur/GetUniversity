//
//  UniversityTableViewCell.h
//  GetUniversity
//
//  Created by Artem Belkov on 14/07/15.
//  Copyright © 2015 Artem Belkov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UniversityTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *departmentLabel;
@property (nonatomic, weak) IBOutlet UILabel *originalMarksLabel;

@property (nonatomic, weak) IBOutlet UIView *originalMarksView;


@end
