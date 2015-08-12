//
//  StartViewController.m
//  Hayden
//
//  Created by Matti on 10/04/15.
//  Copyright (c) 2015 Matti. All rights reserved.
//

#import "StartViewController.h"
#import <Parse/Parse.h>
#import <CoreLocation/CoreLocation.h>
#import "ProgressHUD.h"
#import <AddressBook/AddressBook.h>
#import "Utils.h"

@interface StartViewController ()<CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    NSInteger swipesCount;
    NSString *city;
    NSString *state;
    NSString *country;
    IBOutlet UIButton *startBtn;
}
@end

@implementation StartViewController

- (void)awakeFromNib{
    [self.navigationController.tabBarItem setImage:[[UIImage imageNamed:@"heart"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
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
    
    /// MT-location
    [self.countryBtn setSelected:YES];
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    PFUser *user = [PFUser currentUser];
    PFFile *selfie = user[@"selfie"];
    [selfie getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (data) {
            self.selfieImgView.image = [UIImage imageWithData:data];
        }
    }];
    
    swipesCount = [[PFUser currentUser][@"swipes"] integerValue];
    self.swipeslbl.text = [NSString stringWithFormat:@"%ld", (long)swipesCount];
    
    [locationManager startUpdatingLocation];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

#pragma mark - UIImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.selfieImgView.image = chosenImage;
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - UINavigationController Delegate
//- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//    navigationController.navigationBar.tintColor = [UIColor whiteColor];
//}

#pragma mark - UIButton Action
- (IBAction)btnUploadClick:(id)sender {
    UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
    imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imgPicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    imgPicker.delegate = self;
    imgPicker.allowsEditing = YES;
    [self presentViewController:imgPicker animated:YES completion:nil];
}

- (IBAction)btnStartClick:(id)sender {
    
    /// MT-location
//    if (!(self.nearbyBtn.selected || self.cityBtn.selected || self.stateBtn.selected || self.countryBtn.selected)) {
//        [ProgressHUD showError:@"Select Location"];
//        return;
//    }
    if (city.length == 0 || state.length == 0 || country.length == 0) {
        [ProgressHUD showError:@"Could not get location information"];
        return;
    }
    if (swipesCount <= 0) {
        [ProgressHUD showError:@"You need more swipes"];
        return;
    }
    if (self.selfieImgView.image == nil) {
        [ProgressHUD showError:@"Upload your selfie" Interaction:NO];
        return;
    }
    
    ////
    [startBtn setEnabled:false];
    [startBtn setTitle:@"In progress" forState:UIControlStateDisabled];
    
    /// MT-location
    PFQuery *query = [PFUser query];
//    if (self.cityBtn.selected) {
//        [query whereKey:@"city" equalTo:city];
//    } else if (self.stateBtn.selected){
//        [query whereKey:@"state" equalTo:state];
//    } else if (self.countryBtn.selected){
        [query whereKey:@"country" equalTo:country];
//    }
    
    [query whereKey:@"sex" notEqualTo:[[PFUser currentUser] objectForKey:@"sex"]];
    [query whereKey:@"selfie" notEqualTo:[NSNull null]];
    [ProgressHUD show:@"Searching..." Interaction:NO];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects.count > 0) {
            for (int i = 0; i < objects.count; i ++) {
                if (swipesCount <= 0) {
                    break;
                }
                
                PFUser *matchedUser = objects[i];
                
                PFObject *matchObject = [PFObject objectWithClassName:@"Matches"];
                matchObject[@"heart"] = [NSNumber numberWithInteger:0];
                
                PFQuery *query = [PFQuery queryWithClassName:@"Matches"];

                if ([[[PFUser currentUser] objectForKey:@"sex"] isEqualToString:@"Male"]) {
                    matchObject[@"male"] = [PFUser currentUser];
                    matchObject[@"female"] = matchedUser;
                    [query whereKey:@"male" equalTo:[PFUser currentUser]];
                    [query whereKey:@"female" equalTo:matchedUser];
                } else{
                    matchObject[@"male"] = matchedUser;
                    matchObject[@"female"] = [PFUser currentUser];
                    [query whereKey:@"male" equalTo:matchedUser];
                    [query whereKey:@"female" equalTo:[PFUser currentUser]];
                }
                
                [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    if (object) {
                        [object setObject:object[@"male"] forKey:@"male"];
                        [object saveInBackground];
                        NSLog(@"Match updated successfully");
                    } else{
                        [matchObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if (!error) {
                                NSLog(@"Match saved successfully");
                                
                            } else{
                                NSLog(@"%@", error);
                            }
                        }];
                    }
                   //
                    
                    [startBtn setEnabled:true];
                    
                }];
                
            }
            [ProgressHUD dismiss];
        } else{
            [ProgressHUD showError:@"Could not find your matches in selected area" Interaction:NO];
        }
    }];
    
    ////
    swipesCount -= 1;
    
    //Update swipes count status
    PFUser *user = [PFUser currentUser];
    user[@"swipes"] = [NSNumber numberWithInteger:swipesCount];
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.swipeslbl.text = [NSString stringWithFormat:@"%ld", (long)swipesCount];
    }];
    //////
}

