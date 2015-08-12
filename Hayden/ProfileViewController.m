//
//  ProfileViewController.m
//  Hayden
//
//  Created by Matti on 07/04/15.
//  Copyright (c) 2015 Matti. All rights reserved.
//

#import "ProfileViewController.h"
#import <Parse/Parse.h>

@interface ProfileViewController ()
{
    BOOL isSelfie;
    NSMutableArray *userPhotosArray;
    PFObject *userPhotosObj;
    IBOutlet UILabel *lastMatchedUserLbl;
    
}
@end

@implementation ProfileViewController

- (void)awakeFromNib{
    [self.navigationController.tabBarItem setImage:[[UIImage imageNamed:@"profile"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    PFUser *user = [PFUser currentUser];
    
    self.namelbl.text = user[@"name"];
    self.locationlbl.text = [NSString stringWithFormat:@"%@, %@", user[@"city"], user[@"country"]];
    self.agelbl.text = user[@"age"];
    
    PFFile *selfie = user[@"selfie"];
    [selfie getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            if (data != nil) {
                self.selfieImgView.image = [UIImage imageWithData:data];
            }
        } else{
            NSLog(@"%@", error);
        }
    }];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Photos"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        userPhotosObj = object;

        userPhotosArray = object[@"photos"];
        if (userPhotosArray == nil) {
            userPhotosArray = [[NSMutableArray alloc] init];
        }

        for (int i = 0; i < userPhotosArray.count; i ++) {
            UIImageView *imgview = [self.photosImgView objectAtIndex:i];
            imgview.image = [UIImage imageWithData:[userPhotosArray[i] getData]];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    PFFile *selfie = [PFUser currentUser][@"selfie"];
    [selfie getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            if (data != nil) {
                self.selfieImgView.image = [UIImage imageWithData:data];
            }
        } else{
            NSLog(@"%@", error);
        }
    }];
    
    self.beswipedlbl.text = [NSString stringWithFormat:@"%ld", (long)[[PFUser currentUser][@"beSwiped"]integerValue]];
    self.swipedlbl.text = [NSString stringWithFormat:@"%ld", (long)[[PFUser currentUser][@"swiped"]integerValue]];
    
    //last matched user label display
    PFQuery *query = [PFQuery queryWithClassName:@"Matches"];
    NSString *currentUserSex = [[PFUser currentUser] objectForKey:@"sex"];
    if ([currentUserSex isEqualToString:@"Male"]) {
        [query whereKey:@"male" equalTo:[PFUser currentUser]];
    } else{
        [query whereKey:@"female" equalTo:[PFUser currentUser]];
    }
    
    [query includeKey:@"male"];
    [query includeKey:@"female"];
    query.limit = 10;
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error && (objects.count > 0)){
            PFObject * lastMatch = [objects firstObject];
            NSString *otherUser;
            if ([currentUserSex isEqualToString:@"Male"]) {
                otherUser = lastMatch[@"female"][@"name"];
            } else{
                otherUser = lastMatch[@"male"][@"name"];
            }
            
            NSString *votes = [NSString stringWithFormat:@"%ldVotes", (long)[lastMatch[@"heart"]integerValue]];
            NSString *location = [PFUser currentUser][@"country"];
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"dd/MM/yy"];
            NSString * date = [formatter stringFromDate:lastMatch.createdAt];
            NSString *matchedUserStr = [NSString stringWithFormat:@"%@    %@    %@    %@", otherUser, votes, location, date];
            
            lastMatchedUserLbl.text = matchedUserStr;
        }else{
            lastMatchedUserLbl.text = @"";
        }
    }];
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

#pragma mark - UIButton Action
- (IBAction)btnUploadSelfie:(id)sender{
    isSelfie = YES;
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    
    [self presentViewController:picker animated:YES completion:nil];

}
- (IBAction)btnAddNewPhoto:(id)sender{
    isSelfie = NO;
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    if (isSelfie) {
        self.selfieImgView.image = chosenImage;
        PFUser *user = [PFUser currentUser];
        PFFile *selfie = [PFFile fileWithData:UIImageJPEGRepresentation(chosenImage, 1.f)];
        user[@"selfie"] = selfie;
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"succeeded");
            } else{
                NSLog(@"%@", error);
            }
        }];
    } else{
        PFFile *photofile = [PFFile fileWithData:UIImageJPEGRepresentation(chosenImage, 1.f)];
        if (userPhotosArray.count >= 3) {
            [userPhotosArray removeObjectAtIndex:0];
            [userPhotosArray addObject:photofile];
        } else{
            [userPhotosArray addObject:photofile];
        }
        for (int i = 0; i < userPhotosArray.count; i ++) {
            UIImageView *imgview = [self.photosImgView objectAtIndex:i];
            imgview.image = [UIImage imageWithData:[userPhotosArray[i] getData]];
        }
        if (userPhotosObj == nil) {
            userPhotosObj = [PFObject objectWithClassName:@"Photos"];
            userPhotosObj[@"user"] = [PFUser currentUser];
        }
        userPhotosObj[@"photos"] = userPhotosArray;
        [userPhotosObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                NSLog(@"succeeded");
            } else{
                NSLog(@"%@", error);
            }
        }];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
