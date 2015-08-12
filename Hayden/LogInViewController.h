//
//  LogInViewController.h
//  Hayden
//
//  Created by Matti on 14/04/15.
//  Copyright (c) 2015 Matti. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTextField.h"

@interface LogInViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet CustomTextField *emailField;
@property (weak, nonatomic) IBOutlet CustomTextField *passwordField;

@end