- (IBAction)btnNearbyClick:(id)sender{
    UIButton *btn = (UIButton*)sender;
    btn.selected = !btn.selected;
    
    [self.cityBtn setSelected:NO];
    [self.cityBtn setBackgroundColor:COLORPurple];
    [self.stateBtn setSelected:NO];
    [self.stateBtn setBackgroundColor:COLORPurple];
    [self.countryBtn setSelected:NO];
    [self.countryBtn setBackgroundColor:COLORPurple];
    
    if (btn.selected) {
        [btn setBackgroundColor:COLORDarkPurple];
    } else{
        [btn setBackgroundColor:COLORPurple];
        [self.cityBtn setBackgroundColor:COLORPurple];
        [self.stateBtn setBackgroundColor:COLORPurple];
        [self.countryBtn setBackgroundColor:COLORPurple];
    }
}
- (IBAction)btnCityClick:(id)sender{
    UIButton *btn = (UIButton*)sender;
    btn.selected = !btn.selected;
    
    [self.nearbyBtn setSelected:NO];
    [self.nearbyBtn setBackgroundColor:COLORPurple];
    [self.stateBtn setSelected:NO];
    [self.stateBtn setBackgroundColor:COLORPurple];
    [self.countryBtn setSelected:NO];
    [self.countryBtn setBackgroundColor:COLORPurple];
    
    if (btn.selected) {
        [btn setBackgroundColor:COLORDarkPurple];
    } else{
        [btn setBackgroundColor:COLORPurple];
        [self.nearbyBtn setBackgroundColor:COLORPurple];
        [self.stateBtn setBackgroundColor:COLORPurple];
        [self.countryBtn setBackgroundColor:COLORPurple];
    }
}
- (IBAction)btnStateClick:(id)sender{
    UIButton *btn = (UIButton*)sender;
    btn.selected = !btn.selected;
    
    [self.nearbyBtn setSelected:NO];
    [self.nearbyBtn setBackgroundColor:COLORPurple];
    [self.cityBtn setSelected:NO];
    [self.cityBtn setBackgroundColor:COLORPurple];
    [self.countryBtn setSelected:NO];
    [self.countryBtn setBackgroundColor:COLORPurple];
    
    if (btn.selected) {
        [btn setBackgroundColor:COLORDarkPurple];
    } else{
        [btn setBackgroundColor:COLORPurple];
        [self.nearbyBtn setBackgroundColor:COLORPurple];
        [self.cityBtn setBackgroundColor:COLORPurple];
        [self.countryBtn setBackgroundColor:COLORPurple];
    }
}
- (IBAction)btnCountryClick:(id)sender{
    UIButton *btn = (UIButton*)sender;
    btn.selected = !btn.selected;
    
    [self.nearbyBtn setSelected:NO];
    [self.nearbyBtn setBackgroundColor:COLORPurple];
    [self.cityBtn setSelected:NO];
    [self.cityBtn setBackgroundColor:COLORPurple];
    [self.stateBtn setSelected:NO];
    [self.stateBtn setBackgroundColor:COLORPurple];
    
    if (btn.selected) {
        [btn setBackgroundColor:COLORDarkPurple];
    } else{
        [btn setBackgroundColor:COLORPurple];
    }
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
            [self.cityBtn setTitle:city forState:UIControlStateNormal];
            [self.stateBtn setTitle:state forState:UIControlStateNormal];
            [self.countryBtn setTitle:country forState:UIControlStateNormal];
            
            PFUser *user = [PFUser currentUser];
            user[@"city"] = city;
            user[@"state"] = state;
            user[@"country"] = country;
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    NSLog(@"user updated successfully");
                } else{
                    NSLog(@"%@", error);
                }
            }];
        } else{
            NSLog(@"geocoding failed %@", error);
        }
    }];
}

@end
