//
//  StartViewController.h
//  Hayden
//
//  Created by Matti on 10/04/15.
//  Copyright (c) 2015 Matti. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StartViewController : UITableViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>


@property (weak, nonatomic) IBOutlet UIImageView *selfieImgView;

@property (weak, nonatomic) IBOutlet UIButton *nearbyBtn;
@property (weak, nonatomic) IBOutlet UIButton *cityBtn;
@property (weak, nonatomic) IBOutlet UIButton *stateBtn;
@property (weak, nonatomic) IBOutlet UIButton *countryBtn;

@property (weak, nonatomic) IBOutlet UILabel *swipeslbl;


@end
