//
//  ProfileViewController.h
//  Hayden
//
//  Created by Matti on 07/04/15.
//  Copyright (c) 2015 Matti. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileViewController : UITableViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *selfieImgView;
@property (weak, nonatomic) IBOutlet UILabel *namelbl;
@property (weak, nonatomic) IBOutlet UILabel *locationlbl;
@property (weak, nonatomic) IBOutlet UILabel *agelbl;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *photosImgView;
@property (strong, nonatomic) IBOutlet UILabel *beswipedlbl;
@property (strong, nonatomic) IBOutlet UILabel *swipedlbl;


@end
