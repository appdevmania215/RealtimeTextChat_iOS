//
//  ChatViewController.h
//  Hayden
//
//  Created by Matti on 17/04/15.
//  Copyright (c) 2015 Matti. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSQMessages.h"
#import <Parse/Parse.h>

@interface ChatViewController : JSQMessagesViewController<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) PFUser *secondUser;

@property (nonatomic, strong) NSString *chatRoom;
@property (nonatomic, strong) NSString *otherId;
@property (nonatomic, strong) NSString *otherAvatarUrl;
@property (nonatomic, strong) NSMutableArray *chatHistory;

@end
