//
//  MainLogInViewController.m
//  Hayden
//
//  Created by Matti on 07/04/15.
//  Copyright (c) 2015 Matti. All rights reserved.
//

#import "MainLogInViewController.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>

@interface MainLogInViewController ()

@end

@implementation MainLogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"gotoMainVC"]) {
        
    }
}
- (IBAction)btnLoginFBClick:(id)sender{
//    [self performSegueWithIdentifier:@"gotoMainVC" sender:nil];
    [PFFacebookUtils logInInBackgroundWithReadPermissions:@[@"public_profile", @"email"] block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
        } else if (user.isNew){
            NSLog(@"User signed up and logged in through Facebook");
            [self performSegueWithIdentifier:@"gotoMainVC" sender:nil];
        } else{
            NSLog(@"user logged in through Facebook");
            [self performSegueWithIdentifier:@"gotoMainVC" sender:nil];
        }
    }];
}

@end
