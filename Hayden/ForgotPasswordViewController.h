//
//  ForgotPasswordViewController.h
//  Hayden
//
//  Created by Matti on 27/04/15.
//  Copyright (c) 2015 Matti. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTextField.h"

@interface ForgotPasswordViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet CustomTextField *emailField;

@end
