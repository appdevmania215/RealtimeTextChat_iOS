//
//  RoomTableCell.h
//  Hayden
//
//  Created by Matti on 17/04/15.
//  Copyright (c) 2015 Matti. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoomTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarImgView;
@property (weak, nonatomic) IBOutlet UILabel *namelbl;
@property (weak, nonatomic) IBOutlet UILabel *msglbl;
@property (weak, nonatomic) IBOutlet UILabel *timelbl;

@end
