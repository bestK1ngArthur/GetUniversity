//
//  MainViewController.m
//  GetUniversity
//
//  Created by Artem Belkov on 14/07/15.
//  Copyright © 2015 Artem Belkov. All rights reserved.
//

#import "MainViewController.h"
#import "Reachability.h"

static NSString *kUserMarksCount = @"userMarksCount";

@interface MainViewController ()



@end

@implementation MainViewController

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.marksCountLabel.text = [self getInfoStringFromMarksCount:[self userMarksCount]];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [self checkInternetConnection];
    
}

- (NSString *)getInfoStringFromMarksCount:(NSInteger)marksCount {
    
    NSInteger lastNumber = marksCount % 10;
    
    NSString *string;
    
    if (lastNumber == 1) {
        string = [NSString stringWithFormat:@"У меня %d балл", (int)marksCount];
    } else if ((lastNumber == 2) || (lastNumber == 3) || (lastNumber == 4)) {
        string = [NSString stringWithFormat:@"У меня %d балла", (int)marksCount];
    } else {
        string = [NSString stringWithFormat:@"У меня %d баллов", (int)marksCount];
    }
    
    return string;
}

#pragma mark - NSUserDefaults

- (void)saveUserMarksCount:(NSInteger)userMarksCount {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setInteger:userMarksCount forKey:kUserMarksCount];
    [userDefaults synchronize];
    
}

- (NSInteger)userMarksCount {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    return [userDefaults integerForKey:kUserMarksCount];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - Segue

- (void)prepareForSegue:(nonnull UIStoryboardSegue *)segue sender:(nullable id)sender {
    
    [self checkInternetConnection];
    
}

#pragma mark - Actions

- (IBAction)actionEnterMarksCount:(id)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Баллы ЕГЭ"
                                                                   message:@"Введите свои баллы ЕГЭ"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * __nonnull textField) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             
                             UITextField *textField = [[alert textFields] objectAtIndex:0];
                             
                             if ([textField.text integerValue]) {
                                 
                                 NSInteger marksCount = [textField.text integerValue];
                                 
                                 [self saveUserMarksCount:marksCount];
                                 self.marksCountLabel.text = [self getInfoStringFromMarksCount:marksCount];
                                 
                                 [alert dismissViewControllerAnimated:YES completion:nil];

                             }
                         }];
    
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [alert addAction:cancel];
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark- Internet Connection

- (void)checkInternetConnection {
    
    Reachability *curReach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    switch (netStatus) {
        case NotReachable: {
            
            UIViewController *networkErrorViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"NetworkErrorViewController"];
            [self presentViewController:networkErrorViewController animated:YES completion:nil];
            
            break;
        } case ReachableViaWWAN: {
            
            
        } case ReachableViaWiFi: {
            
        }
    }
    
}

@end
