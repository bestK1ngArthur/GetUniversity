//
//  UniversityTableViewCell.m
//  GetUniversity
//
//  Created by Artem Belkov on 14/07/15.
//  Copyright © 2015 Artem Belkov. All rights reserved.
//

#import "UniversityTableViewCell.h"

@implementation UniversityTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (selected) {
        self.backgroundColor = [UIColor colorWithRed: 74 / 255.f
                                               green: 74 / 255.f
                                                blue: 74 / 255.f
                                               alpha: 1.f];
    }
    
    
    
    
    // Configure the view for the selected state
}

@end
