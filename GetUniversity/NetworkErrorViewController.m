//
//  NetworkErrorViewController.m
//  GetUniversity
//
//  Created by Artem Belkov on 22/07/15.
//  Copyright © 2015 Artem Belkov. All rights reserved.
//

#import "NetworkErrorViewController.h"
#import "Reachability.h"

@interface NetworkErrorViewController ()

@end

@implementation NetworkErrorViewController

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    
    [self performSelectorInBackground:@selector(checkInternetConnection) withObject:nil];
    
}

#pragma mark - Memory

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SatusBar

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark- Internet Connection

- (void)checkInternetConnection {
    
    Reachability *curReach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    switch (netStatus) {
        case NotReachable: {
            self.doneButton.enabled = NO;
            break;
        } case ReachableViaWWAN: {
            
            //WTF!?
            
        } case ReachableViaWiFi: {
            
            //wi-fi
            
        } default: {
            self.doneButton.enabled = YES;
            break;
        }
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self checkInternetConnection];
    });
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
