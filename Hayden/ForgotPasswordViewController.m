//
//  ForgotPasswordViewController.m
//  Hayden
//
//  Created by Matti on 27/04/15.
//  Copyright (c) 2015 Matti. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import <Parse/Parse.h>
#import "Utils.h"
#import "ProgressHUD.h"

@interface ForgotPasswordViewController ()

@end

@implementation ForgotPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navBackIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(BackPressed)];
    [self.navigationItem setLeftBarButtonItem:backBtn animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)BackPressed{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIButton
- (IBAction)btnResetClick:(id)sender{
    if ([Utils NSStringIsValidEmail:self.emailField.text]) {
        [PFUser requestPasswordResetForEmailInBackground:self.emailField.text block:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [ProgressHUD showSuccess:@"Reset link was sent to your email"];
            }
        }];
    } else{
        [ProgressHUD showError:@"Invalid Email"];
    }
}

@end
