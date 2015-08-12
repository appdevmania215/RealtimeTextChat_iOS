//
//  LogInViewController.m
//  Hayden
//
//  Created by Matti on 14/04/15.
//  Copyright (c) 2015 Matti. All rights reserved.
//

#import "LogInViewController.h"
#import <Parse/Parse.h>
#import "ProgressHUD.h"
#import "Utils.h"

@interface LogInViewController ()

@end

@implementation LogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navBackIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(BackPressed)];
    [self.navigationItem setLeftBarButtonItem:backBtn animated:NO];
    
    ////MT
    self.emailField.text = [Utils getObjectFromUserDefaultsForKey:LOGGEDNAME];
    self.passwordField.text = [Utils getObjectFromUserDefaultsForKey:LOGGEDPWD];
}
- (void)BackPressed{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIButton
- (IBAction)btnLoginClick:(id)sender {
    [ProgressHUD show:@"" Interaction:NO];
    [PFUser logInWithUsernameInBackground:self.emailField.text password:self.passwordField.text block:^(PFUser *user, NSError *error) {
        if (user) {
            [ProgressHUD dismiss];
            [Utils setObjectToUserDefaults:self.emailField.text inUserDefaultsForKey:LOGGEDNAME];
            [Utils setObjectToUserDefaults:self.passwordField.text inUserDefaultsForKey:LOGGEDPWD];
            [self performSegueWithIdentifier:@"gotoMainVC" sender:nil];
        } else{
            [ProgressHUD showError:@"Login Error" Interaction:NO];
            NSLog(@"===Login Error===%@", error.description);
        }
    }];
}

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([textField isEqual:self.emailField]) {
        [self.passwordField becomeFirstResponder];
    } else if ([textField isEqual:self.passwordField]){
        [textField resignFirstResponder];
        [self btnLoginClick:nil];
    }
    return YES;
}

@end
