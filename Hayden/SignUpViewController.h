//
//  SignUpViewController.h
//  Hayden
//
//  Created by Matti on 08/04/15.
//  Copyright (c) 2015 Matti. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTextField.h"
#import "TPKeyboardAvoidingScrollView.h"

@interface SignUpViewController : UIViewController<UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>{


    IBOutlet UIButton *signupBtn;
}

@property (weak, nonatomic) IBOutlet UIScrollView *m_scrollView;
@property (weak, nonatomic) IBOutlet CustomTextField *nameField;
@property (weak, nonatomic) IBOutlet CustomTextField *sexField;
@property (weak, nonatomic) IBOutlet CustomTextField *ageField;
@property (weak, nonatomic) IBOutlet CustomTextField *raceField;
@property (weak, nonatomic) IBOutlet CustomTextField *heightField;
@property (weak, nonatomic) IBOutlet CustomTextField *emailField;
@property (weak, nonatomic) IBOutlet CustomTextField *passwordField;
@property (weak, nonatomic) IBOutlet CustomTextField *repeatpwdField;

@property (strong, nonatomic) IBOutlet CustomTextField *createfield;
@end
