//
//  RoomTableCell.m
//  Hayden
//
//  Created by Matti on 17/04/15.
//  Copyright (c) 2015 Matti. All rights reserved.
//

#import "RoomTableCell.h"

@implementation RoomTableCell

- (void)awakeFromNib {
    // Initialization code
    self.avatarImgView.layer.cornerRadius = 32.5f;
    self.avatarImgView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
