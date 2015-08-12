//
//  MessagesViewController.m
//  Hayden
//
//  Created by Matti on 07/04/15.
//  Copyright (c) 2015 Matti. All rights reserved.
//

#import "MessagesViewController.h"
#import "RoomTableCell.h"
#import "ChatViewController.h"
#import <Firebase/Firebase.h>
#import "Utils.h"

@interface MessagesViewController ()
{
    Firebase *firebase;
    NSMutableDictionary *roomsMutDict;
}
@end

@implementation MessagesViewController

- (void)awakeFromNib{
    [self.navigationController.tabBarItem setImage:[[UIImage imageNamed:@"message"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    roomsMutDict = [[NSMutableDictionary alloc] init];
    firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/messages", FirebaseURL]];
    [firebase observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSLog(@"%@, %@", snapshot.key, snapshot.value);
        for(FDataSnapshot *roomshot in snapshot.children.allObjects){
            if ([roomshot.key containsString:[PFUser currentUser].objectId]){
                NSLog(@"%@, %@", roomshot.key, roomshot.value);
                FDataSnapshot *shot = [roomshot.children.allObjects lastObject];
                NSLog(@"%@, %@", shot.key, shot.value);
               
                NSMutableDictionary *roomdict = shot.value;
                NSString *objId = roomdict[@"user1"];
                if ([objId isEqualToString:[PFUser currentUser].objectId]) {
                    objId = roomdict[@"user2"];
                }
                PFQuery *query = [PFUser query];
                PFUser *secondUser = (PFUser*)[query getObjectWithId:objId];
                [roomdict setObject:secondUser forKey:@"secondUser"];
                
                [roomsMutDict setObject:roomdict forKey:roomshot.key];
                [self.m_tableView reloadData];
            }
        }
    }];
    self.m_tableView.tableFooterView = [UIView new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView data
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return roomsMutDict.allValues.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90.f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RoomTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"roomTableCell"];
    if (!cell) {
        cell = [[RoomTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"roomTableCell"];
    }
    cell.msglbl.text = roomsMutDict.allValues[indexPath.row][@"message"];
    
    PFUser *secondUser = roomsMutDict.allValues[indexPath.row][@"secondUser"];
    cell.namelbl.text = secondUser[@"name"];
    
    PFFile *secondSelfie = secondUser[@"selfie"];
    [secondSelfie getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            cell.avatarImgView.image = [UIImage imageWithData:data];
        } else{
            NSLog(@"%@", error);
        }
    }];
    
    NSString *timeStr = roomsMutDict.allValues[indexPath.row][@"date"];
    NSLog(@"time = %@", timeStr);
    NSDateFormatter *dfr = [[NSDateFormatter alloc]init];
    [dfr setDateFormat:@"yyyy-MM-dd hh:mm:s"];
    NSDate *dt = [dfr dateFromString:timeStr];
    
    [dfr setDateFormat:@"MM-dd-yyyy"];
    cell.timelbl.text = [dfr stringFromDate:dt];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ChatViewController *chatVC = [ChatViewController messagesViewController];
    chatVC.hidesBottomBarWhenPushed = YES;
    chatVC.secondUser = roomsMutDict.allValues[indexPath.row][@"secondUser"];
    [self.navigationController pushViewController:chatVC animated:YES];
}

@end
