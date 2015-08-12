//
//  SignUpViewController.m
//  Hayden
//
//  Created by Matti on 08/04/15.
//  Copyright (c) 2015 Matti. All rights reserved.
//

#import "SignUpViewController.h"
#import "Utils.h"
#import <Parse/Parse.h>
#import "ProgressHUD.h"
#import "NIDropDown.h"
#import <AddressBook/AddressBook.h>

@interface SignUpViewController ()<CLLocationManagerDelegate>
{
    NIDropDown *dropDown;
    UIToolbar *m_toolBar;
    UIPickerView *m_pickerView;
    NSMutableArray *pickerDataSourceArray;
    UITextField *currentTextField;
    
    CLLocationManager *locationManager;
    NSString *city;
    NSString *state;
    NSString *country;
}
@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navBackIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(BackPressed)];
    [self.navigationItem setLeftBarButtonItem:backBtn animated:NO];
    
    pickerDataSourceArray = [[NSMutableArray alloc] init];
    m_pickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
    m_pickerView.delegate = self;
    m_pickerView.dataSource = self;
    self.sexField.inputView = m_pickerView;
    
    m_toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    [m_toolBar setBarStyle:UIBarStyleDefault];
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(btnDoneClick:)];
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    m_toolBar.items = [[NSArray alloc] initWithObjects:flexibleItem, barButtonDone, nil];
    barButtonDone.tintColor = [UIColor blackColor];
    self.sexField.inputAccessoryView = m_toolBar;
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
#ifdef __IPHONE_8_0
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [locationManager requestWhenInUseAuthorization];
        [locationManager requestAlwaysAuthorization];
    }
#endif
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;

    [locationManager startUpdatingLocation];
    
    self.m_scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, signupBtn.frame.origin.y + 160);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)btnDoneClick:(id)sender{
    [currentTextField resignFirstResponder];
    currentTextField.text = pickerDataSourceArray[[m_pickerView selectedRowInComponent:0]];
}
- (void)BackPressed{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    currentTextField = textField;
    if ([textField isEqual:self.sexField] || [textField isEqual:self.raceField] || [textField isEqual:self.heightField]) {
        textField.inputView = m_pickerView;
        textField.inputAccessoryView = m_toolBar;
        if ([textField isEqual:self.sexField]) {
            pickerDataSourceArray = [[NSMutableArray alloc] initWithObjects:@"Male", @"Female", nil];
            [m_pickerView reloadAllComponents];
            [m_pickerView selectRow:0 inComponent:0 animated:YES];
        } else if ([textField isEqual:self.raceField]){
            pickerDataSourceArray = [[NSMutableArray alloc] initWithObjects:@"White", @"Black", @"Asian", @"Hispanic", @"Mix", @"Other", nil];
            [m_pickerView reloadAllComponents];
            [m_pickerView selectRow:0 inComponent:0 animated:YES];
        } else if ([textField isEqual:self.heightField]){
            [pickerDataSourceArray removeAllObjects];
            for (int i = 5; i < 7; i ++) {//Feet
                for (int j = 0; j < 10; j ++) {
                    if (i == 6 && j >= 7) {
                        continue;
                    }
                    [pickerDataSourceArray addObject:[NSString stringWithFormat:@"%d'%d\"", i, j]];
                }
            }
            [m_pickerView reloadAllComponents];
            [m_pickerView selectRow:0 inComponent:0 animated:YES];
        }
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([textField isEqual:self.nameField]) {
        [self.sexField becomeFirstResponder];
    } else if ([textField isEqual:self.sexField]){
        [self.ageField becomeFirstResponder];
    } else if ([textField isEqual:self.ageField]){
        [self.raceField becomeFirstResponder];
    } else if ([textField isEqual:self.raceField]){
        [self.heightField becomeFirstResponder];
    } else if ([textField isEqual:self.heightField]){
        [self.emailField becomeFirstResponder];
    } else if ([textField isEqual:self.emailField]){
        [self.passwordField becomeFirstResponder];
    } else if ([textField isEqual:self.passwordField]){
        [self.repeatpwdField becomeFirstResponder];
    } else if ([textField isEqual:self.repeatpwdField]){
        [textField resignFirstResponder];
    }

    return YES;
}

#pragma mark - UIPickerView
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return pickerDataSourceArray.count;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return pickerDataSourceArray[row];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    currentTextField.text = pickerDataSourceArray[row];
}

#pragma mark - UIButton Action
- (IBAction)btnCreateClick:(id)sender {
    if (self.nameField.text.length <= 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign Up Error" message:@"Name could not be empty" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    if (self.sexField.text.length <= 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign Up Error" message:@"Sex could not be empty" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    if (self.ageField.text.length <= 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign Up Error" message:@"Age could not be empty" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    if (self.raceField.text.length <= 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign Up Error" message:@"Race could not be empty" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    if (self.heightField.text.length <= 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign Up Error" message:@"Height could not be empty" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    if (![Utils NSStringIsValidEmail:self.emailField.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign Up Error" message:@"Email is not correct" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    if (self.passwordField.text.length < 8) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign Up Error" message:@"Password should be at least 8 characters" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    if (![self.passwordField.text isEqualToString:self.repeatpwdField.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign Up Error" message:@"Password does not match" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    if (city.length == 0 || state.length == 0 || country.length == 0) {
        [ProgressHUD showError:@"Could not get location information"];
        return;
    }

    PFUser *user = [PFUser user];
    user.username = self.emailField.text;
    user.email = self.emailField.text;
    user.password = self.passwordField.text;
    user[@"name"] = self.nameField.text;
    user[@"sex"] = self.sexField.text;
    user[@"age"] = self.ageField.text;
    user[@"height"] = self.heightField.text;
    user[@"swipes"] = [NSNumber numberWithInteger:100];
    user[@"swiped"] = [NSNumber numberWithInteger:0];
    user[@"beSwiped"] = [NSNumber numberWithInteger:0];
    user[@"city"] = city;
    user[@"state"] = state;
    user[@"country"] = country;

    [ProgressHUD show:@"Creating..." Interaction:NO];
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [ProgressHUD dismiss];
            [Utils setObjectToUserDefaults:self.emailField.text inUserDefaultsForKey:LOGGEDNAME];
            [Utils setObjectToUserDefaults:self.passwordField.text inUserDefaultsForKey:LOGGEDPWD];
            [self performSegueWithIdentifier:@"gotoMainVC" sender:nil];
        } else{
            NSLog(@"%@", error.userInfo[@"error"]);
        }
    }];
}

#pragma mark - CLLocationManager Delegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    switch ([error code]) {
        case kCLErrorNetwork:
            [ProgressHUD showError:@"Network Error" Interaction:NO];
            break;
        case kCLErrorDenied:
            [ProgressHUD showError:@"You have to enable the Location Service to use this app. To enable, please go to Settings->Privacy->Location Services" Interaction:NO];
            break;
        default:
            break;
    }
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *location = [locations objectAtIndex:0];
    [locationManager stopUpdatingLocation];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            city = [placemark.addressDictionary objectForKey:(NSString*)kABPersonAddressCityKey];
            state = [placemark.addressDictionary objectForKey:(NSString*)kABPersonAddressStateKey];
            country = [placemark.addressDictionary objectForKey:(NSString*)kABPersonAddressCountryKey];
        } else{
            NSLog(@"geocoding failed %@", error);
        }
    }];
}

@end
